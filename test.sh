#!/bin/bash

ssh -i CSC410.pem ubuntu@54.245.141.112 <<EOF
#sudo /home/ubuntu/engg_533/setmysql.sh&
sudo /home/ubuntu/engg_533/collectlcpu.sh&
sudo /home/ubuntu/engg_533/sar.sh&
sudo service apache2 start
exit
EOF

echo "STARTING HTTPERF"
httperf --server 54.245.141.112 --port 80 --wsesslog 700,0,input.txt --period e0.05 --dead=35 --rfile=/home/ubuntu/engg_533/responsetimes/rfile.txt > /home/ubuntu/engg_533/responsetimes/output.txt

ssh -i CSC410.pem ubuntu@54.245.141.112 <<EOF
sudo killall collectl
sudo killall sar
sudo service apache2 stop
exit
EOF