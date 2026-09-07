WORKDIR=$(pwd)
INPUTDIR=$WORKDIR/inputs
SAVEDIR=$WORKDIR/data
DEFAULT_SAVENAME="hw_lst_clusters_demo.tif"
mkdir -p $SAVEDIR

docker run --rm --user "$(id -u):$(id -g)" -v $INPUTDIR:/home/mambauser/inputs -v $SAVEDIR:/home/mambauser/output hw-lst-clusters:1 --savename "$DEFAULT_SAVENAME" $@
