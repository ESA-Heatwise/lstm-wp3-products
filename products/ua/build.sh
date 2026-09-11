#!/bin/bash

NOTEBOOK=ua_attrs.ipynb

WORKDIR=$(pwd)
SAVEDIR=$WORKDIR/app
mkdir -p $SAVEDIR

xcetool image build --build-dir $SAVEDIR --tag ghcr.io/esa-heatwise/lstm-wp3-products-ua:latest -e $WORKDIR/environment.yml -a $SAVEDIR/eoap.cwl $WORKDIR/$NOTEBOOK
