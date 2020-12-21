##
# Compilador alfa
#
# @file Makefile
# @version 0.1
EDIR := .
SDIR := src
IDIR := include
TDIR := test
ODIR := obj
NDIR := nasm
FDIR := flex
BDIR := bison
LDIR := lib

NAME := alfa
C_NAMES  := y.tab.c lex.yy.c simbolo.c tablaHash.c tablaSimbolos.c generacion.c alfa.c

CC := gcc
CFLAGS := -std=c99 -g -Iinclude -pedantic -Wall -Wextra
BFLAGS := -d -y -v -Wno-other 
NFLAGS := -f elf32 -g
CCNASMFLAGS := -m32

SFILES := c
OFILES := o
SOURCES := $(foreach sname, $(C_NAMES), $(SDIR)/$(sname))
OBJECTS := $(patsubst $(SDIR)/%.$(SFILES), $(ODIR)/%.$(OFILES), $(SOURCES))

EXE := $(EDIR)/$(NAME)

.PHONY: all exe test clean

all: exe

###############################################################################
#   COMPILADOR                                                                 #
###############################################################################
exe: $(EXE)

$(EXE): $(OBJECTS)
	$(CC) $^ -o $@

$(ODIR)/%$(OFILES): $(SDIR)/%$(SFILES)
	@mkdir -p obj
	$(CC) $(CFLAGS) -c $< -o $@

$(SDIR)/lex.yy.c: $(FDIR)/alfa.l $(SDIR)/y.tab.c
	flex -o $@ $<

$(SDIR)/y.tab.c: $(BDIR)/alfa.y
	bison $(BFLAGS) --defines=$(IDIR)/y.tab.h -o $@ $<

###############################################################################
#   TEST                                                                      #
###############################################################################
test:
	@mkdir -p asm
	for file in $(ls $(TDIR)/*.alf); do
		t_title=$(basename -s .alf "$file")
		./alfa "$file" $(NDIR)/"$t_title.asm"
		nasm $(NFLAGS) $(NDIR)/"$t_title.asm"
		$(CC) -o $(t_title) $(CCNASMFLAGS) "$t_title.$OFILES" lib/alfalib.o
		rm -fv "$t_title.$OFILES"
		mv $(t_title) test/compilados
		cp test/*.input test/compilados
		cp test/*.output test/compilados
	done

clean:
	rm -fv $(OBJECTS) $(EXE) $(DEPEND_FILES)
	rm -fv $(SDIR)/lex.yy.c $(SDIR)/y.tab.c $(IDIR)/y.tab.h $(SDIR)/y.output
	rm -rfv $(NDIR) $(ODIR) $(TDIR)/compilados

# Deteccion de dependencias automatica
CFLAGS += -MMD
DEPEND_FILES := $(wildcard $(ODIR)/*.d)
-include $(DEPEND_FILES)

# end
