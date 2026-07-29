#!/bin/bash

NOTEBOOK=ua_attrs.ipynb

WORKDIR=$(pwd)
SAVEDIR=$WORKDIR/app
mkdir -p $SAVEDIR

xcetool image build --build-dir $SAVEDIR --tag hw-uacomb:1 -e $WORKDIR/environment.yml -a $SAVEDIR/eoap.cwl $WORKDIR/$NOTEBOOK
