##
# Compilador Alfa
#
# @file
# @version 0.1

CC := gcc
LEX := flex
BISON := bison
RM := rm -fv
CFLAGS := -std=c99 -g -Iinclude -pedantic -Wall -Wextra
BFLAGS := -d -y -v -g
NFLAGS := -f elf32
CCNASMFLAGS := -m32

BDIR := .
SDIR := src
IDIR := include
TDIR := test
ODIR := obj
NDIR := nasm

# Nota: $(patsubst PATTERN, REPLACEMENT, TEXT)
EXES := alfa.c
ALFALIB := $(ODIR)/alfalib.o
DEPEND_FILES := $(wildcard $(ODIR)/*.d)

EXES := $(patsubst %,$(SDIR)/%,$(EXES))
EOBJ := $(patsubst $(SDIR)/%.c,$(ODIR)/%.o,$(EXES))
EBIN := $(patsubst $(SDIR)/%.c,$(BDIR)/%,$(EXES))

FLEX_SOURCES := $(wildcard $(SDIR)/*.l)
FLEX_GENERATED_FILES := $(FLEX_SOURCES:.l=.yy.c)
FLEX_OBJ := $(patsubst $(SDIR)/%.c,$(ODIR)/%.o, $(FLEX_GENERATED_FILES))

BISON_SOURCES := $(wildcard $(SDIR)/*.y)
BISON_GENERATED_FILES := $(BISON_SOURCES:.y=.tab.c)
BISON_OBJ := $(patsubst $(SDIR)/%.c,$(ODIR)/%.o, $(BISON_GENERATED_FILES))
BISON_HEADERS_ORIG := $(patsubst %.c,%.h, $(BISON_GENERATED_FILES))
BISON_HEADERS := $(patsubst $(SDIR)/%,$(IDIR)/%, $(BISON_HEADERS_ORIG))

NASM_SOURCES := $(wildcard $(NDIR)/*.asm)
NASM_OBJ := $(patsubst $(NDIR)/%.asm,$(ODIR)/%.o,$(NASM_SOURCES))
NASM_BIN := $(patsubst %.nasm, %, $(NASM_SOURCES))

SRCS := $(filter-out $(EXES) $(FLEX_GENERATED_FILES) $(BISON_GENERATED_FILES), $(wildcard $(SDIR)/*.c))
SOBJ := $(patsubst $(SDIR)/%.c,$(ODIR)/%.o,$(SRCS) $(FLEX_GENERATED_FILES) $(BISON_GENERATED_FILES))

# Definicion de objetivos
all: $(EBIN)
nasm: $(NASM_BIN)

# Reglas de compilacion
$(SOBJ):$(ODIR)/%.o: $(SDIR)/%.c
	$(CC) $(CFLAGS) -o $@ -c $<

$(SDIR)/%.yy.c: $(SDIR)/%.l $(BISON_GENERATED_FILES)
	$(LEX) -o $@ $<

$(SDIR)/%.tab.c: $(SDIR)/%.y
	$(BISON) $(BFLAGS) -o $@ $<
	mv $(BISON_HEADERS_ORIG) $(IDIR)

$(EOBJ):$(ODIR)/%.o: $(SDIR)/%.c
	$(CC) $(CFLAGS) -o $@ -c $<

$(EBIN):$(BDIR)/%: $(ODIR)/%.o $(SOBJ)
	$(CC) - o $@ $^

$(NASM_OBJ):$(ODIR)/%.o: $(NDIR)/%.asm
	$(NASM) $(NFLAGS) -o $@ $<

$(NASM_BIN): $(BDIR)/%: $(ODIR)/%.o $(ALFALIB)
	$(CC) $(CNASMFLAGS) -o $@ $^ $(CFLAGS)

clean:
	@$(RM) $(SOBJ) $(EOBJ) $(EBIN)
	@$(RM) $(FLEX_GENERATED_FILES) $(BISON_GENERATED_FILES)
	@$(RM) $(BISON_HEADERS) $(BISON_HEADERS_ORIG)
	@$(RM) $(NASM_OBJ) $(NASM_BIN)


# Deteccion de dependencias automatica, v2
CFLAGS += -MMD
-include $(DEPEND_FILES)

# end
