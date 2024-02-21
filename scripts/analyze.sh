#!/bin/bash

set -ex

data_dir=$(realpath $1)

if [ ! -d "$data_dir" ]; then
  echo "$data_dir does not exist."
  exit
fi

command="jupyter nbconvert \
  --to notebook \
  --output-dir='/output' \
  --execute \
  --ExecutePreprocessor.timeout=-1 \
  /app/notebooks/prepare.ipynb \
&& jupyter nbconvert \
  --to notebook \
  --output-dir='/output' \
  --execute \
  --ExecutePreprocessor.timeout=-1 \
  /app/notebooks/report.ipynb \
"

docker build -t pfanalyzer-tmp .
docker run --rm \
  -v "${data_dir}:/app/data:ro" \
  -v "./notebooks:/app/notebooks:ro" \
  -v "./src:/app/src:ro" \
  -v "./pfanalyzer.yml:/app/pfanalyzer.yml:ro" \
  -v "/tmp:/output" \
  -e "PFANALYZER_ANONYMIZED=${PFANALYZER_ANONYMIZED:-0}" \
  pfanalyzer-tmp bash -c "${command}"

open /tmp/report.ipynb
