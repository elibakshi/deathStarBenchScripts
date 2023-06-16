#!/bin/bash

echo "@@@INSIDE SERVER COLLECTL SCRIPT@@@"

outputfile="output1.txt"

#collectl -sC >& outputfile 
#collectl -sC -P -f /home/joydeep/results/collectl/"$outputfile" &
#collectl   -sC -c 1000  >> /home/joydeep/collectl/"$outputfile"&
sudo collectl -sCD >& /home/ubuntu/engg_533/collectl/"perfdata.txt"&
#sudo collectl -sZ -i:1 --procopts m >& /home/joydeep/freshtest/collectl/lowthroughput/four_cores_diff_socket/l3cache/"$outputfile"&
#sudo collectl -sZ -i1:1 >> /home/joydeep/lighttpd/collectl/test1/"$outputfile"&
echo "@@@OUTSIDE SERVER COLLECTL SCRIPT@@@"
sleep 1 
#sudo killall collectl