#!/usr/bin/env bash

function build_docker() {
    print_status "Building docker..."
    local docker_build_command=`get_docker_command "build "`
    exec_cmd "${docker_build_command}"
    print_done
}

function main() {
    build_docker
}

calculate_time_run_command main