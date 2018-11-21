#!/usr/bin/env bash

source bin/common.sh

function stopDocker() {
    local DOCKER_BUILD_COMMAND=`get_docker_command "stop "`
    exec_cmd "${DOCKER_BUILD_COMMAND}"
}

function main() {
    stopDocker
}

main