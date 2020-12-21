#!/bin/bash

NFLAGS="-f elf32 -g"
CCNASMFLAGS="-m32"
tests=$(ls test/*.alf)

for file in $tests; do
  t_title=$(basename -s .alf $file)
  echo "*************************Salida flex para $t_title*********************" >> output.txt
  echo "*************************Compilacion de $t_title***********************"
  ./alfa $file nasm/$t_title.asm output.txt
  echo "***********************************************************************" >> output.txt
  if [[ -f nasm/$t_title.asm ]]; then
    nasm $NFLAGS nasm/$t_title.asm
    gcc $CCNASMFLAGS -o $t_title nasm/$t_title.o lib/alfalib.o
    rm -fv nasm/$t_title.o
    mkdir -p test/compilados
    mv $t_title test/compilados
    cp test/*.input test/compilados
    cp test/*.output test/compilados
  fi
done
