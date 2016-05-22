#!/bin/bash
#Written by Andrew Guidetti

VAULT_IP="45.55.163.231:8200"
APP_ID="722d6410-cda6-4d47-bbfb-4d9103368bf0"
#USER_ID="065a2a45-a169-4fcd-b34d-9d44f7c3f331" #<-- Use this key for demo
#the user_id and app_id should never be hardcoded together in production!


function connect2Vault {

	#TODO: add some logic here if vault is not initialized
	echo -e "\nChecking if vault is initialized..."
	curl "http://"$VAULT_IP"/v1/sys/init"
	sleep 1

	echo -e "\nlogging into vault with app_id:"
	sleep 1
	echo $APP_ID
	sleep 1

	echo -e "\nYou must now provide a private user_id:"
	read USER_ID
	sleep 1
	echo "Checking: "$USER_ID""
	sleep 1

	JSONTOKEN=`
		curl \
		-s \
		-X POST \
		-d '{"app_id":"'"$APP_ID"'", "user_id":"'"$USER_ID"'"}' \
		"http://"$VAULT_IP"/v1/auth/app-id/login"`		

    VAULT_TOKEN=`echo "$JSONTOKEN" | sed -e 's/^.*"client_token"[ ]*:[ ]*"//' -e 's/".*//'`
    export VAULT_TOKEN

	#check if the key is long enough
	if [ ${#VAULT_TOKEN} -ge 2 ]; 
	then
		echo -e "\nVault has granted you a key:"
		sleep 1
		echo $VAULT_TOKEN
		sleep 1
		echo -e "\nConnected to Vault. Ready for step 3.\n"
	else
		echo -e "\n!!!Vault did not give you a key!!!"
		echo -e "Please check your user_id and try again before step 3.\n"
	fi
menu
}


function create3Passwords {
	echo -e "\nHere are three new passwords:\n"
	sleep .5
	PASSWORD1=$(generatePassword)
	echo $PASSWORD1
	PASSWORD2=$(generatePassword)
	echo $PASSWORD2
	PASSWORD3=$(generatePassword)
	echo -e "$PASSWORD3 \n"
	sleep 1
menu
}

function generatePassword {
	cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1
}

function sendPasswords {
	
	#TODO: clean this up and make it reusable, add some logic if passwords or tokens are blank.
	echo "Sending this secret data to Vault"
	sleep 1
	echo -e "\nPassword1 = $PASSWORD1"
	curl \
   	     -X POST \
   	     -H "X-Vault-Token:$VAULT_TOKEN" \
   	     -H 'Content-type: application/json' \
   	     -d '{"Password1":"'"$PASSWORD1"'"}' \
   	     http://"$VAULT_IP"/v1/secret/password1

	echo "Password2 = $PASSWORD2"
	curl \
   	    -X POST \
		-H "X-Vault-Token:$VAULT_TOKEN" \
		-H 'Content-type: application/json' \
		-d '{"Password2":"'"$PASSWORD2"'"}' \
   	     http://"$VAULT_IP"/v1/secret/password2

	echo "Password3 = $PASSWORD3"
	curl \
		-X POST \
		-H "X-Vault-Token:$VAULT_TOKEN" \
   	    -H 'Content-type: application/json' \
   	    -d '{"Password3":"'"$PASSWORD3"'"}' \
   	     http://"$VAULT_IP"/v1/secret/password3
	
	sleep 1
	echo -e "\nSucesfully sent to Vault!\nPress 4 to exit, or start over.\n"
menu
}

function menu {
        echo -e "Choose an option\n1: Generate 3 new passwords \n2: Connect to Vault \n3: Send passwords to Vault \n4: Exit "
        read menuPick
		
		if [ "$menuPick" == "1" ]
		then
			create3Passwords
		elif [ "$menuPick" == "2" ]
		then
			connect2Vault
		elif [ "$menuPick" == "3" ] 
		then
			sendPasswords	
		elif [ "$menuPick" == "4" ]
		then
			echo "Goodbye!"
			exit
		else
			echo "Try again"
			menu				
		fi
}
echo ""
menu



