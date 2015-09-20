#!/bin/bash
#XAIOBS - xampp all in one bash script v0.1

set -e

#Default params
server_name=$2
localhosts_folder=$HOME/Localhosts
localhosts_config='/opt/lamp/etc/extra/httpd-vhosts.conf'
errorlog_file="$localhosts_folder/logs/$server_name-error_log"
server_admin='admin@localhost'
host_ip='127.0.0.1'
port=':80'
config_body="
<VirtualHost $host_ip$port>
    ServerAdmin $server_admin
    DocumentRoot $localhosts_folder/$server_name
    ServerName $server_name
    ServerAlias www.$server_name
    ErrorLog $errorlog_file
    CustomLog logs/$server_name-access_log common
    <Directory />
    AllowOverride All
    Require all granted
    </Directory>
</VirtualHost>
";

#Worker params
cmd=$1
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"


help()
{
  printf "Aviable commands: \\n mklh <name> - create a new localhost \\n start - starts xampp \\n stop - stops xampp \\n restart - restarts xampp \\n also you can use flag -a or -m to do stop/start operations only for apache or mysql\\n"
}

reportResult()
{
    if [ $? -eq 0 ]; then
        $SETCOLOR_SUCCESS
        echo -n "$(tput hpa $(tput cols))$(tput cub 6)[OK]"
        $SETCOLOR_NORMAL
        echo
    else
        $SETCOLOR_FAILURE
        echo -n "$(tput hpa $(tput cols))$(tput cub 6)[fail]"
        $SETCOLOR_NORMAL
        echo
    fi
}

start()
{
    if [ $# = 0 ]; then
      /opt/lampp/lampp start
    fi

    while getopts ":am" opt ;
    do
        case $opt in
            a) /opt/lampp/lampp startapache
                ;;
            m) /opt/lampp/lampp startmysql
                ;;
            *) echo "unknown parameter";
                exit 1
                ;;
            esac
    done
}

stop()
{
  if [ $# = 0 ]; then
      /opt/lampp/lampp stop
    fi

    while getopts ":cw:r" opt ;
    do
        case $opt in
            a) /opt/lampp/lampp stopapache
                ;;
            m) /opt/lampp/lampp stopmysql
                ;;
            *) echo "unknown parameter";
                exit 1
                ;;
            esac
    done
}

restart()
{
  if [ $# = 0 ]; then
      /opt/lampp/lampp restart
    fi

    while getopts ":cw:r" opt ;
    do
        case $opt in
            a) /opt/lampp/lampp restartapache
                ;;
            *) echo "unknown parameter";
                exit 1
                ;;
            esac
    done
}

modifyHosts()
{
    ip=${host_ip//\./\\.}
    sed -i "/$host_ip/ s/$/ ${server_name}/" /etc/hosts
}

#Create a new localhost
mklh()
{
  if [ -z "$server_name" ]
    then
        echo -en "\033[33mExpecting localhost name as second parameter\033[0m \\n \033[2muse\033[0m mklh somesite.loc \\n";
    else
    echo -en "\033[34mA new localhost folder will be created under\033[0m \\n$localhosts_folder/$server_name\\n";
    echo -e "\\nThe following localhost config will be added
             $config_body\\nto $localhosts_config";
    echo -n "Looks good? (y/n) "

        read item
        case "$item" in
            y|Y)
                echo "creating localhost folder"
                mkdir $localhosts_folder/$server_name
                reportResult

               echo "modifying $localhosts_config"
               echo "$config_body" >> $localhosts_config
               reportResult

               echo 'modifying hosts'
               modifyHosts
               reportResult

               restart
                ;;
            n|N) echo -e "Declined...\\nYou can configure other params inside the script file"
                exit 0
                ;;
            *) echo "Declined..."
                ;;
        esac;
    fi
}

processCommand()
{
  if [ -n "$(type -t $cmd)" ] && [ "$(type -t $cmd)" = function ]; 
     then eval "$cmd"; else echo -en "\033[33mNo such command found \033[0m \\n"; help; fi
}

#Execution
processCommand

exit 0