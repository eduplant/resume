# Disable built-in implicit rules and suffixes
MAKEFLAGS += --no-builtin-rules
.SUFFIXES :

# Define the shell to use
SHELL := /usr/bin/env bash

###########
# VARIABLES
###########

# Define basic naming conventions for the involved files
RESUME_STUB := eduplant-resume
COMMON_CONTACT_STUB := contact
PUBLIC_CONTACT_STUB := $(COMMON_CONTACT_STUB)-public
PRIVATE_CONTACT_STUB := $(COMMON_CONTACT_STUB)-private
RESUME_TARGET_PUBLIC_STUB := $(RESUME_STUB)-public
RESUME_TARGET_PRIVATE_STUB := $(RESUME_STUB)-private

# Define output PDF naming conventions
RESUME_TARGET_PUBLIC := $(RESUME_TARGET_PUBLIC_STUB).pdf
RESUME_TARGET_PRIVATE := $(RESUME_TARGET_PRIVATE_STUB).pdf

# Define input .tex naming conventions
RESUME_SRC := $(RESUME_STUB).tex
COMMON_CONTACT_SRC := $(COMMON_CONTACT_STUB).tex
PUBLIC_CONTACT_SRC := $(PUBLIC_CONTACT_STUB).tex
PRIVATE_CONTACT_SRC := $(PRIVATE_CONTACT_STUB).tex

# Define encrypted .tex naming conventions
PRIVATE_CONTACT_SRC_ENCRYPTED := $(PRIVATE_CONTACT_SRC).gpg

# Define the PDFs that we are trying to build
BUILD_TARGETS := $(RESUME_TARGET_PUBLIC) \
		$(RESUME_TARGET_PRIVATE)

#######
# RULES
#######

# Default target
.PHONY: resume
resume: $(BUILD_TARGETS)

# Conventional cleanup target
.PHONY: clean
clean:
	# Ignore errors in the event that some clean targets don't exist
	-rm -f $(BUILD_TARGETS)

# Vanity target for only building the public resume
.PHONY: public
public: $(RESUME_TARGET_PUBLIC)

# Vanity target for only building the private resume
.PHONY: private
private: $(RESUME_TARGET_PRIVATE)

# How to render the PDF with public contact information
$(RESUME_TARGET_PUBLIC): $(RESUME_SRC) $(PUBLIC_CONTACT_SRC)
	#
	# Create a symlink so that the LaTeX includes works correctly
	ln -s $(PUBLIC_CONTACT_SRC) $(COMMON_CONTACT_SRC)
	#
	# Double-run is in the event of references
	pdflatex -jobname=$(RESUME_TARGET_PUBLIC_STUB) $<
	pdflatex -jobname=$(RESUME_TARGET_PUBLIC_STUB) $<
	#
	# Remove temporary symlink
	rm -f $(COMMON_CONTACT_SRC)
	#
	# Remove messy LaTeX build ancillaries
	find . -name '$(RESUME_TARGET_PUBLIC_STUB).*' -not -name '$(RESUME_TARGET_PUBLIC)' \
		| xargs rm -f

# How to render the PDF with private contact information
$(RESUME_TARGET_PRIVATE): $(RESUME_SRC) $(PRIVATE_CONTACT_SRC)
	#
	# Create a symlink so that the LaTeX includes works correctly
	ln -s $(PRIVATE_CONTACT_SRC) $(COMMON_CONTACT_SRC)
	#
	# Double-run is in the event of references
	pdflatex -jobname=$(RESUME_TARGET_PRIVATE_STUB) $<
	pdflatex -jobname=$(RESUME_TARGET_PRIVATE_STUB) $<
	#
	# Remove temporary symlink
	rm -f $(COMMON_CONTACT_SRC)
	#
	# Remove messy LaTeX build ancillaries
	find . -name '$(RESUME_TARGET_PRIVATE_STUB).*' -not -name '$(RESUME_TARGET_PRIVATE)' \
		| xargs rm -f

# How to decrypt the private contact information .tex source
$(PRIVATE_CONTACT_SRC): $(PRIVATE_CONTACT_SRC_ENCRYPTED)
	#
	# Use gpg to prompt the user interactively to decrypt
	gpg --output $@ --decrypt $<
