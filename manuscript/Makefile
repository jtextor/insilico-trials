all : ms.pdf reviewer-response.pdf response-letter.pdf

ms.pdf : ms.tex ms.bib
	latexmk -use-make -xelatex $<

reviewer-response.pdf : reviewer-response.tex ms.aux ms.bib
	latexmk -use-make -xelatex $<

response-letter.pdf : response-letter.tex ms.aux ms.bib
	latexmk -use-make -xelatex $<
