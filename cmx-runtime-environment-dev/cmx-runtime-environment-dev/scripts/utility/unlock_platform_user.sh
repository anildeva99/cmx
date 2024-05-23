#!/usr/bin/env bash
HELP="Usage: unlock_platform_user.sh [OPTIONS] \n \
				Options: \n \
					-l|--list\t\t\t\tList users and their lock flags \n"

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
          -U $dbusername -c "\x" -c "select username,failed_login_count,last_failed_login_time,lockout_time from t_user"
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
  psql -a -b -d userservice -h $dbaddress -p $dbport \
      -U $dbusername -c "\x" -c "update t_user set last_failed_login_time=NULL,lockout_time=NULL,failed_login_count=0 where username='$username'"
  echo "Enter the platform user username: "
  read username
done
