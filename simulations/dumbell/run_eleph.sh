#!/bin/bash

: '
 *run_eleph: run the elephant experiment with give parameters
 *  Author: Ahmed Mohamed Abdelmoniem Sayed, <ahmedcs982@gmail.com, github:ahmedcs>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of CRAPL LICENCE avaliable at
 *    http://matt.might.net/articles/crapl/.
 *    http://matt.might.net/articles/crapl/CRAPL-LICENSE.txt
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *  See the CRAPL LICENSE for more details.
 *
 * Please READ carefully the attached README and LICENCE file with this software
'

simT=$1
nodes=$2
qsize=$3
psize=1460
minrto=$4
tcpopt=$5
sample=$6
rack=$7
vmdelay=$8

ROOT_DIR=`pwd`
TRACES_DIR=$ROOT_DIR/rack/eleph
SCRIPTS_DIR=$ROOT_DIR/rack

# NOTE: this must match between ./run and ./scripts/postProcessTraceFiles.sh
RESULTS_DIR_PREFIX=simulation

    STARTTIME=$(date +%s)
    RESULTS_DIR=$TRACES_DIR/$RESULTS_DIR_PREFIX-simT$simT-N$nodes-Q$qsize-P$psize-MRTO$minrto-TCP$tcpopt-Sample$sample-RACK$rack-vmdelay$vmdelay$(date +%Y-%m-%d.%H.%M.%S)

    cd $SCRIPTS_DIR
    echo ns tcp_eleph.tcl $simT TCP DropTail $nodes $qsize $psize $minrto $tcpopt $sample $rack $vmdelay 
    ns tcp_eleph.tcl $simT TCP DropTail $nodes $qsize $psize $minrto $tcpopt $sample $rack $vmdelay
    errorCode=$?
    if [ "$errorCode" -ne 0 ]
    then
        echo "ERROR: Stopping because NS returned error code $errorCode"
	exit -1
    fi
    cd $ROOT_DIR

    # Simulation time calculation
    ENDTIME=$(date +%s)
    DIFF=$(( $ENDTIME - $STARTTIME ))
    DIFF=$(( $DIFF / 60 ))
    echo "Simulation time: $DIFF minutes"

     echo
    echo "Moving trace files into subdirectory..."
    mkdir -p $RESULTS_DIR
    mv -f $SCRIPTS_DIR/*.nam $RESULTS_DIR/
    mv -f $SCRIPTS_DIR/*.tr $RESULTS_DIR/
    cp -f $SCRIPTS_DIR/*.sh $RESULTS_DIR/
    cp -f $SCRIPTS_DIR/*.py $RESULTS_DIR/


echo "Done with all simulations. Now generating the graphs"
 
 cd $RESULTS_DIR/
 ./draw_queue.sh 
 ./draw_drop.sh $nodes 2
 ./draw_inst_goodput.sh $nodes 
 ./draw_persistent.sh $nodes
 ./draw_utilization.sh
 ./draw_draw.sh $nodes
./draw_goodput.sh $nodes

mv -f $ROOT_DIR/*.log $RESULTS_DIR/

