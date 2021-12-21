#!/bin/bash

version="1.5.1"

trashpath=~/.trash/

if [ ! -d "$trashpath" ]; then
	mkdir -p $trashpath
    chmod ugo+rwx $trashpath
fi

restorelist=()
restoreall=false
purgeall=false

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

checkrights(){
	if [[ -r $1 && -w $1 ]]; then
		return 0
	else
		return 1
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
					read -p "Restore \"$var\" to its location: $originpath [y]es/[n]o/[a]ll? " confirm
				else
					read -p "Restore \"$var\" to its location: $originpath [y]es/[n]o? " confirm
				fi
			fi
			while [[ $confirm != "y" && $gconfirm == false ]]; do
				if [[ $confirm == "n" ]]; then
					echo "File not restored"
					break
				elif [[ $confirm == "a" || $restoreall == true ]]; then
					echo The following files will be restored:
					for fname in "${restorelist[@]}";do
						echo $fname
					done
					read -p "are you sure [y]es/[n]o? " confirmall 
					if [[ $confirmall == "y" ]]; then
						gconfirm=true; break
					else
						echo "Operation canceled"
						exit 1
					fi
				else
					if [[ ${#restorelist[@]} -gt 1 ]]; then
						read -p "Type \"y\" to confirm or \"n\" to cancel \"a\" to restore all: " confirm
					else
						read -p "Type \"y\" to confirm or \"n\" to cancel: " confirm
					fi
				fi
			done
			if [[ $confirm == "y" || $gconfirm == true ]];then
				checkrights $trashpath$var$originpath
				if [[ $? -eq 0 ]]; then
					cp -r -p "$trashpath$var$originpath" "$originpath"
					rm -r $trashpath$var $trashpath.$var
				else
					sudo -n true 2>/dev/null || echo "You need to be root to restore $originpath"
					sudo cp -r -p "$trashpath$var$originpath" "$originpath"
					sudo rm -r $trashpath$var $trashpath.$var
				fi

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
	for var in "${purgelist[@]}"; do
		if [[ $(ls $trashpath | wc -l) -eq 0 ]]; then
			echo "Trash can is empty."
		elif [[ -e "$trashpath.$var" ]]; then
			originpath=$(cat $trashpath.$var)
			if [[ $gconfirm == false && $purgeall == false ]]; then
				if [[ ${#restorelist[@]} -gt 1 ]]; then
					read -p "Purge \"$var\"? [y]es/[n]o/[a]ll? " confirm
				else
					read -p "Purge \"$var\"? [y]es/[n]o? " confirm
				fi
			fi
			while [[ $confirm != "y" && $gconfirm == false ]]; do
				if [[ $confirm == "n" ]]; then
					echo "File not purged"
					break
				elif [[ $confirm == "a" || $purgeall == true ]]; then
					echo "The following files will be purged:"
					for fname in "${purgelist[@]}";do
						echo $fname
					done
					read -p  "Continue [y]es/[n]o? " confirmall
					if [[ $confirmall == "y" ]]; then
						gconfirm=true; break
					else
						echo "Operation canceled"
						exit 1
					fi
				else
					if [[ ${#purgelist[@]} -gt 1 ]]; then
						read -p "Type \"y\" to confirm or \"n\" to cancel \"a\" to restore all: " confirm
					else
						read -p "Type \"y\" to confirm or \"n\" to cancel: " confirm
					fi
				fi
			done
			if [[ $confirm == "y" || $gconfirm == true ]];then
				checkrights $trashpath$var$originpath
				if [[ $? -eq 0 ]]; then
					rm -r $trashpath$var $trashpath.$var
				else
					sudo -n true 2>/dev/null || echo "You need to be root to purge $originpath"
					sudo rm -r $trashpath$var $trashpath.$var
				fi
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
		basename=$(basename $originpath)
		file=${basename%.*}

		if [[ ! -e $originpath ]]; then
			echo "$var not found!"
		else
			checkrights $originpath
			if [[ $? -eq 0 ]]; then
				mkdir -p $trashpath${file%/}
				cp -r --parents $(readlink -f $var) -p $trashpath${file%/}/
				echo "$originpath" > $trashpath.${file%/}
				rm -rf $originpath
				if [[ $verbose ]]; then
					echo "File \"$originpath\" was trashed"
				fi
			else
				sudo -n true 2>/dev/null || echo "You need to be root to trash $originpath"
				sudo mkdir -p $trashpath${file%/}
				sudo cp -r --parents $(readlink -f $var) -p $trashpath${file%/}/
				sudo echo "$originpath" > $trashpath.${file%/}
				sudo rm -rf $originpath
				if [[ $verbose ]]; then
					echo "File \"$originpath\" was trashed"
				fi
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
	echo "To report bugs visit https://github.com/tonymorello/trash/issues"
	echo
	exit 1
}

empty(){
	if [[ $(sudo -n true 2>/dev/null && echo 0 || echo 1) -eq 0 ]]; then
		read -p "Empty the trash bin? (this operation is IRREVERSIBLE) [y]es/[n]o: " confirm
		while [[ $confirm != "y" ]]; do
			if [[ $confirm == "n" ]]; then
				echo "Operation canceled."; exit 1
			else
				echo "I'm about to empty the trash can..."
				read -p "Type \"y\" to confirm or \"n\" to cancel: " confirm
			fi
		done
		if [[ $confirm == "y" ]]; then
			sudo rm -r $verbose $trashpath* 2> /dev/null
			sudo rm -r $verbose $trashpath.* 2> /dev/null
			echo "Trash bin emptied!"
		fi
	else
		echo "Please run sudo trash -e to empty the trash can."
		exit 1
	fi
}

restoreallfiles(){
	for f in $(find $trashpath -maxdepth 1 -mindepth 1 -name '.*');do
		string="${f##/*/.}"
		restorelist+=($string)
		restoreall=true
	done
	if [[ ${#restorelist[@]} -eq 0 ]]; then
		echo "Trash can is empty."
	fi
}

######################################################################

while getopts hVvelp:r:Rc: opt;
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
