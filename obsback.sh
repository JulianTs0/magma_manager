#!/bin/bash

error_catch() {
        exit_code=$?
        case $exit_code in
                1) echo 'VERIFY THAT THE "databackup.sh" FIELDS ARE COMPLETE AND CORRECT';;
                126) echo "YOU MUST RUN THIS SCRIPT WITH SUDO PRIVILEGES";;
                127) echo "A COMMAND ARE NOT FOUND, TRY TO REDOWNLOAD THE SCRIPT" ;;
                *) echo "AN UNPLANNED ERROR HAS OCURRED";;
        esac
        echo -e "EXIT CODE:$exit_code"
        exit $exit_code
}

trap 'error_catch' ERR

self_path=`find $PWD -name databackup.sh | head -1`

if test -z $self_path
then
	echo -e "databackup.sh NOT FOUND\nMUST PLACE A "'"databackup.sh"'" FILE IN SOME DIRECTORY THAT IS LOWER IN THE DIRECTORY TREE\nRETURNING TO TERMINAL"
	read -p "PRESS A KEY " n
	exit
fi

while true
do
	data_backup=()
	for i in `bash $self_path`
	do	
		data_backup+=("$i")
	done

	if test ${#data_backup[@]} -ne 8
	then
		echo -e "THIS IS PROBABLY YOUR FIRST TIME YOU HAVE EXECUTING THIS SCRIPT\nVERIFY THAT THE "'databackup.sh'" FIELDS ARE COMPLETE\nRETURNING TO TERMINAL"
		read -p "PRESS A KEY " n
		exit	
	fi

	echo -e "\n1- SEE PROCESS DATA\n2- MODIFY PROCESS DATA\n3- MAKE/UPDATE A BACKUP\nE- EXIT"
	read opt

	case $opt in
		1)
		
		echo -e "-----DATA FORM BACKUP-----\nOBSIDIAN PROCESS PATH:${data_backup[0]}\nBACKUP ID:${data_backup[1]}\nBACKUP NAME:${data_backup[2]}\nLOCAL VAULT PATH:${data_backup[3]}\nBACKUP VAULT PATH:${data_backup[4]}\nBACKUP PROCESS DATA PATH:$self_path\n--------------------------"
		read -p "PRESS A KEY " n

		clear 
		
		;;
		2)
		
		clear
 
		while true
		do
			change_vars=(`head -8 $self_path`)
			echo_command=`tail -1 $self_path`
		

			echo -e "\n1- OBSIDIAN PROCESS PATH \n2- BACKUP ID \n3- BACKUP NAME \n4- LOCAL VAULT PATH\n5- BACKUP VAULT PATH\nS- BACK"
			read opt2

			case $opt2 in
				1) 

				echo -e "OLD OBSIDIAN PROCESS PATH: ${data_backup[0]}\nINSERT THE NEW OBSIDIAN PROCESS PATH"
				read new_var
				change_vars[0]='obs_path="'$new_var'"'

				;;
				2) 
				
				echo -e "OLD BACKUP ID: ${data_backup[1]}\nINSERT THE NEW BACKUP ID"
				read new_var
				change_vars[1]='back_id="'$new_var'"'
				
				;;
				3) 

				echo -e "OLD BACKUP NAME: ${data_backup[2]}\nINSERT THE NEW BACKUP NAME"	
				read new_var
				change_vars[2]='back_name="'$new_var'"'		
				
				;;	
				4) 
	
				echo -e "OLD LOCAL VAULT PATH: ${data_backup[3]}\nINSERT THE NEW LOCAL VAULT PATH"	
				read new_var
				change_vars[3]='local_vault_child="'$new_var'"'			
				
				;;
				5) 
				
				echo -e "OLD BACKUP VAULT PATH: ${data_backup[4]}\nINSERT THE NEW BACKUP VAULT PATH"	
				read new_var
				change_vars[4]='back_path_child="'$new_var'"'			
				
				;;
				0 | S | s) 
				
				read -p "RETURNING TO THE MENU" n
				
				clear
				break
				
				;;
				*) 
				
				read -p "INSERT A VALID OPTION" n
				new_var=""
				
				;;
			esac

			if !(test -z $new_var)
			then
				echo -e "\nLOADING NEW DATA..."

				true > $self_path
				for i in ${change_vars[@]}
				do
					echo $i >> $self_path
				done
				echo $echo_command >> $self_path
				
				read -p "DONE" n

				clear
				
			fi
		done	

		;;
		3) 
	
		clear

		while true
		do
			
			echo -e "\n1- MAKE A BACKUP ON USB\n2- UPDATE LOCAL STORAGE FROM THE BACKUP\nS- BACK"
			read opt

			case $opt in
				1) opt_backup="1"; break;;	
				2) opt_backup="2"; break;;
				0 | S | s) opt_backup="0"; break;;
				*)
				read -p "INSERT A VALID OPTION" n
				clear
				;;
			esac

		done

		if test $opt_backup != "0"
		then
		
			echo -e "\nSHUTDOWN AFTER THE PROCESS? [S/n]"

			while true
			do
				read opt_shut

				case $opt_shut in 
					S | s) opt_shut="1"; break;;
					N | n) opt_shut="0"; break;;
					*) echo "OPTION [S/n]";;
				esac
			done
		
			obs_procs=`ps -aux | grep ${data_backup[0]} | tr -s " " | cut -d" " -f2`
			fpid=`echo $obs_procs | cut -d" " -f1`
			cant_procs=`echo $obs_procs | wc -w`
			
			trap - ERR
			back_exists=`ls /dev/ | grep -w ${data_backup[1]} || echo ""`
			back_mounted=`ls ${data_backup[7]} 2> /dev/null | grep -w ${data_backup[2]} || echo ""`
			trap 'error_catch' ERR

			if !(test -z $back_exists) && !(test -z $back_mounted)
				then
					
					echo -e "\nLOADING..."

					if test $cant_procs -ge 9
					then
						kill -9 $fpid
					fi

					if test $opt_backup == "1"
					then
						cp -r ${data_backup[3]} ${data_backup[6]}
					else
						cp -r ${data_backup[4]} ${data_backup[5]}
					fi

					echo -e "SUCCESS\n"
						
					if test $opt_shut == "1"
						then
							echo "EJECTING USB-BACKUP"
							umount ${data_backup[6]}
							eject /dev/${data_backup[1]}

							echo -e "DONE\nTO SHUTDOWN\nOPENING A WINDOW TO CANCEL"
							sleep 20
							shutdown now
							exit	
						else
							read -p "RETURNING TO THE MENU" n
							clear
							
					fi
					
				else
					read -p "FAIL TO FIND THE USB, PLEASE INSERT IT O VERIFY THE "'"databackup.sh"'" FILE" n
					clear
					
			fi
		else
			echo -e "\nRETURNING TO THE MENU"
			read -p "PRESS A KEY " n
			clear
		fi

		;;
		E | e | 0)
		 
		echo "RETURNING TO TERMINAL"
		read -p "PRESS A KEY " n
		clear
		exit
		
		;;
		*)
			 
		echo -e "\nSELECT A VALID OPTION"
		read -p "PRESS A KEY " n
		clear

		;;
	esac 
done
