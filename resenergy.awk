#residual energy of node
BEGIN {
	i=0
	n=0
	total_energy=0.0
	hop_count=0
}

{
event = $1
time =$3
node_id=$5
energy_value= $7

if(event == "N"){
	for(i=0;i<100;i++) {
		if(i==node_id) {
			iEnergy[i] = iEnergy[i]-(iEnergy[i] - energy_value);
			printf("energi node (%d) = %f \n",i,iEnergy[i]);
			hop_count++;
		}
	}
}
}

END {
printf("\n");
for(i=0;i<100;i++) {
	printf("residu energi node (%d) = %f \n",i,iEnergy[i]);
total_energy = total_energy + iEnergy[i];
if(iEnergy[i] !=0)
n++
}
printf("\n");
average=total_energy/n;
printf("average energi = %f \n",average);
printf("\n");
printf("total residu energi = %f \n",total_energy);
printf("\n");
printf("total hop count = %d\n",hop_count);
}
