#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment the following to get more detail on failures of stubs
export AWS_STUB_DEBUG=/dev/tty

@test "Syncs files from the source directory to the destination S3 bucket" {
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_SOURCE=s3://source
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_DESTINATION=destination/
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_EXTRA_ARGS=""

  stub aws "s3 sync s3://source destination/ : echo s3 sync"

  run $PWD/hooks/pre-command

  assert_success
  assert_output --partial "s3 sync"
  unstub aws
}

@test "Syncs and deletes files" {
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_SOURCE=s3://source
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_DESTINATION=destination/
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_DELETE=true
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_EXTRA_ARGS=""

  stub aws "s3 sync --delete s3://source destination/ : echo s3 sync --delete"

  run $PWD/hooks/pre-command

  assert_success
  assert_output --partial "s3 sync --delete"
  unstub aws
}

@test "Doesn't follow symlinks" {
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_SOURCE=s3://source
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_DESTINATION=destination/
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_FOLLOW_SYMLINKS=false
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_EXTRA_ARGS=""

  stub aws "s3 sync --no-follow-symlinks s3://source destination/ : echo s3 sync --no-follow-symlinks"

  run $PWD/hooks/pre-command

  assert_success
  assert_output --partial "s3 sync --no-follow-symlinks"
  unstub aws
}

@test "Skips pre command when source is local" {
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_SOURCE=source/
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_DESTINATION=s3://destination
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_EXTRA_ARGS=""

  run $PWD/hooks/pre-command

  assert_success
}

@test "Skips pre command when source and destination are both s3" {
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_SOURCE=s3://source/
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_DESTINATION=s3://destination
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_EXTRA_ARGS=""

  run $PWD/hooks/pre-command

  assert_success
}

@test "Syncs with extra args" {
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_SOURCE=s3://source
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_DESTINATION=destination/
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_DELETE=true
  export BUILDKITE_PLUGIN_AWS_S3_SYNC_EXTRA_ARGS="--acl public-read --follow-symlinks"

  stub aws "s3 sync '--acl public-read --follow-symlinks' s3://source destination/ : echo s3 sync --acl public-read --follow-symlinks"

  run $PWD/hooks/pre-command

  assert_success
  assert_output --partial "s3 sync --acl public-read --follow-symlinks"
  unstub aws
}
