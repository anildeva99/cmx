#!/usr/bin/env python3
import sys
import os
import json
from os.path import expanduser
import subprocess
import configparser
from shutil import copyfile




def run_command(cmd):
    """
    execute a shell command
    """

    p = ""
    try:
        ## run it ##
        p = subprocess.check_output(cmd, universal_newlines=True, shell=True, encoding='UTF-8')
        
    except OSError as e:
        print (e)

    return p

def get_temparary_token(g_tokens, new_config, serial_number):
    cmd = 'aws sts get-session-token --token-code '+g_tokens[1]+ ' --serial-number '+serial_number+' --profile '+ g_tokens[0]
    print ("executing:"+cmd)
    stdout_msg = run_command(cmd)
    print(stdout_msg)
    json_data = json.loads(stdout_msg)

    cred_file = expanduser("~/.aws/credentials")

    new_config['default'] = {'aws_access_key_id': json_data["Credentials"]["AccessKeyId"],
                             'aws_secret_access_key': json_data["Credentials"]["SecretAccessKey"],
                             'aws_session_token': json_data["Credentials"]["SessionToken"]}

    #delete old credentials file
    os.remove(cred_file)
    # write to new credentials file
    with open(cred_file, 'w+') as configfile:
        new_config.write(configfile)
        configfile.close()

       

def main(tokens):

    cred_file = expanduser("~/.aws/credentials")
    # backup the credentials file
    copyfile(cred_file, expanduser("~/.aws/credentials.backup"))

    # read old credentials file
    config = configparser.ConfigParser()
    config.sections()
    config.read(cred_file)
    serial_number = config[tokens[0]]['serial_number']


    get_temparary_token(tokens,  config, serial_number) 
if __name__ == "__main__":
    main(sys.argv[1:])
