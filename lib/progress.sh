#!/bin/bash

step() {
  local num="$1"
  local desc="$2"
  echo -e "\n\e[1;34m▶ STEP $num: $desc\e[0m"
}
