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
      day:
        label: day
        doc: day
        type: long
        default: 18
      latitude:
        label: latitude
        doc: latitude
        type: double
        default: 37.98381
      longitude:
        label: longitude
        doc: longitude
        type: double
        default: 23.727539
      lst_day_band:
        label: lst_day_band
        doc: lst_day_band
        type: long
        default: 7
      lst_day_ndv:
        label: lst_day_ndv
        doc: lst_day_ndv
        type: long
        default: -9999
      lst_night_band:
        label: lst_night_band
        doc: lst_night_band
        type: long
        default: 7
      lst_night_ndv:
        label: lst_night_ndv
        doc: lst_night_ndv
        type: long
        default: -9999
      month:
        label: month
        doc: month
        type: long
        default: 7
      output_format:
        label: output_format
        doc: output_format
        type: string
        default: zarr
      refl_ndv:
        label: refl_ndv
        doc: refl_ndv
        type: long
        default: -9999
      savename:
        label: savename
        doc: savename
        type: string
        default: ''
      year:
        label: year
        doc: year
        type: long
        default: 2009
    outputs:
      - id: stac_catalog
        type: Directory
        outputSource:
          - run_script/results
    steps:
      run_script:
        run: '#xce_script'
        in:
          day: day
          latitude: latitude
          longitude: longitude
          lst_day_band: lst_day_band
          lst_day_ndv: lst_day_ndv
          lst_night_band: lst_night_band
          lst_night_ndv: lst_night_ndv
          month: month
          output_format: output_format
          refl_ndv: refl_ndv
          savename: savename
          year: year
        out:
          - results
  - class: CommandLineTool
    id: xce_script
    requirements:
      DockerRequirement:
        dockerPull: ghcr.io/esa-heatwise/lstm-wp3-products-inertia:latest
    hints:
      DockerRequirement:
        dockerPull: ghcr.io/esa-heatwise/lstm-wp3-products-inertia:latest
    baseCommand:
      - /usr/local/bin/_entrypoint.sh
      - python
      - /home/mambauser/execute.py
    arguments:
      - --batch
      - --eoap
    inputs:
      day:
        label: day
        doc: day
        type: long
        default: 18
        inputBinding:
          prefix: --day
      latitude:
        label: latitude
        doc: latitude
        type: double
        default: 37.98381
        inputBinding:
          prefix: --latitude
      longitude:
        label: longitude
        doc: longitude
        type: double
        default: 23.727539
        inputBinding:
          prefix: --longitude
      lst_day_band:
        label: lst_day_band
        doc: lst_day_band
        type: long
        default: 7
        inputBinding:
          prefix: --lst-day-band
      lst_day_ndv:
        label: lst_day_ndv
        doc: lst_day_ndv
        type: long
        default: -9999
        inputBinding:
          prefix: --lst-day-ndv
      lst_night_band:
        label: lst_night_band
        doc: lst_night_band
        type: long
        default: 7
        inputBinding:
          prefix: --lst-night-band
      lst_night_ndv:
        label: lst_night_ndv
        doc: lst_night_ndv
        type: long
        default: -9999
        inputBinding:
          prefix: --lst-night-ndv
      month:
        label: month
        doc: month
        type: long
        default: 7
        inputBinding:
          prefix: --month
      output_format:
        label: output_format
        doc: output_format
        type: string
        default: zarr
        inputBinding:
          prefix: --output-format
      refl_ndv:
        label: refl_ndv
        doc: refl_ndv
        type: long
        default: -9999
        inputBinding:
          prefix: --refl-ndv
      savename:
        label: savename
        doc: savename
        type: string
        default: ''
        inputBinding:
          prefix: --savename
      year:
        label: year
        doc: year
        type: long
        default: 2009
        inputBinding:
          prefix: --year
    outputs:
      results:
        type: Directory
        outputBinding:
          glob: .
