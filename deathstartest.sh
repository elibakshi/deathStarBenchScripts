#!/bin/bash

ip=35.90.184.131

numRuns=5
connections=(500)
latency=(0.10)

for idx in ${!threads[@]}; do
    # Number of threads and period for the current iteration.
    c=${connections[$idx]}
    l=${latency[$idx]}

    for ((iter=0; iter<$numRuns; iter++)); do

        # SSH into the server and start collectl
        ssh -i Mayur_AWS_KeyPair.pem -o PubkeyAcceptedKeyTypes=+ssh-rsa ubuntu@$ip "sudo collectl -sCD >& perfdata_output_${c}_${l}_run$iter.txt &"
        # Send the mixed workload using wrk2
        ../wrk2/wrk -D exp -t 1 -c $c -L -s ./wrk2/scripts/social-network/mixed-workload.lua http://$ip:8080 --latency $l > wrk2_output_${c}_${p}_run$iter.txt
        # SSH into the server and stop docker stats
        ssh -i Mayur_AWS_KeyPair.pem -o PubkeyAcceptedKeyTypes=+ssh-rsa ubuntu@$ip 'sudo killall collectl'

    done

done