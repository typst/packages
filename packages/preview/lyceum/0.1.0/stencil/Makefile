%.py: %.typ
	echo '#!/usr/bin/env python' > $@
	typst query $< "<self-bib-entry>" | sed '1s/^/D = /g' >> $@
	echo 'print(D[0]["value"])' >> $@

%.yml: %.py
	python $< > $@

