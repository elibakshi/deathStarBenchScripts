#!/bin/bash

ip=3.80.38.185

numRuns=5
threads=(500 1000 1500 2000 3000 4000 5000)
periods=(0.10 0.05 0.033 0.025 0.016 0.0125 0.01)

# Create a results file with the headers "Threads, Period, Response Time, Mongo CPU, NodeJS CPU"
echo "Threads, Period, Response Time (ms), Mongo CPU %, NodeJS CPU %" > results.csv

for idx in ${!threads[@]}; do
    # Number of threads and period for the current iteration.
    t=${threads[$idx]}
    p=${periods[$idx]}

    # Run each load numRuns times to get the avg.
    respAvg=0
    mongoCpuAvg=0
    nodejsCpuAvg=0

    for ((iter=0; iter<$numRuns; iter++)); do

        # SSH into the server and start docker stats
        ssh -i CSC_410_Project.pem ubuntu@$ip "docker stats > docker_stats_output_${t}_${p}_run$iter.txt &"
        # Send the workload using httperf
        httperf --server $ip --port 9080 --http-version=1.1 --wsesslog=$t,1,acme_session.txt --add-header='Content-Type:application/json\n' --session-cookie --period=e$p > httperf_acme_output_${t}_${p}_run$iter.txt
        # SSH into the server and stop docker stats
        ssh -i CSC_410_Project.pem ubuntu@$ip 'sudo pkill -f "docker stats"'

        # SSH into the server and process the docker output file and calculate the average utilizations from the server
        readarray -d ' ' -t util < <(ssh -i CSC_410_Project.pem ubuntu@$ip "./docker_stats_to_csv.sh docker_stats_output_${t}_${p}_run$iter.txt ${p} data_${t}_${p}_run$iter.csv; ./util.py data_${t}_${p}_run$iter.csv")

        # Get the response time for the current iteration and sum it with the average
        resp=$(awk '{for (I=1;I<=NF;I++) if ($I == "connect") {x=$(I+1)} else if ($I == "response") {y=$(I+1)} else if ($I == "transfer") {z=$(I+1)}} END{print x+y+z}' httperf_acme_output_${t}_${p}_run$iter.txt)
        
        # Sum the variables, note that they are potentially floating point values
        respAvg=$(echo "$respAvg + $resp" | bc -l)
        mongoCpuAvg=$(echo "$mongoCpuAvg + ${util[2]}" | bc -l)
        nodejsCpuAvg=$(echo "$nodejsCpuAvg + ${util[0]}" | bc -l)

    done

    # Divide the sums by the number of runs to get the averages
    respAvg=$(echo "scale=3; $respAvg / $numRuns" | bc -l)
    
    mongoCpuAvg=$(echo "scale=3; $mongoCpuAvg / $numRuns" | bc -l)
    nodejsCpuAvg=$(echo "scale=3; $nodejsCpuAvg / $numRuns" | bc -l)

    #Append the results to the results file
    echo "$t, $p, $respAvg, $mongoCpuAvg, $nodejsCpuAvg" >> results.csv

done