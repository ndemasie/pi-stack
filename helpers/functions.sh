#!/bin/bash
function hasCommand() {
  local cmd=$@
  command -v "$cmd" >/dev/null 2>&1
}

function execute() {
  local path=${1}
  [ -x $path ] || sudo chmod +x $path
  $path
}