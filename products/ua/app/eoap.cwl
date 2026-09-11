cwlVersion: v1.0
$namespaces:
  s: https://schema.org/
s:version: 1.0.0
s:softwareVersion: 1.0.0
schemas:
  - http://schema.org/version/9.0/schemaorg-current-http.rdf
$graph:
  - class: Workflow
    id: heatwise_combined
    label: xcengine notebook
    doc: xcengine notebook
    requirements: []
    inputs:
      asset_id_hcspots:
        label: asset_id_hcspots
        doc: asset_id_hcspots
        type: string
        default: hcspots
      asset_id_mat:
        label: asset_id_mat
        doc: asset_id_mat
        type: string
        default: mat
      asset_id_ua:
        label: asset_id_ua
        doc: asset_id_ua
        type: string
        default: ua
      band_hotspot:
        label: band_hotspot
        doc: band_hotspot
        type: long
        default: 2
      hcspots:
        label: hcspots
        doc: hcspots
        type: Directory
        default: null
      material_labels:
        label: material_labels
        doc: material_labels
        type: Directory
        default: null
      material_legend:
        label: material_legend
        doc: material_legend
        type: string
        default: asphalt,concrete,terracotta,vegetation,metal
      material_ndv:
        label: material_ndv
        doc: material_ndv
        type: long
        default: 0
      savename:
        label: savename
        doc: savename
        type: string
        default: hw_combined_sepolia.gpkg
      urban_atlas:
        label: urban_atlas
        doc: urban_atlas
        type: Directory
        default: null
    outputs:
      - id: stac_catalog
        type: Directory
        outputSource:
          - run_script/results
    steps:
      run_script:
        run: '#xce_script'
        in:
          asset_id_hcspots: asset_id_hcspots
          asset_id_mat: asset_id_mat
          asset_id_ua: asset_id_ua
          band_hotspot: band_hotspot
          hcspots: hcspots
          material_labels: material_labels
          material_legend: material_legend
          material_ndv: material_ndv
          savename: savename
          urban_atlas: urban_atlas
        out:
          - results
  - class: CommandLineTool
    id: xce_script
    requirements:
      DockerRequirement:
        dockerPull: ghcr.io/ESA-Heatwise/lstm-wp3-products-ua:latest
    hints:
      DockerRequirement:
        dockerPull: ghcr.io/ESA-Heatwise/lstm-wp3-products-ua:latest
    baseCommand:
      - /usr/local/bin/_entrypoint.sh
      - python
      - /home/mambauser/execute.py
    arguments:
      - --batch
      - --eoap
    inputs:
      asset_id_hcspots:
        label: asset_id_hcspots
        doc: asset_id_hcspots
        type: string
        default: hcspots
        inputBinding:
          prefix: --asset-id-hcspots
      asset_id_mat:
        label: asset_id_mat
        doc: asset_id_mat
        type: string
        default: mat
        inputBinding:
          prefix: --asset-id-mat
      asset_id_ua:
        label: asset_id_ua
        doc: asset_id_ua
        type: string
        default: ua
        inputBinding:
          prefix: --asset-id-ua
      band_hotspot:
        label: band_hotspot
        doc: band_hotspot
        type: long
        default: 2
        inputBinding:
          prefix: --band-hotspot
      hcspots:
        label: hcspots
        doc: hcspots
        type: Directory
        default: null
        inputBinding:
          prefix: --hcspots
      material_labels:
        label: material_labels
        doc: material_labels
        type: Directory
        default: null
        inputBinding:
          prefix: --material-labels
      material_legend:
        label: material_legend
        doc: material_legend
        type: string
        default: asphalt,concrete,terracotta,vegetation,metal
        inputBinding:
          prefix: --material-legend
      material_ndv:
        label: material_ndv
        doc: material_ndv
        type: long
        default: 0
        inputBinding:
          prefix: --material-ndv
      savename:
        label: savename
        doc: savename
        type: string
        default: hw_combined_sepolia.gpkg
        inputBinding:
          prefix: --savename
      urban_atlas:
        label: urban_atlas
        doc: urban_atlas
        type: Directory
        default: null
        inputBinding:
          prefix: --urban-atlas
    outputs:
      results:
        type: Directory
        outputBinding:
          glob: .
