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
C_NAMES  := lex.yy.c y.tab.c simbolo.c tablaHash.c tablaSimbolos.c generacion.c main.c

CC := gcc
CFLAGS := -std=c99 -g -Iinclude -pedantic -Wall -Wextra -D_POSIX_SOURCE
BFLAGS := -d -y -v
NFLAGS := -f elf32 -g
CCNASMFLAGS := -m32

SFILES := c
OFILES := o
SOURCES := $(foreach sname, $(C_NAMES), $(SDIR)/$(sname))
OBJECTS := $(patsubst $(SDIR)/%.$(SFILES), $(ODIR)/%.$(OFILES), $(SOURCES))

# TFILES := alf
# TSOURCES := $(wildcard $(TDIR)/*.alf)

EXE := $(EDIR)/$(NAME)

.PHONY: all exe clean

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
	bison --defines=$(IDIR)/y.tab.h -o $@ $(BFLAGS) $<

###############################################################################
#   TEST                                                                      #
###############################################################################
# test:
# 	@mkdir -p asm
# 	for file in $(ls $(TDIR)/*.alf); do
# 		t_title=$(basename -s .alf "$file")
# 		./alfa "$file" $(NDIR)/"$t_title.asm"
# 		nasm $(NFLAGS) $(NDIR)/"$t_title.asm"
# 		$(CC) -o $(t_title) $(CCNASMFLAGS) "$t_title.$OFILES"
# 		mv "$t_title.$OFILES" obj
# 		# Si esto funciona y hay tiempo podría automatizarse las entradas y salidas
# 	done

clean:
	rm -fv $(OBJECTS) $(EXE) $(DEPEND_FILES)
	rm -fv $(SDIR)/lex.yy.c $(SDIR)/y.tab.c $(IDIR)/y.tab.h $(SDIR)/y.output
	rm -fv $(NOBJECTS) $(NSOURCES)
	rm -dfv $(NDIR) $(ODIR)

# Deteccion de dependencias automatica, v2
CFLAGS += -MMD
DEPEND_FILES := $(wildcard $(ODIR)/*.d)
-include $(DEPEND_FILES)

# end
