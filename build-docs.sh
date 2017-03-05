#!/bin/bash

# import general info (e.g. input docs directory)
source common.config

# index file used to build docs
indexfile=

# output directory
OUTPUT=

# print help
if [ "$1" = "--help" ] ; then
  echo "
    SYNOPSIS
    build-docs.sh {e, external | i, internal | a, all} [OPTION]

    DESCRIPTION
    This script allows you (and Travis) to build all internal and/or external documentation of the Monolith project. This script makes use of 'build-latex.sh' script and of 'common.config' file.

    OPTION
    -c \"path/to/other/index/file\" : Specify a custom index file.

    EXAMPLES
    build-internal-docs.sh i -> PDF: ./_travis-build/Interni/NormeDiProgetto.pdf, ./_travis-build/Interni/Verbale***.pdf
	build-internal-docs.sh i -c \"only-verbale.config\" -> PDF: ./_travis-build/Interni/Verbale***.pdf"
  exit 0
fi

function setupInternal {
	indexfile="internal-docs.config"
	OUTPUT=Interni
}

function setupExternal {
	indexfile="external-docs.config"
	OUTPUT=Esterni
}

function setupNonDefaultIndex {
	# read from non-default index file
	if [ "$2" = "-c" ] ; then
		indexfile=$3
	fi
}

function error {
	echo "Invalid arguments. Please check how to use this script running it with '--help'"
}

function setupOutput {
	outputFolder=$PDFROOT/$OUTPUT
	if [ ! -d "$outputFolder" ]; then
		mkdir -p "$outputFolder"
	fi
}

function buildInternal {
	setupInternal
	setupNonDefaultIndex
	setupOutput
	# build LaTeX specified in file
	buildFiles $indexfile $outputFolder
}

function buildExternal {
	setupExternal
	setupNonDefaultIndex
	setupOutput
	# build LaTeX specified in file
	buildFiles $indexfile $outputFolder
}



# external or internal or both
if [ "$1" = "i" -o "$1" = "internal" ] ; then
	buildInternal
elif [ "$1" = "e" -o "$1" = "external" ] ; then
	buildExternal
elif [ "$1" = "a" -o "$1" = "all" ] ; then
	buildInternal
	buildExternal
else
	error
	exit 1
fi
