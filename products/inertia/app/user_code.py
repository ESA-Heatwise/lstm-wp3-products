import unittest.mock
get_ipython = unittest.mock.MagicMock
#!/usr/bin/env python
# coding: utf-8

# # HW ATI Product

# In[ ]:


xcengine_config = {
    "workflow_id": "heatwise_inertia",
    "environment_file": "environment.yml",
    "container_image_tag": "hw-inertia:1",
}

lst_day_band = 7
lst_day_ndv = -9999

lst_night_band = 7
lst_night_ndv = -9999

refl_ndv = -9999

longitude = 23.727539
latitude = 37.983810

year = 2009
month = 7
day = 18

output_format = "zarr"
savename = ""


# In[ ]:


__xce_set_params()


# In[ ]:


# Apparent Thermal Inertia (ATI) calculation using Mandanici et al. (2024)
# method, as described in the paper: https://doi.org/10.1038/s41598-024-64371-3

import numpy as np
import pystac
import rasterio as rio
from rasterio import warp
from rasterio.enums import Resampling
import math
from datetime import datetime
from pvlib import solarposition
from pathlib import Path
import xarray as xr
import rioxarray


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


obs_date = datetime(year, month, day)

lst_day: "EOInput" = Path("./inputs/lst_day")
asset_id_lst_day = "lst_day"

lst_night: "EOInput" = Path("./inputs/lst_night")
asset_id_lst_night = "lst_night"

refl: "EOInput" = Path("./inputs/refl")
asset_id_refl = "refl"

catalog_lst_day = get_catalog(lst_day)
lst_day_fpath = next(iter(extract_assets_from_catalog(catalog_lst_day, asset_id_lst_day))).href

catalog_lst_night = get_catalog(lst_night)
lst_night_fpath = next(iter(extract_assets_from_catalog(catalog_lst_night, asset_id_lst_night))).href

catalog_refl = get_catalog(refl)
refl_fpath = next(iter(extract_assets_from_catalog(catalog_refl, asset_id_refl))).href


with rio.open(lst_day_fpath) as ds:  # Daytime LST
    LST_D = ds.read(lst_day_band)
    LST_D = LST_D.astype(float)
    LST_D[LST_D == lst_day_ndv] = np.nan
    LST_crs = ds.crs
    LST_tf = ds.transform
    profile_lst_D = ds.profile

with rio.open(lst_night_fpath) as ds:  # Nigttime LST (acquired at the same day as daytime LST)
    LST_N = ds.read(lst_night_band)
    LST_N = LST_N.astype(float)
    LST_N[LST_N == lst_night_ndv] = np.nan
    profile_lst_N = ds.profile

if profile_lst_D["transform"] != profile_lst_N["transform"]:
    raise SystemExit("Day and night LST rasters must have the same geotransform.")

if LST_D.shape != LST_N.shape:
    raise SystemExit("Day and night LST rasters must have the same shape.")
else:
    dtemp = LST_D - LST_N

with rio.open(refl_fpath) as ds:
    SR = ds.read()
    SR = SR.astype(float)
    SR_crs = ds.crs
    SR_tf = ds.transform
    SR[SR == refl_ndv] = np.nan
    profile_refl = ds.profile

    SR = np.ma.masked_invalid(SR)
    SR = SR.mean(axis=0)  # calculate the arithmetic instead of the weighthed mean.

    if SR.shape != LST_N.shape:
        SR_resampled = np.zeros(dtemp.shape, dtype=np.float32)

        warp.reproject(
            source=SR,
            destination=SR_resampled,
            src_transform=SR_tf,
            src_crs=SR_crs,
            src_nodata=np.nan,
            dst_transform=LST_tf,
            dst_crs=LST_crs,
            dst_nodata=np.nan,
            resampling=Resampling.cubic,
        )

        SR = SR_resampled

# Calculate S using Eq.3 from Mandanici et al. (2024)
sol_pos = solarposition.get_solarposition(obs_date, latitude, longitude)
delta = sol_pos["apparent_elevation"].iloc[0]  # Solar declination (in radians)

phi = math.radians(latitude)
delta = math.radians(delta)

part1 = math.sin(phi) * math.sin(delta)
part2 = math.sqrt(1.0 - math.tan(phi) * math.tan(phi) * math.tan(delta) * math.tan(delta))
part3 = math.cos(phi) * math.cos(delta) * math.acos(-math.tan(phi) * math.tan(delta))
S = part1 * part2 + part3

inertia = S * (1 - SR) / dtemp  # Eq.2 from Mandanici et al. (2024). Units: K^-1

profile_lst_D.update(dtype=rio.float32, nodata=np.nan, count=1)

# In[ ]:


# define xarray dataset (output of the EOAP)
dims = ("y", "x")
hw_ati = xr.Dataset(
    {
        "ati": (
            dims, inertia.astype(profile_lst_D["dtype"]),
        ),
    }
)

hw_ati.rio.write_crs(profile_lst_D["crs"], inplace=True)
hw_ati.rio.write_transform(profile_lst_D["transform"], inplace=True)
hw_ati["ati"].rio.write_nodata(profile_lst_D.get("nodata"), inplace=True)
hw_ati.attrs["xcengine_output_format"] = output_format
hw_ati.rio.set_spatial_dims(x_dim="x", y_dim="y", inplace=True)

# Save as tiff (when running docker by hand)
if savename:
    with rio.open(Path("./output") / savename, "w", **profile_lst_D) as dst:
        dst.write(inertia.astype(rio.float32), 1)

