#!/bin/bash

##########################################################
#### WORKLOAD GENERATION for MASTER THESIS EXPERIMENT ####
######## using distributed autobench for httperf #########
##########################################################
################## Author: Stefan Engl ###################
##########################################################
######## bash script for Ubuntu 12.04 LTS servers ########
##########################################################

###################
#### VARIABLES ####
###################

#### deployments to test
#envs=(wsmt1m.elasticbeanstalk.com wsmt2m.elasticbeanstalk.com wsmt4m.elasticbeanstalk.com)
envs=(wsmt2m.elasticbeanstalk.com)
envs_count=${#envs[@]}

#### URIs to test
# uri_names=(full-json full-xml full-xhtml today-json tomorrow-json today-xml tomorrow-xml today-xhtml tomorrow-xhtml today-early-json tomorrow-early-json today-early-xml tomorrow-early-xml today-early-xhtml tomorrow-early-xhtml today-morning-json tomorrow-morning-json today-morning-xml tomorrow-morning-xml today-morning-xhtml tomorrow-morning-xhtml today-afternoon-json tomorrow-afternoon-json today-afternoon-xml tomorrow-afternoon-xml today-afternoon-xhtml tomorrow-afternoon-xhtml today-evening-json tomorrow-evening-json today-evening-xml tomorrow-evening-xml today-evening-xhtml tomorrow-evening-xhtml)
uri_names=(full-json full-xml full-xhtml today-json tomorrow-json today-xml tomorrow-xml today-xhtml tomorrow-xhtml today-early-json today-early-xml today-early-xhtml today-morning-json today-morning-xml today-morning-xhtml today-afternoon-json today-afternoon-xml today-afternoon-xhtml today-evening-json today-evening-xml today-evening-xhtml)
# uri_names=(full-json today-early-json today-early-xml today-early-xhtml today-morning-json today-morning-xml today-morning-xhtml today-afternoon-json today-afternoon-xml today-afternoon-xhtml today-evening-json today-evening-xml today-evening-xhtml)

# uris=("schedule-bbc-one-json" "schedule-bbc-one-xml" "schedule-bbc-one-xhtml" "schedule-bbc-one-20120721-json" "schedule-bbc-one-20120722-json" "schedule-bbc-one-20120721-xml" "schedule-bbc-one-20120722-xml" "schedule-bbc-one-20120721-xhtml" "schedule-bbc-one-20120722-xhtml" "schedule-bbc-one-early-20120721-json" "schedule-bbc-one-early-20120722-json" "schedule-bbc-one-early-20120721-xml" "schedule-bbc-one-early-20120722-xml" "schedule-bbc-one-early-20120721-xhtml" "schedule-bbc-one-early-20120722-xhtml" "schedule-bbc-one-morning-20120721-json" "schedule-bbc-one-morning-20120722-json" "schedule-bbc-one-morning-20120721-xml" "schedule-bbc-one-morning-20120722-xml" "schedule-bbc-one-morning-20120721-xhtml" "schedule-bbc-one-morning-20120722-xhtml" "schedule-bbc-one-afternoon-20120721-json" "schedule-bbc-one-afternoon-20120722-json" "schedule-bbc-one-afternoon-20120721-xml" "schedule-bbc-one-afternoon-20120722-xml" "schedule-bbc-one-afternoon-20120721-xhtml" "schedule-bbc-one-afternoon-20120722-xhtml" "schedule-bbc-one-evening-20120721-json" "schedule-bbc-one-evening-20120722-json" "schedule-bbc-one-evening-20120721-xml" "schedule-bbc-one-evening-20120722-xml" "schedule-bbc-one-evening-20120721-xhtml" "schedule-bbc-one-evening-20120722-xhtml")
uris=("schedule-bbc-one-json" "schedule-bbc-one-xml" "schedule-bbc-one-xhtml" "schedule-bbc-one-20120721-json" "schedule-bbc-one-20120722-json" "schedule-bbc-one-20120721-xml" "schedule-bbc-one-20120722-xml" "schedule-bbc-one-20120721-xhtml" "schedule-bbc-one-20120722-xhtml" "schedule-bbc-one-early-20120721-json" "schedule-bbc-one-early-20120721-xml" "schedule-bbc-one-early-20120721-xhtml" "schedule-bbc-one-morning-20120721-json" "schedule-bbc-one-morning-20120721-xml" "schedule-bbc-one-morning-20120721-xhtml" "schedule-bbc-one-afternoon-20120721-json" "schedule-bbc-one-afternoon-20120721-xml" "schedule-bbc-one-afternoon-20120721-xhtml" "schedule-bbc-one-evening-20120721-json" "schedule-bbc-one-evening-20120721-xml" "schedule-bbc-one-evening-20120721-xhtml")
# uris=("schedule-bbc-one-json" "schedule-bbc-one-early-20120721-json" "schedule-bbc-one-early-20120721-xml" "schedule-bbc-one-early-20120721-xhtml" "schedule-bbc-one-morning-20120721-json" "schedule-bbc-one-morning-20120721-xml" "schedule-bbc-one-morning-20120721-xhtml" "schedule-bbc-one-afternoon-20120721-json" "schedule-bbc-one-afternoon-20120721-xml" "schedule-bbc-one-afternoon-20120721-xhtml" "schedule-bbc-one-evening-20120721-json" "schedule-bbc-one-evening-20120721-xml" "schedule-bbc-one-evening-20120721-xhtml")

uris_count=${#uris[@]}

#### transaction timeout
timeout=2

#### load producing clients
client1=ec2-23-22-199-136.compute-1.amazonaws.com:4600
client2=ec2-23-22-211-160.compute-1.amazonaws.com:4600

#### workload request rates

## wsmt1m
#low_rate=10
#rate_step=5
#high_rate=25

## wsmt2m
#low_rate=20
#rate_step=10
#high_rate=50

## wsmt4m
#low_rate=40
#rate_step=20
#high_rate=100

## warmup
low_rate=5
rate_step=1
high_rate=5

#### calls per connection
num_call=1

#### test duration in seconds
#test_time=300
test_time=20

#### output format for results
output_format=csv

#### request port
port=80

#### current timestamp
timestamp=$(date -u +%F_%H:%M:%S)

#############################
#### PREPARE DIRECTORIES ####
#############################

#### create directory to save result output
#mkdir /home/ubuntu/autobench_$timestamp
if [ -d "autobench" ]; then
	echo "directory autobench already exists"
else 
	mkdir autobench
fi 


#### create subdirectories for each URI to test
for (( f=0; f<$uris_count; f++ ))
do
	#mkdir /home/ubuntu/
	if [ -d "autobench/${uri_names[$f]}" ]; then
		echo "directory autobench/${uri_names[$f]} already exists"
	else
		mkdir autobench/${uri_names[$f]}
	fi
done

###################
####  SETTINGS ####
###################

#### override autobench standard settings
> .autobench.conf

###############################
#### PRODUCE LOAD function ####
###############################

#### produce load for a specific URI and environment
function produce_load() {

	#### build command
	if [ -e "autobench/$3/$1_results.csv" ]; then
		echo "file autobench/$3/$1_results.csv already exists"
	else
		#### autobench command for multiple clients
		#autobench_command="autobench_admin --single_host --host1 $1 --port1 $port --uri1 /application/index/$2 --clients $client1,$client2 --low_rate $low_rate --rate_step $rate_step --high_rate $high_rate --num_call $num_call --const_test_time $test_time --timeout $timeout --output_fmt $output_format --file autobench/$3/$1_results.csv"
		
		#### autobench command for a single client
		autobench_command="autobench --single_host --host1 $1 --port1 $port --uri1 /application/index/$2 --low_rate $low_rate --rate_step $rate_step --high_rate $high_rate --num_call $num_call --const_test_time $test_time --timeout $timeout --output_fmt $output_format --file autobench/$3/$1_results.csv"
		
		#### save command to textfile
		echo $autobench_command > autobench/$3/$1_cli.txt
		#### run command
		$autobench_command >> autobench_sdtout.txt
	fi
}

###########################
#### WORKLOAD function ####
###########################

#### loop environments to test for each URI
function produce_workload() {
	for (( i=0; i<$envs_count; i++ ))
	do
		echo "##################################################################################
Test environment ${envs[$i]} with URI $1.
----------------------------------------------------------------------------------"
		produce_load ${envs[$i]} $1 $2
		echo ""
	done
}

##########################
#### EXECUTE WORKLOAD ####
##########################

#### loop URIs to test
for (( j=0; j<$uris_count; j++ ))
do
	produce_workload ${uris[$j]} ${uri_names[$j]}
done
