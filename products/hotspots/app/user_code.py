import unittest.mock
get_ipython = unittest.mock.MagicMock
#!/usr/bin/env python
# coding: utf-8

# # Hot- and cold-spot detection using majority voting

# In[ ]:


from pathlib import Path


# In[ ]:


xcengine_config = {
    "workflow_id": "hotspot_detection",
    "environment_file": "environment.yml",
    "container_image_tag": "ghcr.io/esa-heatwise/lstm-wp3-products-hotspots:latest",
}

band = 1
ndv = 0
output_format = "zarr"
savename = "" # "hw_lst_clusters_demo.tif"

lst: "EOInput" = Path("./inputs/lst")
asset_id_lst = "lst"


# In[ ]:


__xce_set_params()


# Main Code:

# In[ ]:


"""Hot- and cold-spot detection using majority voting."""

import pystac
import numpy as np
import rasterio as rio
from scipy.stats import kurtosis, skew
from sklearn.ensemble import (
    AdaBoostRegressor,
    GradientBoostingRegressor,
    RandomForestRegressor,
)
from sklearn.linear_model import ElasticNet, Lasso, Ridge, RidgeCV
from sklearn.neighbors import KNeighborsRegressor
from sklearn.neural_network import MLPRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVR, LinearSVR
from sklearn.tree import DecisionTreeRegressor
from xgboost import XGBRegressor
from skimage import morphology
import xarray as xr
import rioxarray


WINDOW_SIZES = [15, 51]


def extract_assets_from_catalog(catalog: pystac.Catalog, asset_key: str) -> list[pystac.Asset]:
    """
    Returns all assets with a given key from the items of a catalog.
    """
    assets = []
    for item in catalog.get_all_items():
        if (asset := item.assets.get(asset_key)) is not None:
            assets.append(asset)

    return assets


def get_catalog(inp: Path | str) -> pystac.Catalog:
    p = Path(inp) / "catalog.json"
    catalog = pystac.Catalog.from_file(p)
    catalog.make_all_asset_hrefs_absolute()
    return catalog


def compute_window_features(temp, x, y, window_size=3):
    """Compute 15 statistical features from a window."""
    half_window = window_size // 2

    x_min = max(x - half_window, 0)
    x_max = min(x + half_window + 1, temp.shape[1])
    y_min = max(y - half_window, 0)
    y_max = min(y + half_window + 1, temp.shape[0])

    window = temp[y_min:y_max, x_min:x_max]

    mean = np.nanmean(window)
    std = np.nanstd(window)
    min_val = np.nanmin(window)
    max_val = np.nanmax(window)
    kurt = kurtosis(window.flatten(), nan_policy="omit")
    skewness = skew(window.flatten(), nan_policy="omit")
    median = np.nanmedian(window)
    q25 = np.nanpercentile(window, 25)
    q75 = np.nanpercentile(window, 75)
    iqr = q75 - q25
    range_val = max_val - min_val
    total_sum = np.nansum(window)
    variance = np.nanvar(window)
    count_non_nan = np.count_nonzero(~np.isnan(window))

    features = [
        mean,
        std,
        min_val,
        max_val,
        kurt,
        skewness,
        median,
        q25,
        q75,
        iqr,
        range_val,
        total_sum,
        variance,
        count_non_nan,
    ]
    return features

catalog_lst = get_catalog(lst)
print(catalog_lst)
fpath = next(iter(extract_assets_from_catalog(catalog_lst, asset_id_lst))).href

with rio.open(fpath) as ds:
    temp = ds.read(band)
    profile = ds.profile
    lonlat_bounds = rio.warp.transform_bounds(
        ds.crs,
        "EPSG:4326",
        *ds.bounds
    )

temp = temp.astype(float)
temp[temp == ndv] = np.nan

rows, cols = temp.shape
values = temp.ravel()

valid_mask = ~np.isnan(values)
y_train = values[valid_mask]

hot_spots = []
cold_spots  = []

for window_size in WINDOW_SIZES:

    # Prepare the feature matrix
    features = []
    for y in range(rows):
        for x in range(cols):
            # Skip invalid data (NaNs)
            if np.isnan(temp[y, x]):
                continue
            # Compute features for each pixel using the window
            window_features = compute_window_features(temp, x, y, window_size=window_size)
            features.append(window_features)

    features = np.array(features)

    scaler = StandardScaler()
    features_scaled = scaler.fit_transform(features)

    # Models to evaluate
    models = {
        "DecisionTree": DecisionTreeRegressor(random_state=42),
        "SVM": SVR(kernel="rbf", C=1e3, gamma=0.1),
        "RandomForest": RandomForestRegressor(
            n_estimators=100,
            max_depth=10,
            random_state=42,
        ),
        "KNeighbors": KNeighborsRegressor(n_neighbors=5),
        "GradientBoosting": GradientBoostingRegressor(
            n_estimators=100,
            max_depth=3,
            random_state=42,
        ),
        "LinearSVR": LinearSVR(C=1.0, max_iter=10000, tol=1e-1),
        "ElasticNet": ElasticNet(alpha=1.0, l1_ratio=0.5),
        "Lasso": Lasso(alpha=0.1),
        "RidgeCV": RidgeCV(),
        "AdaBoost": AdaBoostRegressor(n_estimators=100),
        "XGBoost": XGBRegressor(n_estimators=100, max_depth=3, learning_rate=0.1),
        "MLP": MLPRegressor(
            hidden_layer_sizes=(50, 50),
            max_iter=1000,
            random_state=42,
        ),
    }

    model_predictions = {}
    for model_name, model in models.items():
        print(f"Training {model_name}...")
        model.fit(features_scaled, y_train)
        model_predictions[model_name] = model.predict(features_scaled)

    # Initialize an empty grid to store predictions
    predicted_grids = {
        model_name: np.full((rows, cols), np.nan) for model_name in models
    }

    # Loop through each model's predictions and insert them into the grid at the correct locations
    for model_name, pred in model_predictions.items():
        valid_indices = np.where(~np.isnan(temp))
        # Convert the valid (row, col) indices to a 1D index and 
        # place the predictions into the correct positions in the grid
        valid_1d_indices = np.ravel_multi_index(valid_indices, (rows, cols))
        predicted_grids[model_name].ravel()[valid_1d_indices] = pred

    residuals_dict = {}
    z_scores_dict = {}

    for model_name, predicted_surface in predicted_grids.items():
        predicted_surface_resized = np.resize(predicted_surface, temp.shape)

        residuals = temp - predicted_surface_resized
        residual_flat = residuals[~np.isnan(residuals)]

        std_residual = np.std(residual_flat)
        if std_residual == 0:
            z_scores = np.zeros_like(residuals)  # If std is 0, set all z-scores to 0
        else:
            z_scores = residuals / std_residual

        residuals_dict[model_name] = residuals
        z_scores_dict[model_name] = z_scores

    hot_spots_dict = {}
    cold_spots_dict = {}

    for model_name, z_scores in z_scores_dict.items():
        mask = z_scores > 1
        hot_spots_dict[model_name] = morphology.remove_small_objects(mask, max_size=1)
        mask = z_scores < -1
        cold_spots_dict[model_name] = morphology.remove_small_objects(mask, max_size=1)

    hot_votes = np.array(list(hot_spots_dict.values())).sum(axis=0)
    cold_votes = np.array(list(cold_spots_dict.values())).sum(axis=0)

    # Combine the results from the different models using majority voting (1 for hot/cold spot, 0 for normal)
    hot_spots.append(hot_votes > len(models) // 2)
    cold_spots.append(cold_votes > len(models) // 2)

# Combine the results from the two moving windows
hot_spots_combined = np.logical_or(*hot_spots)
cold_spots_combined = np.logical_or(*cold_spots)

profile.update(dtype=rio.uint8, nodata=0, count=2)


# In[ ]:


# define xarray dataset (output of the EOAP)
dims = ("y", "x")
hw_lst_clusters = xr.Dataset(
    {
        "lst_coldspots": (
            dims, cold_spots_combined.astype(profile["dtype"]),
        ),
        "lst_hotspots": (
            dims, hot_spots_combined.astype(profile["dtype"]),
        ),
    }
)

hw_lst_clusters.rio.write_crs(profile["crs"], inplace=True)
hw_lst_clusters.rio.write_transform(profile["transform"], inplace=True)
hw_lst_clusters["lst_coldspots"].rio.write_nodata(profile.get("nodata"), inplace=True)
hw_lst_clusters["lst_hotspots"].rio.write_nodata(profile.get("nodata"), inplace=True)
hw_lst_clusters.attrs["xcengine_output_format"] = output_format
hw_lst_clusters.attrs["geospatial_lon_min"] = lonlat_bounds[0]
hw_lst_clusters.attrs["geospatial_lon_max"] = lonlat_bounds[2]
hw_lst_clusters.attrs["geospatial_lat_min"] = lonlat_bounds[1]
hw_lst_clusters.attrs["geospatial_lat_max"] = lonlat_bounds[3]
hw_lst_clusters.rio.set_spatial_dims(x_dim="x", y_dim="y", inplace=True)


# In[ ]:


# Save as tiff (when running docker by hand)
if savename:
    with rio.open(Path("./output") / savename, "w", **profile) as dst:
        dst.write(cold_spots_combined.astype(rio.uint8), 1)
        dst.set_band_description(1, "lst_coldspots")
        dst.write(hot_spots_combined.astype(rio.uint8), 2)
        dst.set_band_description(2, "lst_hotspots")

