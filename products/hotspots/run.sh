WORKDIR=$(pwd)
SAVEDIR=$WORKDIR/data
mkdir -p $SAVEDIR

docker run --rm --user "$(id -u):$(id -g)" -v $SAVEDIR:/home/mambauser/output hw-lst-clusters:1 $@
