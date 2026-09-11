WORKDIR=$(pwd)
INPUTDIR=$WORKDIR/inputs
SAVEDIR=$WORKDIR/data
DEFAULT_SAVENAME="hw_lst_clusters_demo.tif"
mkdir -p $SAVEDIR

docker run --rm --user "$(id -u):$(id -g)" -v $INPUTDIR:/home/mambauser/inputs -v $SAVEDIR:/home/mambauser/output ghcr.io/esa-heatwise/lstm-wp3-products-hotspots:latest --savename "$DEFAULT_SAVENAME" $@
