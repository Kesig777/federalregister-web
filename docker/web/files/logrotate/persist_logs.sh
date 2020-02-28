#! /bin/bash
set -eu

# don't return anything in file glob if no match
shopt -s nullglob

persist_logs=${PERSIST_LOGS:-false}
k8s=${K8S:-false}

if [ "$persist_logs" = "true" ]; then
  log_bucket=$LOG_BUCKET
  hostname=$(hostname)

  if [ "$k8s" = "true" ]; then
    pod_name=$(hostname | rev | cut -d '-' -f 3- | rev)
  else
    pod_name=$(hostname)
  fi

  for f in /home/app/log/*.gz
  do
    log_name=$(echo "${f}" | rev | cut -d '/' -f1 | rev)
    year=$(echo "${f}" | cut -d '-' -f2 | cut -c1-4)
    month=$(echo "${f}" | cut -d '-' -f2 | cut -c5-6)
    upload_path="${year}/${month}/${pod_name}/${hostname}-${log_name}"
    
    if [ ! "$("aws s3 ls s3://${log_bucket}/${upload_path}")" ]; then
      result=$("aws s3api put-object --bucket ${log_bucket} --key ${upload_path} --body ${f}")
      echo "${result}"
    else
      echo "file ${upload_path} already exists"
    fi
  done
fi