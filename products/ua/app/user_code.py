import unittest.mock
get_ipython = unittest.mock.MagicMock
#!/usr/bin/env python
# coding: utf-8

# # Combined WP3 product

# In[ ]:


xcengine_config = {
    "workflow_id": "heatwise_inertia",
    "environment_file": "environment.yml",
    "container_image_tag": "hw-uacomb:1",
}

fpath_ua = "./data/UA2021_Sepolia.gpkg"
fpath_mat = "./data/Sepolia_material_label_dominant.tif"
fpath_hcspots = "./data/Sepolia_Thermopolis_LST-N_Clusters.tif"

band_hotspot = 2
material_ndv = 0
material_legend = "asphalt,concrete,terracotta,vegetation,metal"  # A string containing the materials.

savename = "hw_combined_sepolia.gpkg"


# In[ ]:


__xce_set_params()


# In[ ]:


import geopandas as gpd
import numpy as np
import pandas as pd
import rasterio as rio
from rasterstats import zonal_stats
from pathlib import Path

# Step 1: Load the UA as a GeoDataFrame and get its CRS.
# It is assumed that the UA already and the raster data overlap.
ua = gpd.read_file(fpath_ua)
crs_ua = ua.crs.to_wkt()

# Step 2: Add the dominant material %-fraction as attributes to the UA
with rio.open(fpath_mat) as src:
    materials_n = np.unique(src.read(1))
    tf = src.transform
    ua = ua.to_crs(src.crs)

material_names = material_legend.split(",")
if len(material_names) + 1 == materials_n.size:
    material_names = {i: name for i, name in enumerate(material_names, start=1)}
else:
    material_names = {i: f"material_{i}" for i in range(1, materials_n.size)}

stats = zonal_stats(
    ua,
    fpath_mat,
    categorical=True,
    category_map=material_names,
    nodata=material_ndv,
)

df = pd.DataFrame(stats).fillna(0)
df = df.div(df.sum(axis=1), axis=0) * 100  # Convert counts to percentages
ua = ua.merge(df, left_index=True, right_index=True)

# Step 3: add the hotspot %-fraction as attributes to the UA
stats = zonal_stats(
    ua,
    fpath_hcspots,
    band=band_hotspot,
    categorical=True,
    category_map={0: "normal", 1: "hotspot"},
    nodata=-9999, 
)

df = pd.DataFrame(stats).fillna(0)
df = df.div(df.sum(axis=1), axis=0) * 100  # Convert counts to percentages
ua = ua.merge(df, left_index=True, right_index=True)

# Step 4: Save updated UA dataset
ua = ua.to_crs(crs_ua)
ua.to_file(Path("./data") / savename)

