cwlVersion: v1.0
$namespaces:
  s: https://schema.org/
s:version: 1.0.0
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
        dockerPull: ghcr.io/esa-heatwise/lstm-wp3-products-hotspots:latest
    hints:
      DockerRequirement:
        dockerPull: ghcr.io/esa-heatwise/lstm-wp3-products-hotspots:latest
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
        default: 1
        inputBinding:
          prefix: --band
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
