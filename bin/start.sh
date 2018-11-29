#!/usr/bin/env bash

source bin/common.sh

function run_docker() {
    local docker_build_command=`get_docker_command "start"`
    exec_cmd "${docker_build_command}"
}

function main() {
    run_docker
    print_site_magento_list
}

calculate_time_run_command main