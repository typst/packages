# Visual CeTZ — guide visuel de CeTZ 0.5.2
#
#   make          compile le PDF s'il n'est pas à jour
#   make force    recompile inconditionnellement
#   make watch    recompile à chaque modification
#   make clean    supprime le PDF
#
# Si typst n'est pas dans le PATH :  make TYPST=~/bin/typst

TYPST ?= typst
SRC    = main.typ
OUT    = Visual-CeTZ-0.5.2.pdf
DEPS   = $(SRC) tpl.typ $(wildcard ch*.typ)

all: $(OUT)

$(OUT): $(DEPS)
	$(TYPST) compile $(SRC) $@

# À utiliser si make se croit à jour à tort — typiquement après un
# dézippage, qui restaure des dates de fichiers antérieures à celle du PDF.
force:
	$(TYPST) compile $(SRC) $(OUT)

watch:
	$(TYPST) watch $(SRC) $(OUT)

clean:
	rm -f $(OUT)

.PHONY: all force watch clean
