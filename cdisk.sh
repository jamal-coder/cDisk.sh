#!/bin/bash
clear
#=============================================================
# Author: Muhammad Ismail
# Program: CD Database
# Purpose: Keep records of Compact Disks (CDs) in a dataBase
# Start Date: 26/01/2023
# End Date:
#=============================================================

#=============================================================
# Variables Section
#=============================================================
fname=$1
title=""
artist=""
tracks=""
album=""
price=0
intake=""
selection=""
choice=""

#=============================================================
# Functions Section
#=============================================================
# input function is used for taking input of user
function input {
	read -rp "$@" intake
	echo "$intake"
}

# createRecord function is used for creating new record
function createRecord {
	while :
	do
		#Asking user for input through input function
		clear
		echo "Please enter the following information"
		echo "======================================"
		title=$(input "Enter CD's Title          : ")
		artist=$(input "Enter Artist Name         : ")
		tracks=$(input "Enter No of Tracks on CD  : ")
		while [[ $album -ne 1 && $album -ne 2 ]]; do
			album=$(input "Enter [1]Album / [2]Singl : ")
			if [[ $album -ne 1 && $album -ne 2 ]]; then
				echo "Please select 1 or 2"
			fi
 		done
 		# Assigning A or S as Albume or Single to albume variable
 		[ "$album" == 1 ] && album="A"
		[ "$album" == 2 ] && album="S"
		price=$(input "Enter CD's Price          : ")
		echo; echo
		choice=$(input "Do you want to save record [y/N] : ")
		# Ask user for depositing record in database
		# Record will not be deposited into database until
		# User select Y or Yes.
		# N or No is default here
		if [[ $choice == [Yy] || $choice == [YES] || $choice == [yes] || $choice == [Yes] ]]; then
			echo "$title:$artist:$tracks:$album:$price" >> "$fname"
		fi
		# Ask user for another record
		# Y or Yes is default to exit user should choose N or No
		choice=$(input "Do you want to enter another record [Y/n] : ")
		# if user choose N or No control will be shifted to main menu
		[[ $choice == [Nn] || $choice == [NO] || $choice == [No] || $choice == [no] ]] && break
	done	
}

# viewRecord function is used for veiwing complete record
function viewRecord {
	clear
	(
		echo "=========================================================================================="
		printf "%-30s %-25s %-10s %-6s %-12s\n" "Title" "Artist" "Tracks" "Type" "Price"
		echo "=========================================================================================="
		# if 1 or 2 is sent as argument it will be considered as search function call
		# otherwise routine display will be shown to user
		if [[ "$1" -eq 1 || "$1" -eq 2 || "$1" -eq 3 ]]; then
			grep -i "$2" "$fname" | awk -F ":" '{printf ("%-30s %-25s %-10s %-6s %-12s\n", $1, $2, $3, $4, $5)}' | sort -k2
		else
			awk -F ":" '{printf ("%-30s %-25s %-10s %-6s %-12s\n", $1, $2, $3, $4, $5)}' "$fname" | sort -k2
		fi
	) | if [[ "$1" -eq 1 || "$1" -eq 2 || "$1" -eq 3 ]]; then
			more
		else
			less
		fi

		if [[ "$1" -eq 1 ]]; then
			# Asking user for narrowing search to get exact record
			choice=$(input "Do you want to narrow search [y/N] : ")
			if [[ "$choice" == [Yy] || "$choice" == "YES" || "$choice" == "Yes" || "$choice" == "yes" ]]; then
				searchRecord
			fi
		fi

		if [[ "$1" -eq 2 ]]; then
			# Asking user for narrowing search to get exact record
			choice=$(input "Do you want to narrow search [y/N] : ")
			if [[ "$choice" == [Yy] || "$choice" == "YES" || "$choice" == "Yes" || "$choice" == "yes" ]]; then
				editRecord
			else
				editRecord "$2"
			fi
		fi

		if [[ "$1" -eq 3 ]]; then
			# Asking user for narrowing search to get exact record
			choice=$(input "Do you want to narrow search [y/N] : ")
			if [[ "$choice" == [Yy] || "$choice" == "YES" || "$choice" == "Yes" || "$choice" == "yes" ]]; then
				deleteRecord
			else
				deleteRecord "$2"
			fi
		fi
}

# searchRecord function is used for searching a record
function searchRecord {
	echo
	searchTerm=$(input "Enter Search Term : ")
	viewRecord 1 "$searchTerm"
}

# editRecord function is used to update or alter a record
function editRecord {
	# Recursively viewRecord function is called until reaching at the desired record
	# This code will be executed when first time editRecord function will be called from
	# main menu without any arguments.
	if [[ "$#" -eq 0 ]]; then
		echo
		searchTerm=$(input "Enter Search Term : ")
		viewRecord 2 "$searchTerm"
	fi
	# The following chunk of code edit the specific field of record
	# The code is enclosed in if because when the viewRecord function return code after update
	# This code is escaped if it will not be in the if block it will be again executed.
	# As first time this code will be executed when editRecord function is called with an argument
	# at last the control will be back to this funciton which will not be having any arguments
	# so this block of code will be bypassed and control will be shifted to main menu
	if [[ "$#" -eq 1 ]]; then
		title=$(grep -i "$1" "$fname" | awk -F ":" '{print $1}')
		artist=$(grep -i "$1" "$fname" | awk -F ":" '{print $2}')
		tracks=$(grep -i "$1" "$fname" | awk -F ":" '{print $3}')
		album=$(grep -i "$1" "$fname" | awk -F ":" '{print $4}')
		price=$(grep -i "$1" "$fname" | awk -F ":" '{print $5}')

		# An infinite loop is used to edit the field of records according to the requirements
		while [[ "$choice" -ne 6 || "$choice" -ne 7 ]] 
		do
			clear
			echo -e "\n\t\tRecord to Update"
			echo -e "\t\t================"
			echo -e "\t\t[1] Title  : $title"
			echo -e "\t\t[2] Artist : $artist"
			echo -e "\t\t[3] Tracks : $tracks"
			echo -e "\t\t[4] Type   : $album"
			echo -e "\t\t[5] Price  : $price"
			echo -e "\t\t[6] Update Record"
			echo -e "\t\t[7] Main Menu"
			echo
			choice=$(input "Select Field [1-7] : ")

			case  $choice in
				1) 	title=$(input "Enter Title : ");;
				2) 	artist=$(input "Enter Artist : ");;
				3) 	tracks=$(input "Enter Tracks : ");;
				4) 
					# A while loop is used to get appropriate respons of 1 or 2 from user
					# for album or single type of CD
					while [[ "$album" -ne 1 || "$album" -ne 2 ]]; do
						album=$(input "Enter Type [1]Album [2]Single : ")
						if [[ $album -eq 1 ]]; then
							album="A"
							break
						else
							album="S"
							break
						fi
					done;;
				5)	price=$(input "Enter Price : ");;
				6)
					# updating database after editing record
					grep -iv "$1" "$fname" > temp.txt
					echo "$title:$artist:$tracks:$album:$price" >> temp.txt
					mv temp.txt "$fname"
					break;;
				7) 	break;;
				*) 	echo "Invalid Selection";;
			esac
		done
	fi
}

# deleteRecord function is used for deleting a record
function deleteRecord {
	# Recursively viewRecord function is called until reaching at the desired record
	# This code will be executed when first time editRecord function will be called from
	# main menu without any arguments.
	if [[ "$#" -eq 0 ]]; then
		echo
		searchTerm=$(input "Enter Search Term : ")
		viewRecord 3 "$searchTerm"
	fi

	if [[ "$#" -eq 1 ]]; then
		while [[ "$choice" == [Yy] || "$choice" == [Nn] || "$choice" == [Yy][Ee][Ss] || "$choice" == [Nn][Oo] ]]
		do	
			choice=$(input "Do you want to delete record [Y/N] ")

			if [[ "$choice" == [Yy] || "$choice" == [Yy][Ee][Ss] ]]; then
				grep -iv "$1" "$fname" > temp.txt
				rm "$fname"
				mv temp.txt "$fname"
				break
			else
				break
			fi 
		done
	fi
}

#=============================================================
# Main Section
#=============================================================
# Program checks whether file name is given as argument or not
# if file name is given program executes or error message is displayed
if [ $# -eq 1 ]; then
	if [ -e /usr/bin/banner ]; then
		banner "CD DataBase"
		banner "Ver 1.00"
	else
		echo "CD DataBase"
		echo "Version 1.00"
	fi
	sleep 3
	# if file not exist then create a blank file
	if [ ! -f "$fname" ]; then
		touch "$fname"
	fi
	# infinte loop to continue program until the exit selected by user
	while :
	do
		# Main Menu
		# Main Menu gives various options to the user
		clear
		echo -e "\t\tMain Menu"
		echo -e "\t\t========="
		echo
		echo -e "\t[1] Create Record"
		# if file is new the following function of program will not be available
		if [ -s "$fname" ]; then
			echo -e "\t[2] View Records"
			echo -e "\t[3] Search Record"
			echo -e "\t[4] Edit Record"
			echo -e "\t[5] Delete Record(s)"
			echo -e "\t[6] Exit DataBase\n"
			read -rp "Your selection [1-6] : " selection
		fi
		# if new file and no entries only this portion will be avialable
		if [ ! -s "$fname" ]; then
			echo -e "\t[2] Exit DataBase\n"
			read -rp "Your selection [1-2] : " selection
		fi

		# case statement is used to go to appropriat function based on the selection of user
		if [ -s "$fname" ]; then
			case $selection in
				1)  	createRecord;; 
				2) 		viewRecord;;
				3) 		searchRecord;;
				4) 		editRecord;;
				5) 		deleteRecord;;
				6) 		exit;;
				*) 		echo "Please select [1-6] only"
						input "Press Enter to proceed... ";;
			esac
		else
			case $selection in
				1)  createRecord;; 
				2) 	exit;;
				*) 	echo "Please select [1-2] only"
					input "Press Enter to proceed... ";;
			esac
		fi
	done
else
	clear
	echo -e "\n\n\t\tUsage: $(basename "$0") <FileName> - Provide a file name as argument\n\n"
fi
