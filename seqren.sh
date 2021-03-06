#! /bin/bash

#print help list
if [[ $# -lt 1 ]] #|| [[ $@ = -*h* ]] || [[ $@ = *help* ]]
then
	echo "Usage:"
	echo "seqren [OPTIONS].. [DIR]..."
	echo "Options:"
	echo "-a	All Option - files will be included in one singular count and will be put in the output directory"
	echo "-h	Help - print options"
	echo "-k	Keep Originals - Uses cp instead of mv"
	echo "-o	Output Directory - Sets output directory to next argument"
	echo "-r	Recursive - renames files in all subdirectories (no files in current directory will be renamed, but all directories in current directory will be chosen for renaming" 
	exit
fi

#read a common phrase to search files by and get file extension
echo "Rename sequential files!"
echo "You will choose the file type, then specefic files based on a common phrase."
echo "Important!! Please have a backup of your directory before running this script"
echo ""
echo "Now choose a common phrase to rename files by-"
echo "For example you might want to choose all files in current directory that have \"GOPRO\" in the name. Leave Blank to skip common phrases. "
echo -n "Enter common phrase (Press Enter to skip) : "
read commonPhrase 
echo "$commonPhrase"
echo -n "Enter file extension : "
read fileExtension
echo "$fileExtension"

# Set an output directory
# Iterate through arguments
# $# returns the number of arguments given
if [[ -f "dirs.txt" ]] #remove old dirs.txt file if it exists
then
	rm dirs.txt
fi

#initialize flags
outputArgNum=0
outputDir="."
outputDirOption=false
recursiveOption=false
allOption=false
keepOriginalsOption=false
logFile=RenameLog.txt

#process arguments
for ((i=1;i<=$#;i++));
do
	# to access the ith argument you need to use the brackets, otherwise it would compare to the loop variable i
	#echo "$i/$#"
	if [[ ${!i} = -*a*  ]]
	then
		echo "All Option - all files will be renamed according to a single count and will be put in the output directory"
		allOption=true
	elif [[ ${!i} = -*k* ]]
	then
		echo "Keep Originals Option selected"
		keepOriginalsOption=true
	elif [[ ${!i} = -*o*  ]]
	then
		outputArgNum=$((i+1))
		outputDir=${!outputArgNum/\//}

		outputDirOption=true
	elif [[ ${!i} = -*r* ]]
	then
		echo "Recursive Option selected"
		recursiveOption=true
	elif [[ "$outputArgNum" -eq "$i" ]]
	then
		if [[ -d "$outputDir" ]]
		then
			echo "Output Directory: \"$outputDir\""
		else
			mkdir "$outputDir"
			echo "Created Output Directory: \"$outputDir\""
		fi
	else
		if [[ -d "${!i}" ]]
		then
			echo $i
			echo "${!i}" >> dirs.txt
		else
			echo "${!i}: Not a directory"
		fi
	fi
done

# **Recursive Option
# Using find to to search for directories and files
# find -iname 'phrase' is not case sensitive
# -type d is for directory, use f for files
# -print0 with find prints full file name on standard output, followed by a null character  (with xorgs, you can use the -0 flag to input data in this manner)
# Linux file names can contain spaces and newline characters causing problems, print0 and -0 helps make the output usable to programs that in using file
# When further manipulation of the  
if [[ "$recursiveOption" = true ]] #include all directories/subdirectories in current directory to search for files to rename
then
	find -type d -print0  | xargs -0 -I {} echo '{}' > dirs.txt
fi

#remove forward slashes from dirs.txt and list directories to be searched for files to rename
sed -i 's/\///g' dirs.txt 
echo ""
echo "Directories being used:"
cat dirs.txt
echo ""

#get number of files to process
infile="./dirs.txt"
num_files=0
while IFS= read -r dir
do
	(( num_files+=$(ls $dir/*$commonPhrase*.$fileExtension | wc -l) ))
done < $infile
echo "Number of files to rename: $num_files"
echo "Continue? (y/N)" 
read input
if [[ $input = y* ]] || [[ $input = Y* ]]
then
	echo "Starting Rename..."
	echo ""
else
	rm dirs.txt
	echo ""
	echo "Renaming terminated."
	exit
fi
echo ""

#file renaming
total_knt=1
date >> $logFile
while IFS= read -r dir
do
	knt=1
	files="$dir/*$commonPhrase*.$fileExtension"
	for i in $files
	do
		echo $i >> files.txt
		echo -ne "\r$total_knt: " >> RenameLog.txt
		if [[ "$keepOriginalsOption" = true ]] #uses cp instead of mv
		then
			if [[ "$outputDirOption" = true ]] #an output directory has been specified
			then
				if [[ "$allOption" = true ]] #all files from multiple directories will be counted and output into a single directory
				then
					echo "cp "$i" \"$outputDir/$newPhrase$total_knt.$fileExtension\"" >> RenameLog.txt
					cp "$i" "$outputDir/$newPhrase$total_knt.$fileExtension"
				else
					if [[ -d "$outputDir/$dir" ]]
					then
						echo "Already Created: \"$outputDir/$dir\"" >> RenameLog.txt
					else
						mkdir "$outputDir/$dir"
						echo "mkdir \"$outputDir/$dir\"" >> RenameLog.txt
					fi
					echo "cp "$i" \"$outputDir/$dir/$newPhrase$knt.$fileExtension\"" >> RenameLog.txt
					cp "$i" "$outputDir/$dir/$newPhrase$knt.$fileExtension"
				fi
			else #no output directory specified
				if [[ "$allOption" = true ]]
				then
					echo "cp "$i" \"./$newPhrase$total_knt.$fileExtension\"" >> RenameLog.txt
					cp "$i" "./$newPhrase$total_knt.$fileExtension"
				else
					echo "cp "$i" \"$dir/$newPhrase$knt.$fileExtension\"" >> RenameLog.txt
					cp "$i" "$dir/$newPhrase$knt.$fileExtension"
				fi
			fi
		else #uses move instead of cp
			if [[ "$outputDirOption" = true ]] 
			then
				if [[ "$allOption" = true ]]
				then
					echo "mv "$i" \"$outputDir/$newPhrase$total_knt.$fileExtension\"" >> RenameLog.txt
					mv "$i" "$outputDir/$newPhrase$total_knt.$fileExtension"
				else
					echo "mv $i \"$outputDir/$dir/$newPhrase$knt.$fileExtension\"" >> RenameLog.txt
					mv "$i" "$outputDir/$dir/$newPhrase$knt.$fileExtension"
				fi
			else #no output directory specified
				if [[ "$allOption" = true ]]
				then
					echo "mv "$i" \"./$newPhrase$total_knt.$fileExtension\"" >> RenameLog.txt
					mv $i "./$newPhrase$total_knt.$fileExtension"
				else
					echo "mv "$i" \"$dir/$newPhrase$knt.$fileExtension\"" >> RenameLog.txt
					mv "$i" "$dir/$newPhrase$knt.$fileExtension"
				fi
			fi
		fi
		echo -ne "\r($total_knt/$num_files)"
		total_knt=$((total_knt+1))
		knt=$((knt+1))
	done
done < $infile

#finishing inputs to log file
echo -e "\nDone. \nA log of all renames are in $logFile"
date >> $logFile
echo -e "\n\n\n" >> $logFile
rm dirs.txt
exit

######SCRAP#####
#num_files=$(xargs -I {''} wc {} -l | find . -iname *$commonPhrase*.$fileExtension) 
#STR="birthday-091216-pics"
#SUBSTR=$(echo $STR | cut -d'-' -f 2 )
#echo $SUBSTR
# $# references the number of arguments given
# -lt is less than


#you could use ~+ in place of . to get full path
#echo "Searching for files that match '$commonPhrase'"

# search for specific directies
# find -type d -name '*.JG*' -print0 | xargs -0 -I {} echo '{}' > files.txt
# search for specefic files
# find -type f -name '*.JG*' -print0 | xargs -0 -I {} echo '{}' > files.txt
# Search for all directories recursively