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
      asset_id_lst:
        label: asset_id_lst
        doc: asset_id_lst
        type: string
        default: lst
      band:
        label: band
        doc: band
        type: long
        default: 1
      ndv:
        label: ndv
        doc: ndv
        type: long
        default: 0
      output_format:
        label: output_format
        doc: output_format
        type: string
        default: zarr
      savename:
        label: savename
        doc: savename
        type: string
        default: ''
    outputs:
      - id: stac_catalog
        type: Directory
        outputSource:
          - run_script/results
    steps:
      run_script:
        run: '#xce_script'
        in:
          asset_id_lst: asset_id_lst
          band: band
          ndv: ndv
          output_format: output_format
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
      asset_id_lst:
        label: asset_id_lst
        doc: asset_id_lst
        type: string
        default: lst
        inputBinding:
          prefix: --asset-id-lst
      band:
        label: band
        doc: band
        type: long
        default: 1
        inputBinding:
          prefix: --band
      lst:
        label: lst
        doc: lst
        type: Directory
        default: null
        inputBinding:
          prefix: --lst
      ndv:
        label: ndv
        doc: ndv
        type: long
        default: 0
        inputBinding:
          prefix: --ndv
      output_format:
        label: output_format
        doc: output_format
        type: string
        default: zarr
        inputBinding:
          prefix: --output-format
      savename:
        label: savename
        doc: savename
        type: string
        default: ''
        inputBinding:
          prefix: --savename
    outputs:
      results:
        type: Directory
        outputBinding:
          glob: .
