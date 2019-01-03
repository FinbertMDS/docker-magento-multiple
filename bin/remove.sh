#!/usr/bin/env bash

source bin/common.sh

function removeDocker() {
    local docker_build_command=`get_docker_command "down "`
    exec_cmd "${docker_build_command}"
}

function main() {
    removeDocker
}

main