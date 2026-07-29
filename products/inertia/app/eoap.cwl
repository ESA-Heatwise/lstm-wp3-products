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
      lst_day_fpath:
        label: lst_day_fpath
        doc: lst_day_fpath
        type: string
        default: https://eoresults.esa.int/d/CHIME_and_LSTM_mimicked_reflectances_over_land_HEATWISE/2009/07/18/athens-center-lstm/Athens_Center_LSTM_Thermopolis_090718_day_50m.tif
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
      lst_night_fpath:
        label: lst_night_fpath
        doc: lst_night_fpath
        type: string
        default: https://eoresults.esa.int/d/CHIME_and_LSTM_mimicked_reflectances_over_land_HEATWISE/2009/07/18/athens-center-lstm/Athens_Center_LSTM_Thermopolis_090718_night_50m.tif
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
      refl_fpath:
        label: refl_fpath
        doc: refl_fpath
        type: string
        default: https://eoresults.esa.int/d/CHIME_and_LSTM_mimicked_reflectances_over_land_HEATWISE/2009/07/18/athens-center-chime/Athens_Center_CHIME_Thermopolis_090718.tif
      refl_ndv:
        label: refl_ndv
        doc: refl_ndv
        type: long
        default: -9999
      savename:
        label: savename
        doc: savename
        type: string
        default: hw_ati_demo.tif
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
          lst_day_fpath: lst_day_fpath
          lst_day_ndv: lst_day_ndv
          lst_night_band: lst_night_band
          lst_night_fpath: lst_night_fpath
          lst_night_ndv: lst_night_ndv
          month: month
          refl_fpath: refl_fpath
          refl_ndv: refl_ndv
          savename: savename
          year: year
        out:
          - results
  - class: CommandLineTool
    id: xce_script
    requirements:
      DockerRequirement:
        dockerPull: hw-inertia:1
    hints:
      DockerRequirement:
        dockerPull: hw-inertia:1
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
      lst_day_fpath:
        label: lst_day_fpath
        doc: lst_day_fpath
        type: string
        default: https://eoresults.esa.int/d/CHIME_and_LSTM_mimicked_reflectances_over_land_HEATWISE/2009/07/18/athens-center-lstm/Athens_Center_LSTM_Thermopolis_090718_day_50m.tif
        inputBinding:
          prefix: --lst-day-fpath
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
      lst_night_fpath:
        label: lst_night_fpath
        doc: lst_night_fpath
        type: string
        default: https://eoresults.esa.int/d/CHIME_and_LSTM_mimicked_reflectances_over_land_HEATWISE/2009/07/18/athens-center-lstm/Athens_Center_LSTM_Thermopolis_090718_night_50m.tif
        inputBinding:
          prefix: --lst-night-fpath
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
      refl_fpath:
        label: refl_fpath
        doc: refl_fpath
        type: string
        default: https://eoresults.esa.int/d/CHIME_and_LSTM_mimicked_reflectances_over_land_HEATWISE/2009/07/18/athens-center-chime/Athens_Center_CHIME_Thermopolis_090718.tif
        inputBinding:
          prefix: --refl-fpath
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
        default: hw_ati_demo.tif
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
