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

lst_day_fpath = "https://eoresults.esa.int/d/CHIME_and_LSTM_mimicked_reflectances_over_land_HEATWISE/2009/07/18/athens-center-lstm/Athens_Center_LSTM_Thermopolis_090718_day_50m.tif"
lst_day_band = 7
lst_day_ndv = -9999

lst_night_fpath = "https://eoresults.esa.int/d/CHIME_and_LSTM_mimicked_reflectances_over_land_HEATWISE/2009/07/18/athens-center-lstm/Athens_Center_LSTM_Thermopolis_090718_night_50m.tif"
lst_night_band = 7
lst_night_ndv = -9999

refl_fpath = "https://eoresults.esa.int/d/CHIME_and_LSTM_mimicked_reflectances_over_land_HEATWISE/2009/07/18/athens-center-chime/Athens_Center_CHIME_Thermopolis_090718.tif"
refl_ndv = -9999

longitude = 23.727539
latitude = 37.983810

year = 2009
month = 7
day = 18

savename = "hw_ati_demo.tif"


# In[ ]:


__xce_set_params()


# In[ ]:


# Apparent Thermal Inertia (ATI) calculation using Mandanici et al. (2024)
# method, as described in the paper: https://doi.org/10.1038/s41598-024-64371-3

import numpy as np
import rasterio as rio
from rasterio import warp
from rasterio.enums import Resampling
import math
from datetime import datetime
from pvlib import solarposition
from pathlib import Path


obs_date = datetime(year, month, day)

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
with rio.open(Path("./output") / savename, "w", **profile_lst_D) as dst:
  dst.write(inertia.astype(rio.float32), 1)

