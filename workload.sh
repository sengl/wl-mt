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
## environments available
# envs=(wsmt1m.elasticbeanstalk.com wsmt2m.elasticbeanstalk.com wsmt4m.elasticbeanstalk.com)

## environment to test
envs=(wsmt1m.elasticbeanstalk.com)
envs_names=(wsmt1m)
envs_count=${#envs[@]}

#### URI names
## names of the full range of URIs
# uri_names=(full-json full-xml full-xhtml today-json tomorrow-json today-xml tomorrow-xml today-xhtml tomorrow-xhtml today-early-json tomorrow-early-json today-early-xml tomorrow-early-xml today-early-xhtml tomorrow-early-xhtml today-morning-json tomorrow-morning-json today-morning-xml tomorrow-morning-xml today-morning-xhtml tomorrow-morning-xhtml today-afternoon-json tomorrow-afternoon-json today-afternoon-xml tomorrow-afternoon-xml today-afternoon-xhtml tomorrow-afternoon-xhtml today-evening-json tomorrow-evening-json today-evening-xml tomorrow-evening-xml today-evening-xhtml tomorrow-evening-xhtml)

## names of a URI subset
uri_names=(full-xhtml full-xml full-json today-xhtml today-xml today-json today-evening-xhtml today-evening-xml today-evening-json)

#### URIs to test following this structure /application/index/[:URI]
## full range of URIs
# uris=("schedule-bbc-one-json" "schedule-bbc-one-xml" "schedule-bbc-one-xhtml" "schedule-bbc-one-20120721-json" "schedule-bbc-one-20120722-json" "schedule-bbc-one-20120721-xml" "schedule-bbc-one-20120722-xml" "schedule-bbc-one-20120721-xhtml" "schedule-bbc-one-20120722-xhtml" "schedule-bbc-one-early-20120721-json" "schedule-bbc-one-early-20120722-json" "schedule-bbc-one-early-20120721-xml" "schedule-bbc-one-early-20120722-xml" "schedule-bbc-one-early-20120721-xhtml" "schedule-bbc-one-early-20120722-xhtml" "schedule-bbc-one-morning-20120721-json" "schedule-bbc-one-morning-20120722-json" "schedule-bbc-one-morning-20120721-xml" "schedule-bbc-one-morning-20120722-xml" "schedule-bbc-one-morning-20120721-xhtml" "schedule-bbc-one-morning-20120722-xhtml" "schedule-bbc-one-afternoon-20120721-json" "schedule-bbc-one-afternoon-20120722-json" "schedule-bbc-one-afternoon-20120721-xml" "schedule-bbc-one-afternoon-20120722-xml" "schedule-bbc-one-afternoon-20120721-xhtml" "schedule-bbc-one-afternoon-20120722-xhtml" "schedule-bbc-one-evening-20120721-json" "schedule-bbc-one-evening-20120722-json" "schedule-bbc-one-evening-20120721-xml" "schedule-bbc-one-evening-20120722-xml" "schedule-bbc-one-evening-20120721-xhtml" "schedule-bbc-one-evening-20120722-xhtml")

## subset of URIs to test
uris=("schedule-bbc-one-xhtml" "schedule-bbc-one-xml" "schedule-bbc-one-json" "schedule-bbc-one-20120721-xhtml" "schedule-bbc-one-20120721-xml" "schedule-bbc-one-20120721-json" "schedule-bbc-one-evening-20120721-xhtml" "schedule-bbc-one-evening-20120721-xml" "schedule-bbc-one-evening-20120721-json")

## URIs count
uris_count=${#uris[@]}

#### transaction timeout
timeout=2

#### load producing clients
client1=ec2-.compute-1.amazonaws.com:4600
client2=ec2-.compute-1.amazonaws.com:4600

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
#low_rate=80
#rate_step=15
#high_rate=100

#loads=(50 60 70 70 80 80 80 90 90)
#loads=(35 40 40 35 40 40 40 40 40)
loads=(20 22 22 20 22 22 20 22 22)
load_repetitions=70

## warmup
warmup_low_rate=10
warmup_rate_step=1
warmup_high_rate=10

#### calls per connection
num_call=1

#### test duration in seconds
test_time=30
warmup_test_time=20

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
if [ -d "autobench" ]; then
	echo "directory autobench already exists"
else 
	mkdir autobench
fi

#### create subdirectory to save warmup output
#if [ -d "autobench/warmup" ]; then
#	echo "directory autobench/warmup already exists"
#else 
#	mkdir autobench/warmup
#fi 


#### create subdirectories for each URI to test
#for (( f=0; f<$uris_count; f++ ))
#do
#	#mkdir /home/ubuntu/
#	if [ -d "autobench/${uri_names[$f]}" ]; then
#		echo "directory autobench/${uri_names[$f]} already exists"
#	else
#		mkdir autobench/${uri_names[$f]}
#	fi
#done

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
		
	#### warmup command
	autobench_warmup_command="autobench --single_host --host1 $1 --port1 $port --uri1 /application/index/$2 --low_rate $warmup_low_rate --rate_step $warmup_rate_step --high_rate $warmup_high_rate --num_call $num_call --const_test_time $warmup_test_time --timeout $timeout --output_fmt $output_format"

	#### run warmup command
	$autobench_warmup_command

	#### iterate load repetitions
	for (( r=0; r<$load_repetitions; r++ ))
	do
		#### check if results file exists command
		if [ -e "autobench/$3_$4_results_$5_$r.csv" ]; then
			echo "file autobench/$3_$4_results_$5_$r.csv already exists"
		else
			#### autobench command for a single client
			autobench_command="autobench --single_host --host1 $1 --port1 $port --uri1 /application/index/$2 --low_rate $5 --rate_step 1 --high_rate $5 --num_call $num_call --const_test_time $test_time --timeout $timeout --output_fmt $output_format --file autobench/$3_$4_results_$5_$r.csv"

			#### run test command
			$autobench_command >> autobench/$4_autobench_stdout_$5_$r.txt
		fi
	done

	#### save command to textfile
	echo $autobench_command > autobench/$3_$4_cli.txt
}

###########################
#### WORKLOAD function ####
###########################

#### loop environments to test for each URI
function produce_workload() {
	for (( i=0; i<$envs_count; i++ ))
	do
		echo "##################################################################################
Test environment ${envs[$i]} with URI $1 and load $3.
----------------------------------------------------------------------------------"
		produce_load ${envs[$i]} $1 $2 ${envs_names[$i]} $3
		echo ""
	done
}

##########################
#### EXECUTE WORKLOAD ####
##########################

#### loop URIs to test
for (( j=0; j<$uris_count; j++ ))
do
	produce_workload ${uris[$j]} ${uri_names[$j]} ${loads[$j]}
done
