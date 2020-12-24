#!/bin/bash

NDIR=nasm
NFLAGS="-f elf32 -g"
CCNASMFLAGS="-m32"
tests=$(ls test/src/*.alf)
flexOutput="output.txt"

rm -f $flexOutput
touch $flexOutput
mkdir -p test/bin

for file in $tests; do
  t_title=$(basename -s .alf $file)
  echo "*************************Salida flex para $t_title*********************" >> $flexOutput
  echo "*************************Compilacion de $t_title***********************"
  ./alfa $file $NDIR/$t_title.asm $flexOutput
  echo "***********************************************************************" >> $flexOutput
  if [[ -f nasm/$t_title.asm ]]; then
    nasm $NFLAGS nasm/$t_title.asm
    gcc $CCNASMFLAGS -o test/bin/$t_title nasm/$t_title.o lib/alfalib.o 2>&-
    rm -f nasm/$t_title.o
    inputs=$(ls test/inputs/$t_title*.input 2>&-) 
    if [[ $inputs ]]; then
      for input in $inputs; do
        cat $input | ./test/bin/$t_title >> misalida.output
        output=$(basename -s .input $input)
        echo "=============================== Diferencias ==============================="
        echo "diff misalida.txt test/outputs/$output.output"
        diff misalida.output test/outputs/$output.output
        echo "==========================================================================="
        rm -f misalida.output
      done
    else
      ./test/bin/$t_title >> misalida.output
      echo "=============================== Diferencias ==============================="
      echo "diff misalida.output test/outputs/$t_title.output"
      diff misalida.output test/outputs/$t_title.output
      echo "==========================================================================="
      rm -f misalida.output
    fi
  fi
done
