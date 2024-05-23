#! /bin/bash

fetch_bastion_private_key (){
  key_str=`aws secretsmanager get-secret-value --secret-id $1 | jq '.SecretString' | tr -d '"'`
  render_private_key_in_original_format "$key_str" $2
  chmod 400 $2
}

delete_bastion_private_key (){
  if [[ $2 == "short" ]]
  then
    sleep 3
  else
    sleep 60
  fi
  rm -f $1
}

render_private_key_in_original_format (){
  array=(${1//'-----BEGIN OPENSSH PRIVATE KEY-----\n'/ })
  array2=(${array[0]//'-----END'/ })
  array3=(${array2[0]//'\n'/ })
  echo "-----BEGIN OPENSSH PRIVATE KEY-----" >> $2
  for element in "${array3[@]}"; do     echo "$element" >> $2; done
  echo "-----END OPENSSH PRIVATE KEY-----" >> $2
}

derive_bastion_secret_from_bastion_key (){

  if [[ $1 ]]; then
    # if there is bastion_key in configuration file, construct these parameters
    # from bastion_key.
    local bastion_key_name_local=$( basename $1 )
    local bastion_key_secret_local=CodaMetrixApplication/Developers/$bastion_key_name_local
  else
    echo "Bastion key can not be blank"
    exit
  fi
  echo "$bastion_key_secret_local"
}

# Because this function is interative with user, we cannot use
# "echo" to return value, we can only use parameters to return
# values. If user include '~' as part of file path, we use "eval echo $parameter"
# to expand the user's home directory
read_required_input (){
  local _parameter=$1
  local parameter
  echo "Enter $2: "
  read parameter
  if [ "$parameter" != "" ]; then
    local input=$( eval echo $parameter )
    eval $_parameter="'$input'"
  else
    echo "$2 is required!"
    exit
  fi
}
