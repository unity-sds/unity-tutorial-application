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

cwltool \
    --debug --leave-tmpdir --no-read-only \
    $WORKFLOW_FILENAME $JOB_INP_FILENAME
