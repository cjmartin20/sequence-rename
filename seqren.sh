#! /bin/bash
# $# references the number of arguments given
# -lt is less than

echo "Now choose a common phrase to rename files by-"
echo "For example you might want to choose all files in current directory that have \"GOPRO\" in the name. Leave Blank to skip common phrases. "
echo "Enter common phrase (Press Enter to skip) :"
#read commonPhrase 
#sed -i 's/ /\\ /g' files.txt
#you could use ~+ in place of . to get full path
echo "Searching for files that match '$commonPhrase'"
echo "..."








# **Recursive Option
# Using find to to search for directories and files
# find -iname 'phrase' is not case sensitive
# -type d is for directory, use f for files
# -print0 with find prints full file name on standard output, followed by a null character  (with xorgs, you can use the -0 flag to input data in this manner)
# Linux file names can contain spaces and newline characters causing problems, print0 and -0 helps make the output usable to programs that in using file
# When further manipulation of the  

# search for specific directies
# find -type d -name '*.JG*' -print0 | xargs -0 -I {} echo '{}' > files.txt
# search for specefic files
# find -type f -name '*.JG*' -print0 | xargs -0 -I {} echo '{}' > files.txt
# Search for all directories recursively


# Set an output directory
# Iterate through arguments
# $# returns the number of arguments given
outputArgNum=0
outputDir="."
outputDirOption=no
for ((i=1;i<=$#;i++));
do
	# to access the ith argument you need to use the brackets, otherwise it would compare to the loop variable i
	if [[ ${!i} = -*o*  ]]
	then
		if [ $outputArgNum!=$i ] && [ -d "${!i}" ]
		then
			echo "${!i} >> dirs.txt"
		fi
		outputArgNum=$((i+1))
		outputDir=${!outputArgNum}
		outputDirFlag=yes
		ls "$outputDir"
	fi
done


echo "Enter file extension : "
read fileExtension
echo "Enter new phrase (Press enter to skip) :"
read newPhrase

exit



if [[ $outputDirOption="yes" ]]
then
	# check for existence of provided output directory- if not, create one
	if [[ -d "$outputDir" ]]
	then
		echo "Output Direcotory: \"$outputDir\""
	else
		mkdir "$outputDir"
		echo "Created Output Directory: \"$outputDir\""
	fi
fi







recursiveOption=no
if [[ $@ = -*r* ]]
then
	recursiveOption=yes
	find -type d -print0 | xargs -0 -I {} echo '{}' > dirs.txt
	infile="./dirs.txt"
	while IFS= read -r line
	do
		ls -l "$line"
	done < $infile
fi

if [[ $@ = -*c* ]]
then
	echo "Using current directory option"
fi
if [[ $# -lt 1 ]]
then
	echo "Usage:"
	echo "./seqren.sh [OPTIONS].. [DIR]..."
	echo "For current directory, \"./seqren.sh .\"" 
	echo "Options:"
	echo "	-c	Moves all files to current directory"
	echo "	-r	Recursively renames files in subdirectories"
	exit
fi
echo "Rename sequential files!"
echo "You will choose the file type, then specefic files based on a common phrase."
echo "Important!! Please have a backup of your directory before running this script"
echo ""
echo ""
echo "You have chosen the following directories : "
echo "$@"
echo ""
echo "Pictures and Videos are common file types that are saved sequentially:"
echo "Examples: JPG, JPEG, HEIC, TIFF, RAW, PNG, MP4, MOV, WMV"
echo "Enter file extension : "
read fileExtension
echo "Enter new phrase (Press enter to skip) :"
read newPhrase
echo ""
echo ""
echo "Now you can choose a new phrase to rename files by"
echo "The files will be named such as \"phrase1.JPG, phrase2.JPG\". Leaving blank will will result in files simply being named as numbers. "
echo "Enter new phrase (Press enter to skip) :"
read newPhrase
echo ""
echo "List files being renamed? (y/N)"
#the $@ references all arguments $1 would reference the first argument 
read input
if [[ $input = y* ]]
then
	echo "Files being renamed : "
	ls -v $@/*$commonPhrase*.$fileExtension
fi
#num_files=$(ls -lv $@/*$commonPhrase*.$fileExtension | wc -l) 
#ls -v is natural sort, if -v isn't used it would order 1.JPG, 2.JPG, 10.JPG
# as 10.JPG, 1.JPG, 2.JPG which would mess up the correct order of files
echo "$num_files files that match \"$commonPhrase.$fileExtension\""
echo "This action cannot be reversed, please ensure your new naming scheme is correct"
echo "Scheme : $newPhrase<file numbers>.$fileExtension"
echo "Continue? (y/N)"
read input
#rfiles="find . -iname *$commonPhrase*.$fileExtension | xargs -I {''} echo {}"
num_files=$(xargs -I {''} wc {} -l | find . -iname *$commonPhrase*.$fileExtension) 

for k in $rfiles
do
	ls -l $k
done
exit
# there's a differece between [[ and [ 
# apperently the first is better and the second can only hold 4 arguments
if [[ $input = y* ]]
then
	#iterate through directories
	for k in $@ 
	do
		knt=1
		files="$k/*$commonPhrase*.$fileExtension"
		for i in $files
		do
			echo "Processing file $i"
			echo "Renaming $i to $newPhrase$knt.$fileExtension"
			mv $i "$k/$newPhrase$knt.$fileExtension"
			echo "($knt/$num_files) Completed"
			knt=$((knt+1))
		done
	done
	echo ""
	echo "Renaming Complete."
else
	echo ""
	echo "Renaming terminated."
fi

#STR="birthday-091216-pics"
#SUBSTR=$(echo $STR | cut -d'-' -f 2 )
#echo $SUBSTR
#for ((i=0; i<=num_files; i++));
#do 
#	echo "One for file number $i"
#done

