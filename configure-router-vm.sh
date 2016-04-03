#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Microsoft Azure
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#--------------------------------------------------------------------------------------------------
# MongoDB Template for Azure Resource Manager (brought to you by Full Scale 180 Inc)
#
# This script installs MongoDB on each Azure virtual machine. The script will be supplied with
# runtime parameters declared from within the corresponding ARM template.
#--------------------------------------------------------------------------------------------------

PACKAGE_URL=http://repo.mongodb.org/apt/ubuntu
PACKAGE_NAME=mongodb-org
MONGODB_PORT=27017
NODE_IP_ADDRESS="127.0.0.1"
SHARD_COUNT=2

help()
{
	echo "This script installs MongoDB on the Ubuntu virtual machine image"
	echo "Options:"
	echo "		-i Node ip address"	
	echo "		-s Shard count"
}

log()
{
	# If you want to enable this logging add a un-comment the line below and add your account key 
	#curl -X POST -H "content-type:text/plain" --data-binary "$(date) | ${HOSTNAME} | $1" https://logs-01.loggly.com/inputs/${LOGGING_KEY}/tag/redis-extension,${HOSTNAME}
	echo "$1"
}

log "Begin execution of MongoDB installation script extension on ${HOSTNAME}"

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

# Parse script parameters
while getopts :i:s:h optname; do  
	case $optname in
	i) # Installation package location
		NODE_IP_ADDRESS=${OPTARG}
		;;
	s) # Shard count
		SHARD_COUNT=${OPTARG}
		;;
    h) # Helpful hints
		help
		exit 2
		;;
    \?) # Unrecognized option - show help
		echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
		help
		exit 2
		;;
  esac
done

#############################################################################
install_mongodb()
{
	log "Downloading MongoDB package $PACKAGE_NAME from $PACKAGE_URL"

	# Configure mongodb.list file with the correct location
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
	echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

	# Install updates
	apt-get -y update

	# Remove any previously created configuration file to avoid a prompt
	if [ -f /etc/mongos.conf ]; then
		rm /etc/mongos.conf
	fi
	
	#Install Mongo DB
	log "Installing MongoDB package $PACKAGE_NAME"
	apt-get -y install $PACKAGE_NAME
	
	# Stop Mongod as it may be auto-started during the above step (which is not desirable)
	stop_mongodb
}

#############################################################################
start_mongos()
{
	log "Starting mongos service"

	tee /etc/mongos.conf > /dev/null <<EOF
systemLog:
    destination: file
    path: /var/log/mongodb/mongos.log
    quiet: true
    logAppend: true
net:
    port: $MONGODB_PORT
sharding:
    configDB: con/10.0.0.8:$MONGODB_PORT
EOF
	
	nohup mongos --config /etc/mongos.conf &
	# Wait for MongoDB daemon to start and initialize for the first time (this may take up to a minute or so)
	while ! timeout 1 bash -c "echo > /dev/tcp/$NODE_IP_ADDRESS/$MONGODB_PORT"; do sleep 10; done
}

#############################################################################
configure_sharded_cluster()
{
	log "Configuring sharded cluster"

	for i in $(seq 1 $SHARD_COUNT)
	do
		shardName=sha$[ $i - 1 ]
		shardIp=$[ 16 * $i ]
		mongo $NODE_IP_ADDRESS:$MONGODB_PORT --eval "sh.addShard('$shardName/10.0.0.$shardIp:$MONGODB_PORT')"	
	done
}

#############################################################################
stop_mongodb()
{
	# Find out what PID the MongoDB instance is running as (if any)
	MONGOPID=`ps -ef | grep '/usr/bin/mongod' | grep -v grep | awk '{print $2}'`
	
	if [ ! -z "$MONGOPID" ]; then
		log "Stopping MongoDB daemon processes (PID $MONGOPID)"
		
		kill -15 $MONGOPID
	fi
	
	# Important not to attempt to start the daemon immediately after it was stopped as unclean shutdown may be wrongly perceived
	sleep 15s	
}


#tune_memory
#tune_system
install_mongodb
start_mongos
configure_sharded_cluster

# Exit (proudly)
exit 0