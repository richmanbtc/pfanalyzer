#!/bin/bash

set -ex

data_dir=$(realpath $1)

if [ ! -d "$data_dir" ]; then
  echo "$data_dir does not exist."
  exit
fi

repo_root="$(dirname -- "${BASH_SOURCE[0]}")/../"
tmp_dir=$(mktemp -d)

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

(
cd ${repo_root}

docker build -t pfanalyzer-tmp .
docker run --rm \
  -v "${data_dir}:/app/data:ro" \
  -v "./notebooks:/app/notebooks:ro" \
  -v "./src:/app/src:ro" \
  -v "./pfanalyzer.yml:/app/pfanalyzer.yml:ro" \
  -v "${tmp_dir}:/output" \
  -e "PFANALYZER_ANONYMIZED=${PFANALYZER_ANONYMIZED:-0}" \
  pfanalyzer-tmp bash -c "${command}"
)

report_path="${tmp_dir}/report.ipynb"

mkdir -p "${data_dir}/reports"
date_str=$(date "+%Y%m%d_%H%M%S")
output_path="${data_dir}/reports/${date_str}.ipynb"
cp "${report_path}" ${output_path}

open "${output_path}"
