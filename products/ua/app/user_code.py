import unittest.mock
get_ipython = unittest.mock.MagicMock
#!/usr/bin/env python
# coding: utf-8

# # Combined WP3 product

# In[1]:


from pathlib import Path


# In[ ]:


xcengine_config = {
    "workflow_id": "heatwise_combined",
    "environment_file": "environment.yml",
    "container_image_tag": "ghcr.io/esa-heatwise/lstm-wp3-products-ua:latest",
}

urban_atlas: "EOInput" = Path("./inputs/urban_atlas")
asset_id_ua = "ua"
material_labels: "EOInput" = Path("./inputs/material_labels")
asset_id_mat = "mat"
hcspots: "EOInput" = Path("./inputs/hcspots")
asset_id_hcspots = "hcspots"

band_hotspot = 2
material_ndv = 0
material_legend = "asphalt,concrete,terracotta,vegetation,metal"  # A string containing the materials.

savename = "hw_combined_sepolia.gpkg"


# In[ ]:


__xce_set_params()


# In[3]:


from pathlib import Path
import pystac


# In[4]:


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


# In[5]:


catalog_ua = get_catalog(urban_atlas)
catalog_mat = get_catalog(material_labels)
catalog_hcspots = get_catalog(hcspots)

fpath_ua = next(iter(extract_assets_from_catalog(catalog_ua, asset_id_ua))).href
fpath_mat = next(iter(extract_assets_from_catalog(catalog_mat, asset_id_mat))).href
fpath_hcspots = next(iter(extract_assets_from_catalog(catalog_hcspots, asset_id_hcspots))).href


# In[6]:


import geopandas as gpd
import numpy as np
import pandas as pd
import rasterio as rio
from rasterstats import zonal_stats
from pathlib import Path
import pystac
from datetime import datetime, timezone

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
base_path = Path("./datasets_saved")
base_path.mkdir(exist_ok=True, parents=True)
ua.to_file( base_path / savename)


# In[7]:


def generate_stac(gdf: gpd.GeoDataFrame):
    geometry = gdf.to_crs("EPSG:4327").geometry.dropna()
    layout_strategy = pystac.layout.CustomLayoutStrategy(
            item_func=lambda item, parent: Path(parent) / base_path.name / f"{item.id}.json"
        )
    item = pystac.Item(
        "urban_atlas_with_hotspots",
        geometry=geometry.__geo_interface__,
        bbox=geometry.union_all().bounds,
        datetime=datetime.now(tz=timezone.utc),
        properties={},
    )
    catalog = pystac.Catalog("catalog", "Urban Atlas with Hotspots", strategy=layout_strategy, catalog_type = pystac.CatalogType.SELF_CONTAINED)
    catalog.add_item(item)
    catalog.normalize_and_save("catalog.json")



# In[8]:


# Step 5: Generate output STAC documents (done by hand, because xcengine does not support vector output)
generate_stac(ua)

