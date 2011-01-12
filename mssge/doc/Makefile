# Generic make file for LaTeX: requires GNU make

TEXFILE	= $(wildcard *.tex)

.PHONY: dvi ps pdf clean

pdf:	$(TEXFILE:.tex=.pdf)
ps:	$(TEXFILE:.tex=.ps)
dvi:	$(TEXFILE:.tex=.dvi)

%.dvi: %.tex
	( \
	latex $<; \
	while grep -q "Rerun to get .* right" $(<:.tex=.log); \
	do \
		latex $<; \
	done \
	)

%.ps: %.dvi
	dvips -q $< -o $(<:.dvi=.ps)

%.pdf: %.tex
	( \
	pdflatex $<; \
	while grep -q "Rerun to get .* right" $(<:.tex=.log); \
	do \
		pdflatex $<; \
	done \
	)

clean:
	@rm -f \
	$(TEXFILE:.tex=.aux) \
	$(TEXFILE:.tex=.log) \
	$(TEXFILE:.tex=.out) \
	$(TEXFILE:.tex=.dvi) \
	$(TEXFILE:.tex=.pdf) \
	$(TEXFILE:.tex=.ps)
