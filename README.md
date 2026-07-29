# SUP-HeatWise Products as EOAP applications

This repository contains the three LSTM-based SUP-Heatwise product as application packages, under the `products/` folder. Each package includes a small application, environment setup, run scripts, and example data for a specific heat-related analysis.

## Products

- `products/hotspots`: Cold- and hot-spot detection.
  - Includes `run.sh`, `build.sh`, `environment.yml`, a Jupyter notebook (`hotspot_detection.ipynb`), and an `app/` directory for the EOAP application.
  - Contains supporting `data/` files for hotspot processing.
  - Notebook developed by IK and CTK.

- `products/inertia`: Estimate the Apparent Thermal inertia.
  - Includes `run.sh`, `build.sh`, `environment.yml`, two notebooks (`heatwise_inertia.ipynb` and `heatwise_inertia_KIR.ipynb`), and an `app/` directory for the EOAP application.
  - Contains supporting `data/` files.
  - Notebook developed by IK and CTK.

- `products/ua`: Update the UA polygons with the material abundances and hot/cold-spot information.
  - Includes `run.sh`, `build.sh`, `environment.yml`, a notebook (`ua_attrs.ipynb`), and an `app/` directory for the EOAP application.
  - Contains supporting `data/` files.
  - Notebook developed by PS.

## Structure

Each product package follows a similar layout:

- `app/` — application code and EOAP-related workflow definitions.
- `environment.yml` — conda environment specification.
- `run.sh` — wrapper to execute the package.
- `build.sh` — build helper script.
- `data/` — example or required data files.

To build the EOAP applications, [`xcengine`](https://github.com/xcube-dev/xcengine) is required.
