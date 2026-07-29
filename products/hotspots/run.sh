WORKDIR=$(pwd)
SAVEDIR=$WORKDIR/data
mkdir -p $SAVEDIR

docker run --rm -v $SAVEDIR:/home/mambauser/output hw-lst-clusters:1