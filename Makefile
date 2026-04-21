TEX_FILES := $(wildcard tikz/*.tex)
SVG_FILES := $(TEX_FILES:.tex=.svg)

build-svgs: $(SVG_FILES)
.PHONEY: build-svgs

tikz/%.dvi: tikz/%.tex
	latex --output-directory tikz $^

tikz/%.svg: tikz/%.dvi
	dvisvgm --no-fonts -o assets/%f.svg $^

clean:
	rm -f tikz/*.log tikz/*.aux tikz/*.dvi
.PHONEY: clean

