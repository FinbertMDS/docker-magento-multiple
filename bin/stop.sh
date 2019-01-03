#!/usr/bin/env bash

source bin/common.sh

function stopDocker() {
    local docker_build_command=`get_docker_command "stop "`
    exec_cmd "${docker_build_command}"
}

function main() {
    stopDocker
}

main