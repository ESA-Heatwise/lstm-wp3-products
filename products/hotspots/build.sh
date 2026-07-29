#!/bin/bash

NOTEBOOK=hotspot_detection.ipynb

WORKDIR=$(pwd)
SAVEDIR=$WORKDIR/app
mkdir -p $SAVEDIR

xcetool image build --build-dir $SAVEDIR --tag hw-lst-clusters:1 -e $WORKDIR/environment.yml -a $SAVEDIR/eoap.cwl $WORKDIR/$NOTEBOOK
