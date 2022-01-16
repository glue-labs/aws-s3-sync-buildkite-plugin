#!/bin/bash

function aws_s3_sync() {
  local source=$1
  local destination=$2
  local extra_args=$3
  params=()

  if [ -z "$extra_args" ]
  then
    if [[ "${BUILDKITE_PLUGIN_AWS_S3_SYNC_DELETE:-false}" == "true" ]]; then
      params+=(--delete)
    fi

    if [[ "${BUILDKITE_PLUGIN_AWS_S3_SYNC_FOLLOW_SYMLINKS:-true}" == "false" ]]; then
      params+=(--no-follow-symlinks)
    fi
  else
    echo "found extra args skipping others"
    params+=("$extra_args")
  fi

  params+=("$source")
  params+=("$destination")
  echo "~~~ :s3: Syncing '$source' to '$destination'"
  aws s3 sync "${params[@]}"
}