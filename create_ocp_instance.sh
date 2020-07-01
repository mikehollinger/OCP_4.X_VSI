#!/bin/bash
dir=${PWD}  
p_now=$(date +"%T")
start=$(date +%s)





if [[ "$OSTYPE" == "linux-gnu"* ]]; then
echo "System type: Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
echo "System type: MacOS; lets link the slcli command"
export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig"
   if slcli --version; then
     echo "Success"
   else
    ln -s ~/Library/Python/2.7/bin/slcli /usr/local/bin/slcli
   fi
fi


## This is to verify slcli before executing the playbook.
if slcli --version; then
     echo "Success"
else
     echo Failure, exit status: $?, 
     echo pip install softlayer
     echo please add slcli to your local path by 
     exit
fi

echo "############################################################################################"
echo "#                    PROVISIONED START TIME : $p_now                                       #"
echo "############################################################################################"



ansible-playbook  -e @vars.yaml  $dir/play1.yaml
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
now=$(date +"%T")

echo "Current time : $now"
ansible-playbook  -e @vars.yaml  $dir/play2.yaml -i $dir/artifacts/hosts
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

q_now=$(date +"%T")
duration=$(echo "$(date +%s) - $start" | bc)
execution_time=`printf "%.2f seconds" $duration`
now=$(date +"%T")

echo "Current time : $now"
ansible-playbook  -e @vars.yaml  $dir/play3.yaml -i $dir/artifacts/hosts
r_now=$(date +"%T")
duration=$(echo "$(date +%s) - $start" | bc)
execution_time=`printf "%.2f seconds" $duration`
chmod 600 $dir/artifacts/sl_ssh_rsa
echo "###############################################################################################"
echo "#         PROVISIONED START TIME : $p_now             PROVISIONED END TIME : $r_now           #"
echo "#                                 Execution Time: $execution_time                             #"
echo "###############################################################################################"
