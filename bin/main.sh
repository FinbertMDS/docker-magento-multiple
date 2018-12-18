#!/usr/bin/env bash

function main() {
    source bin/download_magento.sh
    source bin/prepare.sh
    source bin/build.sh
    source bin/run.sh
}

calculate_time_run_command main