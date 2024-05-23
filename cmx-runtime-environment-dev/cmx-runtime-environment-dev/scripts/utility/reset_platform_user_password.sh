#!/usr/bin/env bash

HELP="Usage: reset_platform_user_password.sh [OPTIONS] \n \
				Options: \n \
					-l|--list\t\t\t\tList usernames \n"

echo "Enter the database address: "
read dbaddress

echo "Enter the database port: "
read dbport

echo "Enter the database login username: "
read dbusername

echo "Enter the database login password: "
read -s dbpassword
export PGPASSWORD=$dbpassword

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
	    -l|--list)
       psql -a -b -d userservice -h $dbaddress -p $dbport \
          -U $dbusername -c "\x" -c "select username from t_user"
	     shift # past argument
	    ;;
			-h|--help)
			 echo -e $HELP
			 exit
			;;
	esac
done

echo "Enter the platform user username: "
read username

while [ -n "$username" ]; do
  echo "Enter the platform user password (new password): "
  read password
  export password
  export encryptedpassword=`htpasswd -bnBC 11 "" $password | tr -d ':\n' | sed 's/$2y/$2a/'`

  psql -a -b -d userservice -h $dbaddress -p $dbport \
      -U $dbusername -c "\x" -c "update t_user set password='$encryptedpassword' where username='$username'"

  unset password
  unset encryptedpassword

  echo "Enter the platform user username: "
  read username
done

unset PGPASSWORD
unset dbpassword
