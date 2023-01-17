RESUME_FILENAME = eduplant-resume

$(RESUME_FILENAME).pdf: $(RESUME_FILENAME).tex
	# Double-run is in the event of references
	pdflatex $(RESUME_FILENAME).tex
	pdflatex $(RESUME_FILENAME).tex

.PHONY: all
all: resume

.PHONY: resume
resume: $(RESUME_FILENAME).pdf

.PHONY: clean
clean:
	find .	-name '$(RESUME_FILENAME).*'\
		-not -name '$(RESUME_FILENAME).tex'\
		-not -name '$(RESUME_FILENAME).pdf'\
	| xargs rm --verbose
