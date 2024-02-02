#!/usr/bin/env cwl-runner
cwlVersion: v1.1
class: Workflow
label: Workflow that executes the SBG L1 Workflow

$namespaces:
  cwltool: http://commonwl.org/cwltool#

requirements:
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  MultipleInputFeatureRequirement: {}


## Inputs to the e2e rebinning, not to each applicaiton within the workflow
inputs:

  # For CMR Search Step
  input_cmr_collection_name: string
  input_cmr_search_start_time: string
  input_cmr_search_stop_time: string

  # catalog inputs
  input_unity_dapa_api: string
  input_unity_dapa_client: string

  #for exemple-app step
  input_summary_table_filename: string 
  input_example_argument_int: int
  input_example_argument_float: float
  input_example_argument_string: string
  input_example_argument_bool: boolean 
  input_example_argument_empty: string, null 

  # For unity data stage-out step, unity catalog
  output_collection_id: string
  output_data_bucket: string

outputs: 
  results: 
    type: File
    outputSource: example-app/stage_out_result

steps:
  cmr-step:
    run: http://awslbdockstorestack-lb-1429770210.us-west-2.elb.amazonaws.com:9998/api/ga4gh/trs/v2/tools/%23workflow%2Fdockstore.org%2Fmike-gangl%2Fcmr-trial/versions/2/PLAIN-CWL/descriptor/%2FDockstore.cwl
    in:
      cmr_collection : input_cmr_collection_name
      cmr_start_time: input_cmr_search_start_time
      cmr_stop_time: input_cmr_search_stop_time
    out: [results]
  example-app:
    run: http://awslbdockstorestack-lb-1429770210.us-west-2.elb.amazonaws.com:9998/api/ga4gh/trs/v2/tools/%23workflow%2Fdockstore.org%2Fedwinsarkissian%2Funity-example-application/versions/56/PLAIN-CWL/descriptor/%2Fworkflow.cwl
    in:
      # input configuration for stage-in
      # edl_password_type can be either 'BASE64' or 'PARAM_STORE' or 'PLAIN'
      # README available at https://github.com/unity-sds/unity-data-services/blob/main/docker/Readme.md
      stage_in:
        source: [cmr-step/results]
        valueFrom: |
          ${
              return {
                download_type: 'DAAC',
                stac_json: self,
                edl_password: '/sps/processing/workflows/edl_password',
                edl_username: '/sps/processing/workflows/edl_username',
                edl_password_type: 'PARAM_STORE',
                downloading_keys: 'data',
                log_level: '20'
              };
          }
      #input configuration for example process
      # Here we map the inputs to the workflow into the example-process inputs
      parameters:
        source: [output_collection_id]
        valueFrom: |
          ${
              return {
                summary_table_filename: input_summary_table_filename, 
                example_argument_int: input_example_argument_int,
                example_argument_float: input_example_argument_float,
                example_argument_string: input_example_argument_string,
                example_argument_bool: input_example_argument_bool,
                example_argument_empty: input_example_argument_empty,
                output_collection: self[0]
              };
          }
      #input configuration for stage-out
      # readme available at https://github.com/unity-sds/unity-data-services/blob/main/docker/Readme.md
      stage_out:
        source: [output_data_bucket, output_collection_id]
        valueFrom: |
          ${
              return {
                aws_access_key_id: '',
                aws_region: 'us-west-2',
                aws_secret_access_key: '',
                aws_session_token: '',
                collection_id: self[1],
                staging_bucket: self[0],
                log_level: '20'
              };
          }
    out: [stage_out_results]
  data-catalog:
    #run: catalog/catalog.cwl
    run: http://awslbdockstorestack-lb-1429770210.us-west-2.elb.amazonaws.com:9998/api/ga4gh/trs/v2/tools/%23workflow%2Fdockstore.org%2Fmike-gangl%2Fcatalog-trial/versions/7/PLAIN-CWL/descriptor/%2FDockstore.cwl
    in:
      unity_username:
        valueFrom: "/sps/processing/workflows/unity_username"
      unity_password:
        valueFrom: "/sps/processing/workflows/unity_password"
      password_type:
        valueFrom: "PARAM_STORE"
      unity_client_id: input_unity_dapa_client
      unity_dapa_api: input_unity_dapa_api
      uploaded_files_json: example-app/stage_out_results
    out: [results]
