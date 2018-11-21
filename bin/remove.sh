#!/usr/bin/env bash

source bin/common.sh

function removeDocker() {
    local DOCKER_BUILD_COMMAND=`get_docker_command "down "`
    exec_cmd "${DOCKER_BUILD_COMMAND}"
}

function main() {
    removeDocker
}

main