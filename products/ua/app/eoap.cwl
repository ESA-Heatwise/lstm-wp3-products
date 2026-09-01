cwlVersion: v1.0
$namespaces:
  s: https://schema.org/
s:version: 1.0.0
s:softwareVersion: 1.0.0
schemas:
  - http://schema.org/version/9.0/schemaorg-current-http.rdf
$graph:
  - class: Workflow
    id: heatwise_inertia
    label: xcengine notebook
    doc: xcengine notebook
    requirements: []
    inputs:
      band_hotspot:
        label: band_hotspot
        doc: band_hotspot
        type: long
        default: 2
      fpath_hcspots:
        label: fpath_hcspots
        doc: fpath_hcspots
        type: File
        default: 
            class: File
            path: ../data/Sepolia_Thermopolis_LST-N_Clusters.tif
      fpath_mat:
        label: fpath_mat
        doc: fpath_mat
        type: File
        default: 
            class: File
            path: ../data/Sepolia_material_label_dominant.tif
      fpath_ua:
        label: fpath_ua
        doc: fpath_ua
        type: File
        default:
            class: File
            path: ../data/UA2021_Sepolia.gpkg
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
    outputs:
      - id: stac_catalog
        type: Directory
        outputSource:
          - run_script/results
    steps:
      run_script:
        run: '#xce_script'
        in:
          band_hotspot: band_hotspot
          fpath_hcspots: fpath_hcspots
          fpath_mat: fpath_mat
          fpath_ua: fpath_ua
          material_legend: material_legend
          material_ndv: material_ndv
          savename: savename
        out:
          - results
  - class: CommandLineTool
    id: xce_script
    requirements:
      DockerRequirement:
        dockerPull: hw-uacomb:1
    hints:
      DockerRequirement:
        dockerPull: hw-uacomb:1
    baseCommand:
      - /usr/local/bin/_entrypoint.sh
      - python
      - /home/mambauser/execute.py
    arguments:
      - --batch
      - --eoap
    inputs:
      band_hotspot:
        label: band_hotspot
        doc: band_hotspot
        type: long
        default: 2
        inputBinding:
          prefix: --band-hotspot
      fpath_hcspots:
        label: fpath_hcspots
        doc: fpath_hcspots
        type: File
        default: ./data/Sepolia_Thermopolis_LST-N_Clusters.tif
        inputBinding:
          prefix: --fpath-hcspots
      fpath_mat:
        label: fpath_mat
        doc: fpath_mat
        type: File
        default: ./data/Sepolia_material_label_dominant.tif
        inputBinding:
          prefix: --fpath-mat
      fpath_ua:
        label: fpath_ua
        doc: fpath_ua
        type: File
        default: ./data/UA2021_Sepolia.gpkg
        inputBinding:
          prefix: --fpath-ua
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
    outputs:
      results:
        type: Directory
        outputBinding:
          glob: .
