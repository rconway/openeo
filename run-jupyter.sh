#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
source functions

export NB_USER="$(id -un)"
export NB_UID="$(id -u)"
export NB_GID="$(id -g)"

PYTHON=python

function onExit() { cd "${ORIG_DIR}"; }
trap "onExit" EXIT

main() {
  optionalClean "$@"
  runWithPython
}

runWithPython() {
  info "Using python command - $(which $PYTHON)"
  export PYDEVD_DISABLE_FILE_VALIDATION=1
  $PYTHON -m venv venv \
    && source venv/bin/activate \
    && python -m pip install -U pip \
    && pip install -U devtools \
    && pip install -U cmake \
    && pip install -U wheel setuptools \
    && pip install -U jupyterlab \
    && pip install -r requirements.txt \
    && jupyter-lab --ServerApp.root_dir notebooks --NotebookApp.token=\'\' --no-browser
}

optionalClean() {
  if [[ "$*" == *"--clean"* ]]; then
    warning "Clean: removing existing venv"
    rm -rf venv
  else
    if test -d venv; then info "Using existing venv in directory $PWD/venv\n  -> Use option --clean to create a fresh environment"; fi
  fi
}

main "$@"
