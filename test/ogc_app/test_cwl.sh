#!/bin/bash

SCRIPT_DIR=$(realpath $(dirname $0))
BASE_DIR=$(realpath $(dirname $0)/../..)

WORKFLOW_FILENAME=$BASE_DIR/.unity_app_gen/cwl/workflow.cwl
JOB_INP_FILENAME=$SCRIPT_DIR/cwl_job_input.yml

if [ ! -e $WORKFLOW_FILENAME ]; then
    echo "ERROR: Run $SCRIPT_DIR/build_app.sh first to generate CWL output"
    exit 1
fi

if [ ! -e $JOB_INP_FILENAME ]; then
    echo "ERROR: Copy ${JOB_INP_FILENAME}.template to ${JOB_INP_FILENAME} and edit to include credentials"
    exit 1
fi

# Write environment variables for AWS credentials into job input file if not already null
declare -A job_input_overrides
job_input_overrides['aws_access_key_id']=$AWS_ACCESS_KEY_ID
job_input_overrides['aws_secret_access_key']=$AWS_SECRET_ACCESS_KEY
job_input_overrides['aws_session_token']=$AWS_SESSION_TOKEN
job_input_overrides['aws_region']=$AWS_DEFAULT_REGION
job_input_overrides['edl_username']=$EDL_USERNAME
job_input_overrides['edl_password']=$EDL_PASSWORD

# Create temporary copy of job input file 1
modified_job_inp_file=$(mktemp --suffix=".cwl_job.cwl")
cp -v "$JOB_INP_FILENAME" "$modified_job_inp_file"

# Modify the cmr_results.json path to be absolute to the script path
sed -i 's|cmr_results.json|'"$SCRIPT_DIR"'/cmr_results.json|' $modified_job_inp_file

# Override values that have environment variables defined for them
for job_input_var_name in "${!job_input_overrides[@]}"; do
    job_inp_var_value=${job_input_overrides[$job_input_var_name]}

    if [ ! -z "$job_inp_var_value" ]; then
        sed -i 's|'"${job_input_var_name}"': .*$|'"${job_input_var_name}"': "'"${job_inp_var_value}"'"|' "$modified_job_inp_file"
    fi
done

echo "Using modified job input file $modified_job_inp_file:"
cat $modified_job_inp_file

# Detect if using Podman 
if [ ! -z "$(which podman)" ]; then
    use_podman_arg="--podman"
fi

cwltool \
    --debug --leave-tmpdir --no-read-only \
    $use_podman_arg \
    "$WORKFLOW_FILENAME" "$modified_job_inp_file" \
    $*

rm $modified_job_inp_file
