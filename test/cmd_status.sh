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

  if false ; then

    mkdir -p "$WORKSPACE"/{work,tools,ignoring}
    git clone "$CLONE_SOURCE" "$WORKSPACE"/work/neuraltalk

    git clone "$CLONE_SOURCE" "$WORKSPACE"/work/docker-gitlab
    git -C "$WORKSPACE"/work/docker-gitlab checkout gh-pages

    git clone "$CLONE_SOURCE" "$WORKSPACE"/tools/q
    git -C "$WORKSPACE"/tools/q checkout gh-pages
    git -C "$WORKSPACE"/tools/q remote add myone http://coool
    git -C "$WORKSPACE"/tools/q remote add upstream testurl

    git clone "$CLONE_SOURCE" "$WORKSPACE"/tools/peru

    git clone "$CLONE_SOURCE" "$WORKSPACE"/tools/coursera-dl
    git -C "$WORKSPACE"/tools/coursera-dl checkout master

    git init "$WORKSPACE"/tools/emptyyyy

    git init "$WORKSPACE"/tools/another
    cd "$WORKSPACE"/tools/another
      git checkout -b aaaaabbbbbcccccdddddeeeeefffffggggghhhhhiiiiiccccc
      touch test
      git add test
      git commit -m message
    cd ..

    git clone "$CLONE_SOURCE" "$WORKSPACE"/ignoring/gws

    git clone "$CLONE_SOURCE" "$WORKSPACE"/work/gws
    git -C "$WORKSPACE"/ignoring/gws checkout develop

    echo "^ignoring/" > "$WORKSPACE"/.ignore.gws
    cd "$WORKSPACE"
      "$GWS" init
    cd ..

    perturbate "$WORKSPACE"

    cd "$TEST_DIR"
  fi
}

perturbate() {
  touch "$1"/work/neuraltalk/test

  git -C "$1"/work/docker-gitlab checkout master
  git -C "$1"/work/docker-gitlab reset --hard HEAD^

  cd "$1"/tools/q
    touch testfile
    git add testfile
    git commit -m message
  cd ..

  rm -rf "$1"/tools/peru

  cd "$1"/tools/coursera-dl
    touch test
    git add test
  cd ..

  git clone "$CLONE_SOURCE" "$1"/nested-gws
  git clone "$CLONE_SOURCE" "$1"/nested-gws/nested-gws
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
