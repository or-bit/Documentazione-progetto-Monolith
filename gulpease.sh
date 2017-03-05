#!/bin/bash

##### Consts
# const for output auxiliary "optimized" plain text files
PDFTOTEXT=pdftotext-output

# const to set MINIMUM ASSUME-VALID length (above this value, lines will NOT be checked further and will be added to validLines array)
MINIMUM_ASSUME_VALID_LENGTH=25

# backup of default IFS
OIFS=$IFS



source ./common.config

echo Examining document named "$1"

echo "Create 'pdftotext-output' directory if not existing"
mkdir -p "$PDFTOTEXT"

# prepare file name and path
file=./"$PDFTOTEXT"/$(getFileNameWithoutExtension "$1")

echo Converting to plain text
pdftotext "$1" "$file"

# text coming from file
var=$(<"$file")

# delete all empty lines and save the remaining lines in var and in the original file
sed -i.bak '/^$/d' "$file"
var=$(<"$file")

# changing IFS to characters which mean line-break
IFS=$'\n'

# split text file in each line
lines=($var)

# array containing only "valid" lines
validLines=()

# check for each line if it could be a title and such
for line in ${lines[@]};
do
   # debug
   # echo "$line"

   ### Common patterns easy enough to detect and ommit from output

   # if the line is less then 3 chars go ahead with the loop
   lineLength=${#line}
   if [[ "$lineLength" -lt "3" ]] ; then
      # echo Skipping line which length is "$lineLength"
      continue
   fi

   # if line ends with multiple dots (possibly separated by a space)
   if [[ "$line" =~ \.(\.|[[:space:]])+$ ]] ; then
     # echo Skipping line which ends with multiple dots \("$line"\)
     continue
   fi

   # if line contains only numbers separated by '.' or '/' or '-'
   if [[ "$line" =~ ^([[:digit:]]+(\.|-|/)*)+$ ]] ; then
     # echo Skipping line which contains only numbers \("$line"\)
     continue
   fi


   # save first character and last character
   firstChar="${line:0:1}"
   lastChar="${line: -1}"

   # debug
   # echo First char is "$firstChar" and last char is "$lastChar"x

   # if first character is capitalized or is a digit the line might be a title that we need to remove from the file:
   # we conferm this by checking the last character of the line.

   # If the string is above minimum length add it without checking.
   # Else check if the last character of the line is a sentence-break separator: if it is than add the line to validLines
   if [[ "$lineLength" -gt "$MINIMUM_ASSUME_VALID_LENGTH" ]] ; then
      validLines+=("$line")
   elif [[ "$lastChar" == [?\.\!] ]]; then
      validLines+=("$line")
   fi
done

# restore original IFS
IFS="$OIFS"

# output of "optimized" doc
printf "%s\n" "${validLines[@]}" > "$file".output

# read the new "optimized" file
var=$(<"$file".output)

# changing IFS to characters which mean sentence-break
IFS=.\!?$'\n'

# split original text using IFS in to an array
sentences=($var)

# restore IFS to its original value
IFS=$OIFS

# split original text using original IFS (space, tab & newline)
words=($var)
bigWords=()

# count each character which is of class [:alpha:]
totalLetters=$(tr -d -C [:alpha:] <"$file".output | wc -c)
totalSentences=${#sentences[@]}
totalWords=${#words[@]}

# debug
#for (( i=0; i<${totalSentences}; i++ ));
#do
#  echo ${sentences[$i]}
#done
#for (( i=0; i<${totalWords}; i++ ));
#do
#  echo ${words[$i]}
#done

echo "$totalSentences"" sentences"
echo "$totalWords"" total words"
echo "$totalLetters"" total letters"

first=$((300 * $totalSentences))
second=$((10 * $totalLetters))
quotient=$((($first - $second) / $totalWords))
gulpeaseIndex=$((89 + $quotient))

echo "Gulpease Index: ""$gulpeaseIndex"
