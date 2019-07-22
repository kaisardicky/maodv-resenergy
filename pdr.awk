# 
# Script AWK to read result.tr files
# 

BEGIN {
	sendLine = 0;
	recvLine = 0;
	fowardLine = 0;
	TC =0;
	rt_pkts=0;
	rt_send=0;
	rt_forward=0;
recvd = 0;#################### to calculate total number of data packets received
rt_pkts = 0;################## to calculate total number of routing packets received
}
{
##### Check if it is a data packet
if (( $1 == "r") && ( $7 == "cbr" || $7 =="tcp" ) && ( $4=="AGT" )) recvd++;

##### Check if it is a routing packet
if (($1 == "s" || $1 == "f") && $4 == "RTR" && ($7 =="AODV" || $7 =="message" || $7 =="DSR" || $7 =="OLSR")) rt_pkts++;
}


$0 ~/^s.* AGT/ {
	sendLine ++ ;
}

$0 ~/^r.* AGT/ {
	recvLine ++ ;
}

$0 ~/^f.* RTR/ {
	fowardLine ++ ;
}

$0 ~/^s.* \[TC / {
	TC ++ ;
}

{  
	if($4 == "AGT" && $1 == "s" && seqno < $6) {
		seqno = $6;
	} 
	#end-to-end delay
	if($4 == "AGT" && $1 == "s") {
		start_time[$6] = $2;
	}
	else if(($7 == "cbr") && ($1 == "r")) {
		end_time[$6] = $2;
	} 
	else if($1 == "D" && $7 == "cbr") {
		end_time[$6] = -1;
	} 
	else if (($1 == "s" || $1 == "f") && ($4 == "RTR") && ($7 == "AODV")) {
		rt_pkts++;
	}
	if (($1 == "s") && ($4 == "RTR") && ($7 == "AODV") && ($25 == "(REQUEST)")) {	
		rt_send++;
	}
	if (($1 == "s") && ($4 == "RTR") && ($7 == "AODV") && ($25 == "(REQUEST)") && ($3 != "_58_")) {		
		rt_forward++;
	}
}
{
  event = $1
  time = $2
  node_id = $3
  pkt_size = $8
  level = $4

  if (level == "AGT" && event == "s" && $7 == "cbr") {
    sent++
# Note the change in the next line. This initializes the startTime with the first encountered "time" value.
    if (!startTime || (time < startTime)) {
      startTime = time
    }
  }

  if (level == "AGT" && event == "r" && $7 == "cbr") {
    receive++
    if (time > stopTime) {
      stopTime = time
    }
    recvdSize += pkt_size
  }
}


END {        
	for(i=0; i<=seqno; i++) {
		if(end_time[i] > 0) {
			delay[i] = end_time[i] - start_time[i];
			count++;
		}
		else {
			delay[i] = -1;
		}
	}
	for(i=0; i<=seqno; i++) {
		if(delay[i] > 0) {
			n_to_n_delay = n_to_n_delay + delay[i];
		}         
	}
	n_to_n_delay = n_to_n_delay/count;

	# PRINT RESULT
	printf "==================================== \n"
	printf "Performance Metric \n"
	printf "==================================== \n"
	printf "Packet SendLine \t= %d \n", sendLine;
	printf "Packet RecvLine \t= %d \n", recvLine;
	printf "Packet Loss 	\t= %d \n", (sendLine-recvLine);
	printf "Packet Delivery Ratio \t= %.6f \n", (recvLine/sendLine);
	printf("PDR Precentage \t \t= %.2f %%\n",(receive/sent)*100);	
	printf "End-to-End Delay \t= " n_to_n_delay * 1000 " ms \n";
	printf "Packet ForwardLine\t= %d \n", fowardLine;
	printf("Routing Load/Overhead \t= %.4f\n", rt_pkts/recvd);
	#printf "Topology Control \t= %d \n", TC;
	printf "Routing Packets \t= %d \n", rt_pkts;
printf("Average Throughput[kbps]= %.2f \nStartTime= %.2f\tStopTime= %.2f\n", (recvdSize/(stopTime-startTime))*(8/1000),startTime,stopTime);
printf "\n"
}
