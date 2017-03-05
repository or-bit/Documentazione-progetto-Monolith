#!/bin/bash

if [ "$1" = "--help" ] ; then
  echo "
	SYNOPSIS
	create-reports.sh

	DESCRIPTION
	This script allows you (and Travis) to build an HTML file that contains basic statistics of the specified input."
  exit 0
fi

# import general info (e.g. input docs directory)
source common.config

#pdfFileName="$(getFileName "$1")"
# strip extensions
#docName="$(getFileNameWithoutExtension "$1")"
# last directory name
#directoryName="$(getLastDirectoryName "$1")"

#pdftotext "$1" > "$2"/"$docName".report

##### CONSTS
TITLE="Report documentazione: $docName"
RIGHT_NOW=$(date +"%x %r %Z")
TIME_STAMP="Updated on $RIGHT_NOW"
TRESHOLD=5


##### FUNCTIONS
function add_style {
	echo "div { white-space: pre-wrap; }"
}

function getTexFileStats {
	echo "$(texcount -utf8 $1)" 
}

function analyze_doc {
	echo "<div class=\"specific-doc\">"
	fileName="$(getFileNameWithoutExtension "$1")"
	echo "<h3>""$fileName""</h3>"
	echo "<div class=\"notes\">"
	#debug
	#set -x
	#echo "$(getLastDirectoryName "$1")"
	#set +x
	matchingTexFile="$DOCUMENTSROOT"/"$(getLastDirectoryName "$1")"/"$fileName".tex
	echo "$(getTexFileStats "$matchingTexFile")"
	echo "</div>"
	echo "List of unrecognized words in English and Italian:"
	echo "<ul>"
	while read line; do
		echo "<li>""$line""</li>"
	done < "$1"
	echo "</ul>"
	echo "</div>"
}

function create_paragraph {
	echo "<div class=\"global-doc\">"
	dir="$1"
	echo "<h2>""$(getFileName "$dir")""</h2>"
	find "$dir" -maxdepth 1 -mindepth 1 -type f -exec "$analyze_doc" {} /;
}

function scan_spellcheck_folder {
	# loop over all subdirectories of spellcheck main directory
	
	find . -type f -iname "*.txt" -print0 | while IFS= read -r -d $'\0' line; do
		echo "$line"
		ls -l "$line"    
	done
	
	
	for dir in $(find "$SPELLCHECK_DIR" -maxdepth 1 -mindepth 1 -type d | sort) ; do
		echo "<div class=\"global-doc\">"
		echo "<h2>""$(getFileName $dir)""</h2>"
		for file in $(find "$dir" -maxdepth 1 -mindepth 1 -type f | sort) ; do
			set -x
			echo "$(analyze_doc "$file")"
			set +x
		done
		echo "</div>"
	done
}

function scan_documents_directory {
	for d in "$(find "$DOCUMENTSROOT" -maxdepth 1 -mindepth 1 -type d | sort)" ; do 
		
		echo "$d"
		
	done
}

function create_page {
	cat <<- EOF > test.html
	<html>
		<head>
			<title>$TITLE</title>
			<style>$(add_style)</style>
		</head>
		<body>
			<h1>$TITLE</h1>
			<p>$TIME_STAMP</p>
			$(scan_spellcheck_folder)
		</body>
	</html>
	EOF
}

$(create_page)

#echo "$(scan_spellcheck_folder)"

