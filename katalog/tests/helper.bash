#!/usr/bin/env bats
# shellcheck disable=SC2154,SC2034,SC2086,SC2103
# Copyright (c) 2021 SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -o pipefail

kaction(){
    path=$1
    verb=$2
    kustomize build $path | kubectl $verb -f -
}

apply (){
  kustomize build $1 >&2
  kustomize build $1 | kubectl apply -f - 2>&3
}

delete (){
  kustomize build $1 >&2
  kustomize build $1 | kubectl delete -f - 2>&3
}

info(){
  echo -e "${BATS_TEST_NUMBER}: ${BATS_TEST_DESCRIPTION}" >&3
}

loop_it(){
  retry_counter=0
  max_retry=${2:-100}
  wait_time=${3:-2}
  run ${1}
  ko=${status}
  loop_it_result=${ko}
  while [[ ko -ne 0 ]]
  do
    if [ $retry_counter -ge $max_retry ]; then echo "Timeout waiting a condition"; return 1; fi
    sleep ${wait_time} && echo "# waiting..." $retry_counter >&3
    run ${1}
    ko=${status}
    loop_it_result=${ko}
    retry_counter=$((retry_counter + 1))
  done
  return 0
}
