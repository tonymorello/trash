#!/bin/bash

trashpath=~/.trash/

if [ ! -d "$trashpath" ]; then
	mkdir -p $trashpath
    chmod ugo+rwx $trashpath
fi

restorelist=()
version="1.4.2"

list(){
	if [[ $(ls $trashpath | wc -l) -gt 0 ]]; then
		echo
		echo "Content of trash can:"
		echo "---------------------"
		ls -x1 $trashpath
		echo
		echo "TOTAL FILES: $(ls $trashpath | wc -l)"
		echo
	else
		echo "Trash can is empty."
	fi
}

restore(){
	gconfirm=false
	for var in "${restorelist[@]}"; do
		if [[ $(ls $trashpath | wc -l) -eq 0 ]]; then
			echo "Trash can is empty."
		elif [[ -e "$trashpath.$var" ]]; then
			originpath=$(cat $trashpath.$var)
			if [[ $gconfirm == false && $restoreall == false ]]; then
				if [[ ${#restorelist[@]} -gt 1 ]]; then
					echo Restore \"$var\" to its location: $originpath [yes/no/all]?
				else
					echo Restore \"$var\" to its location: $originpath [yes/no]?
				fi
				read confirm
			fi
			while [[ $confirm != "yes" && $gconfirm == false ]]; do
				if [[ $confirm == "no" ]]; then
					echo "File not restored"
					break
				elif [[ $confirm == "all" || $restoreall == true ]]; then
					echo The following files will be restored:
					for fname in "${restorelist[@]}";do
						echo $fname
					done
					echo are you sure? [yes/no]
					read confirmall
					if [[ $confirmall == "yes" ]]; then
						gconfirm=true; break
					else
						echo "Operation canceled"
						exit 1
					fi
				else
					if [[ ${#restorelist[@]} -gt 1 ]]; then
						echo "Type \"yes\" to confirm or \"no\" to cancel \"all\" to restore all."
					else
						echo "Type \"yes\" to confirm or \"no\" to cancel."
					fi
					read confirm
				fi
			done
			if [[ $confirm == "yes" || $gconfirm == true ]];then
				sudo cp -r -p "$trashpath$var$originpath" "$originpath"
				sudo rm -r $trashpath$var $trashpath.$var
			fi
			if [[ $verbose ]]; then
				echo "Restored $originpath"
			fi
		else
			echo "File $var is not present in trash can."
		fi
	done
}

purge(){
	gconfirm=false
	purgeall=false
	for var in "${purgelist[@]}"; do
		if [[ $(ls $trashpath | wc -l) -eq 0 ]]; then
			echo "Trash can is empty."
		elif [[ -e "$trashpath.$var" ]]; then
			originpath=$(cat $trashpath.$var)
			if [[ $gconfirm == false && $purgeall == false ]]; then
				if [[ ${#restorelist[@]} -gt 1 ]]; then
					sudo echo "Purge \"$var\"? [yes/no/all]?"
				else
					sudo echo "Purge \"$var\"? [yes/no]?"
				fi
				read confirm
			fi
			while [[ $confirm != "yes" && $gconfirm == false ]]; do
				if [[ $confirm == "no" ]]; then
					echo "File not purged"
					break
				elif [[ $confirm == "all" || $purgeall == true ]]; then
					echo "The following files will be purged:"
					for fname in "${purgelist[@]}";do
						echo $fname
					done
					echo "are you sure? [yes/no]"
					read confirmall
					if [[ $confirmall == "yes" ]]; then
						gconfirm=true; break
					else
						echo "Operation canceled"
						exit 1
					fi
				else
					if [[ ${#purgelist[@]} -gt 1 ]]; then
						echo "Type \"yes\" to confirm or \"no\" to cancel \"all\" to restore all."
					else
						echo "Type \"yes\" to confirm or \"no\" to cancel."
					fi
					read confirm
				fi
			done
			if [[ $confirm == "yes" || $gconfirm == true ]];then
				sudo rm -r $trashpath$var $trashpath.$var
			fi
			if [[ $verbose ]]; then
				echo "File $var was purged."
			fi
		else
			echo "File $var is not present in trash can."
		fi
	done
}

trash(){
	for var in "$@"
	do
		originpath=$(readlink -f $var)
		if [[ ! -e $originpath ]]; then
			echo "$var not found!"
		else
			sudo mkdir -p $trashpath${var%/}
			sudo cp -r --parents $(readlink -f $var) -p $trashpath${var%/}/
			sudo echo "$originpath" > $trashpath.${var%/}
			sudo rm -r $originpath
			if [[ $verbose ]]; then
				echo "File \"$originpath\" was trashed"
			fi
		fi
	done
}

help(){
	echo "trash v.$version"
	echo
	echo "Usage:  trash <files...>"
	echo "        trash [options]"
	echo "        trash [options] <file>"
	echo
	echo "  -h	Show this help screen"
	echo "  -V	Show current version"
	echo " "
	echo "  -e	Empty trash can"
	echo "  -p	Purge specific files from trash can"
	echo "  -l	List files in trash can"
	echo "  -r	Restore specific file from trash can"
	echo "  -R	Restore ALL files from trash can"
	echo
	echo "Please report bugs on https://aur.archlinux.org/packages/trash/"
	echo
	exit 1
}

empty(){
	echo "Empty the trash bin? (this operation is IRREVERSIBLE) [yes/no]"
	read confirm
	while [[ $confirm != "yes" ]]; do
		if [[ $confirm == "no" ]]; then
			echo "Operation canceled."; break
		else
			echo "I'm about to empty the trash can..."
			echo "Type \"yes\" to confirm or \"no\" to cancel"
			read confirm
		fi
	done
	if [[ $confirm == "yes" ]]; then
		sudo rm -r $verbose $trashpath* 2> /dev/null
		sudo rm -r $verbose $trashpath.* 2> /dev/null
		echo "Trash bin emptied!"
	fi
}

restoreallfiles(){
	for f in $(find $trashpath -maxdepth 1 -name '.*');do
		string="${f##/*/.}"
		restorelist+=($string)
		restoreall=true
	done
	if [[ ${#restorelist[@]} -eq 0 ]]; then
		echo "Trash can is empty."
	fi
}

######################################################################

while getopts hVvelp:r:R opt;
do
	case $opt in
		"h")	help
		;;
		"V")	echo $version
		;;
		"v") 	verbose="-v"
		;;
		"e") 	empty
				exit 1
		;;
		"p")	purgelist+=($OPTARG)
		;;
		"l")	list
				exit 1
		;;
		"r")	restorelist+=($OPTARG)
		;;
		"R")	restoreallfiles
		;;
		esac
done

if [[ ${#restorelist[@]} -gt 0 || ${#purgelist[@]} -gt 0 ]]; then
	if [[ ${#restorelist[@]} -gt 0 ]]; then
		restore
	fi
	if [[ ${#purgelist[@]} -gt 0 ]]; then
		purge
	fi
	exit 1
else
	shift $((OPTIND-1))
	trash $@
	exit 1
fi
