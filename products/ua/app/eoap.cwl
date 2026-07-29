cwlVersion: v1.0
$namespaces:
  s: https://schema.org/
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
      MIN_CLUSTER_SIZE:
        label: MIN_CLUSTER_SIZE
        doc: MIN_CLUSTER_SIZE
        type: long
        default: 3
      PERCENTILE:
        label: PERCENTILE
        doc: PERCENTILE
        type: long
        default: 90
      RADIUS:
        label: RADIUS
        doc: RADIUS
        type: long
        default: 150
      abund_ndv:
        label: abund_ndv
        doc: abund_ndv
        type: long
        default: -9999
      fpath_abund:
        label: fpath_abund
        doc: fpath_abund
        type: string
        default: ./data/Athens_Sepolia_abundances.tif
      fpath_hcspots:
        label: fpath_hcspots
        doc: fpath_hcspots
        type: string
        default: ./data/hot_cold_spots_Sepolia_night_15x15.tif
      fpath_ua:
        label: fpath_ua
        doc: fpath_ua
        type: string
        default: ./data/Sepolia_UA2012.gpkg
      materials:
        label: materials
        doc: materials
        type: string
        default: ''
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
          MIN_CLUSTER_SIZE: MIN_CLUSTER_SIZE
          PERCENTILE: PERCENTILE
          RADIUS: RADIUS
          abund_ndv: abund_ndv
          fpath_abund: fpath_abund
          fpath_hcspots: fpath_hcspots
          fpath_ua: fpath_ua
          materials: materials
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
      MIN_CLUSTER_SIZE:
        label: MIN_CLUSTER_SIZE
        doc: MIN_CLUSTER_SIZE
        type: long
        default: 3
        inputBinding:
          prefix: --MIN-CLUSTER-SIZE
      PERCENTILE:
        label: PERCENTILE
        doc: PERCENTILE
        type: long
        default: 90
        inputBinding:
          prefix: --PERCENTILE
      RADIUS:
        label: RADIUS
        doc: RADIUS
        type: long
        default: 150
        inputBinding:
          prefix: --RADIUS
      abund_ndv:
        label: abund_ndv
        doc: abund_ndv
        type: long
        default: -9999
        inputBinding:
          prefix: --abund-ndv
      fpath_abund:
        label: fpath_abund
        doc: fpath_abund
        type: string
        default: ./data/Athens_Sepolia_abundances.tif
        inputBinding:
          prefix: --fpath-abund
      fpath_hcspots:
        label: fpath_hcspots
        doc: fpath_hcspots
        type: string
        default: ./data/hot_cold_spots_Sepolia_night_15x15.tif
        inputBinding:
          prefix: --fpath-hcspots
      fpath_ua:
        label: fpath_ua
        doc: fpath_ua
        type: string
        default: ./data/Sepolia_UA2012.gpkg
        inputBinding:
          prefix: --fpath-ua
      materials:
        label: materials
        doc: materials
        type: string
        default: ''
        inputBinding:
          prefix: --materials
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
