cwlVersion: v1.0
$namespaces:
  s: https://schema.org/
s:softwareVersion: 1.0.0
schemas:
  - http://schema.org/version/9.0/schemaorg-current-http.rdf
$graph:
  - class: Workflow
    id: hotspot_detection
    label: xcengine notebook
    doc: xcengine notebook
    requirements: []
    inputs:
      band:
        label: band
        doc: band
        type: long
        default: 7
      fpath:
        label: fpath
        doc: fpath
        type: string
        default: https://eoresults.esa.int/d/CHIME_and_LSTM_mimicked_reflectances_over_land_HEATWISE/2025/03/08/athens-sepolia-lstm/Athens_Sepolia_LSTM_PRISMA_50m_v2.tif
      ndv:
        label: ndv
        doc: ndv
        type: long
        default: -9999
      savename:
        label: savename
        doc: savename
        type: string
        default: hw_lst_clusters_demo.tif
    outputs:
      - id: stac_catalog
        type: Directory
        outputSource:
          - run_script/results
    steps:
      run_script:
        run: '#xce_script'
        in:
          band: band
          fpath: fpath
          ndv: ndv
          savename: savename
        out:
          - results
  - class: CommandLineTool
    id: xce_script
    requirements:
      DockerRequirement:
        dockerPull: hw-lst-clusters:1
    hints:
      DockerRequirement:
        dockerPull: hw-lst-clusters:1
    baseCommand:
      - /usr/local/bin/_entrypoint.sh
      - python
      - /home/mambauser/execute.py
    arguments:
      - --batch
      - --eoap
    inputs:
      band:
        label: band
        doc: band
        type: long
        default: 7
        inputBinding:
          prefix: --band
      fpath:
        label: fpath
        doc: fpath
        type: string
        default: https://eoresults.esa.int/d/CHIME_and_LSTM_mimicked_reflectances_over_land_HEATWISE/2025/03/08/athens-sepolia-lstm/Athens_Sepolia_LSTM_PRISMA_50m_v2.tif
        inputBinding:
          prefix: --fpath
      ndv:
        label: ndv
        doc: ndv
        type: long
        default: -9999
        inputBinding:
          prefix: --ndv
      savename:
        label: savename
        doc: savename
        type: string
        default: hw_lst_clusters_demo.tif
        inputBinding:
          prefix: --savename
    outputs:
      results:
        type: Directory
        outputBinding:
          glob: .
