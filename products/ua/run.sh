WORKDIR=$(pwd)
SAVEDIR=$WORKDIR/data
mkdir -p $SAVEDIR

docker run --rm -v $SAVEDIR:/home/mambauser/data hw-uacomb:1