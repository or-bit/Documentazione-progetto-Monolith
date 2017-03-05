#!/bin/bash

# print help
if [ "$1" = "--help" ] ; then
  echo "
    SYNOPSIS
    zip-docs.sh [OPTION]

    DESCRIPTION
    This script allows you (and Travis) to zip the compiled LaTeX documents of the Monolith project. Before using this script, execute script 'build-latex.sh'.

    OPTION
    -r, --release : Profile for release export.
    -rc, --release-clean : As -r or --release. After zip is built this option deletes the directory used to zip."
  exit 0
fi

source common.config

TOZIP=$PDFROOT
CLEAN=false

# delete all files except pdfs
find "$PDFROOT" -type f ! -name '*.pdf' -delete

# if 'release' profile selected, copy docs to 'release' location
if [ "$1" = "-r" -o "$1" = "--release" -o "$1" = "-rc" -o "$1" = "--release-clean" ] ; then
	set -x
	rm -r "$RELEASE"
	mkdir -p "$RELEASE"/Interni
	mkdir -p "$RELEASE"/Esterni
	find "$PDFROOT"/Interni -name "*.pdf" -exec cp {} "$RELEASE"/Interni \;
	find "$PDFROOT"/Esterni -name "*.pdf" -exec cp {} "$RELEASE"/Esterni \;
	mkdir "$RELEASE"/Esterni/Verbali
	mkdir "$RELEASE"/Interni/Verbali
	find "$RELEASE" -name "Verbale E*" -exec mv {} "$RELEASE"/Esterni/Verbali/ \;
	find "$RELEASE" -name "Verbale I*" -exec mv {} "$RELEASE"/Interni/Verbali/ \;	
	TOZIP=$RELEASE
	set +x
fi

if [ "$1" = "-rc" -o "$1" = "--release-clean" ] ; then
	CLEAN=true
fi

if [ -e Documentazione.zip ] ; then
	rm Documentazione.zip
fi
	
# zip output directory for Travis deployment
zip -r Documentazione.zip "$TOZIP"

if [ "$CLEAN" = true ] ; then
	echo "Cleaning..."
	rm -r "$TOZIP"
fi