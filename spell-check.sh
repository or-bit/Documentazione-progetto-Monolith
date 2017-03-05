#!/bin/bash

if [ "$1" = "--help" ] ; then
  echo "
    SYNOPSIS
    spell-check.sh input

    DESCRIPTION
    This script allows you (and Travis) to spellcheck a LaTeX document, correctly ignoring mathematical formulae.
	The output of this script is a sorted list of words that ***might*** be mispelled. Sometimes there may be false-positives!
	Generated reports can be found in 'spell-check-temp' directory.
	
    ARGUMENTS
    input) Input LaTeX document path: Path of the *.tex document to analyze

    EXAMPLES
    spell-check.sh LaTex/documenti/Glossario/Glossario.tex -> output in terminal the list of " 
  exit 0
fi

if [ -z "$1" ] ; then
	echo "Error: arguments missing"
	exit 11
fi

# import general info
source common.config

texFileName="$(getFileName "$1")"
# strip extensions
texName="$(getFileNameWithoutExtension "$1")"
# last directory name
directoryName="$(getLastDirectoryName "$1")"

mkdir -p "$SPELLCHECK_DIR"/"$directoryName"

output="$SPELLCHECK_DIR"/"$directoryName"/"$texName".spellchecked

cat "$1" | aspell --lang=en --personal=./.aspell.en.pws -t list | aspell --lang=it --personal=./.aspell.it.pws -t list | sort -u > "$output"
