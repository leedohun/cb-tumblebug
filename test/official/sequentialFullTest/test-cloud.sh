#!/bin/bash

function dozing()
{
	duration=$1
	printf "Dozing for %s : " $duration
	for (( i=1; i<=$duration; i++ ))
	do
		printf "%s " $i
		sleep 1
	done
	echo "(Back to work)"
}

function test_sequence()
{
	local CSP=$1
	local REGION=$2
	local POSTFIX=$3
	local CMDPATH=$4

		../1.configureSpider/register-cloud.sh $CSP $REGION $POSTFIX $TestSetFile
		#../2.configureTumblebug/create-ns.sh $CSP $REGION $POSTFIX $TestSetFile
		# ../3.vNet/create-vNet.sh $CSP $REGION $POSTFIX $TestSetFile
		# dozing 10
		# if [ "${CSP}" == "gcp" ]; then
		# 	echo "[Test for GCP needs more preparation time]"
		# 	dozing 20
		# fi
		# ../4.securityGroup/create-securityGroup.sh $CSP $REGION $POSTFIX $TestSetFile
		# dozing 10
		# ../5.sshKey/create-sshKey.sh $CSP $REGION $POSTFIX $TestSetFile
		# ../6.image/registerImageWithInfo.sh $CSP $REGION $POSTFIX $TestSetFile
		# ../7.spec/register-spec.sh $CSP $REGION $POSTFIX $TestSetFile
		#../8.mcis/create-mcis.sh $CSP $REGION $POSTFIX $TestSetFile
		#dozing 1
		#../8.mcis/status-mcis.sh $CSP $REGION $POSTFIX $TestSetFile

		_self=$CMDPATH

		echo ""
		echo "[Logging to notify latest command history]"
		echo "[CMD] ${_self} ${CSP} ${REGION} ${POSTFIX}" >> ./executionStatus
		echo ""
		echo "[Executed Command List]"
		cat  ./executionStatus
		echo ""

}


#function testAll() {
    FILE=../conf.env
    if [ ! -f "$FILE" ]; then
        echo "$FILE does not exist."
        exit
    fi

	FILE=../credentials.conf
    if [ ! -f "$FILE" ]; then
        echo "$FILE does not exist."
        exit
    fi

	TestSetFile=${4:-../testSet.env}
    
    FILE=$TestSetFile
    if [ ! -f "$FILE" ]; then
        echo "$FILE does not exist."
        exit
    fi
	source $TestSetFile
    source ../conf.env
	AUTH="Authorization: Basic $(echo -n $ApiUsername:$ApiPassword | base64)"
	source ../credentials.conf

	echo "####################################################################"
	echo "## Create MCIS from Zero Base"
	echo "####################################################################"


	CSP=${1}
	REGION=${2:-1}
	POSTFIX=${3:-developer}

	source ../common-functions.sh
	getCloudIndex $CSP

	if [ "${INDEX}" == "0" ]; then
		echo "[Parallel excution for all CSP regions]"

		INDEXX=${NumCSP}
		for ((cspi=1;cspi<=INDEXX;cspi++)); do
			#echo $i
			INDEXY=${NumRegion[$cspi]}
			CSP=${CSPType[$cspi]}
			for ((cspj=1;cspj<=INDEXY;cspj++)); do
				#echo $j
				REGION=$cspj

				echo $CSP
				echo $REGION

				test_sequence $CSP $REGION $POSTFIX ${0##*/}

			done
		done
		
	else
		echo "[Single excution for a CSP region]"

		test_sequence $CSP $REGION $POSTFIX ${0##*/}

	fi

#}

#test_cloud