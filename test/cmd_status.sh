#!/bin/sh

TEST_DIR=$(pwd)
GWS="$(pwd)/../src/gws"
TMP_DIR=$(mktemp -d --tmpdir gws-test.XXXXXXXXXX)
CLONE_SOURCE="${TMP_DIR}/test-repo"
WORKSPACE="${TMP_DIR}/workspace"

mktemp_workspace() {
  mktemp -d --tmpdir="$TMP_DIR" "$1".XXXX
}

oneTimeSetUp() {
  git clone https://github.com/StreakyCobra/gws "$CLONE_SOURCE" &>/dev/null
  git -C "$CLONE_SOURCE" checkout develop &>/dev/null
  git -C "$CLONE_SOURCE" checkout gh-pages &>/dev/null
  git -C "$CLONE_SOURCE" checkout master &>/dev/null
}


oneTimeTearDown() {
  rm -rf $TMP_DIR
}

test_prints_clean_for_each_clean_branch() {
  workspace=$(mktemp_workspace cmd_status)
  git clone "$CLONE_SOURCE" "${workspace}/clean"
  git -C "${workspace}/clean" checkout -b foo
  cp "${workspace}"/clean/.git/refs/{heads/foo,remotes/origin/foo}
  echo "clean | ${CLONE_SOURCE}" > "${workspace}"/.projects.gws

  cd "$workspace"
  expected="clean:
    foo :                     Clean
    master :                  Clean"
  assertEquals "$expected" "$("$GWS" status)"
}

cd "$TEST_DIR"
source ./launch_shunit.sh
