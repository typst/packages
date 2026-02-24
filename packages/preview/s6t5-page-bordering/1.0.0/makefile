COMMAND := typst compile -f png --root .

OBJDIR := assets
SRCDIR := examples

SRCSUF := .typ
ADDSUF := 
TGTEXTSUF := .png
TGTSUF := $(ADDSUF)$(TGTEXTSUF)

SRCS := $(wildcard $(SRCDIR)/*$(SRCSUF))
TGTS := $(notdir $(SRCS:$(SRCSUF)=$(TGTSUF)))
TGTS := $(addprefix $(OBJDIR)/, $(TGTS))

TARGET := _TARGET

all:	$(TARGET)

$(TARGET): $(TGTS)

$(TGTS): | $(OBJDIR)
$(OBJDIR):
	mkdir -p $(OBJDIR)

$(OBJDIR)/%$(TGTSUF): $(SRCDIR)/%$(SRCSUF)
	@echo Create $@ from $^
	$(COMMAND) $^ $(@:$(TGTSUF)=$(TGTEXTSUF)) && oxipng $(@:$(TGTSUF)=$(TGTEXTSUF)) -o 4 --strip safe --alpha $(@:$(TGTSUF)=$(TGTEXTSUF))

.PHONY: clean
clean: 
	rm $(TGTS)