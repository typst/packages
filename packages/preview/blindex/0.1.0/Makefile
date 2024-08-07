tmp-01.png: tmp-01.pdf
	pdftoppm tmp-01.pdf tmp-01 -png
	magick montage tmp-01-*png -geometry +2+2 -tile 4x1 tmp-01.png
	rm -v tmp-01-*png

