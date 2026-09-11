WORKDIR=$(pwd)
SAVEDIR=$WORKDIR/data
mkdir -p $SAVEDIR

docker run --rm -v $SAVEDIR:/home/mambauser/data ghcr.io/esa-heatwise/lstm-wp3-products-ua:latest
