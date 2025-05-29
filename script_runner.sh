#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ -z "$XDG_CONFIG_HOME" ]; then
    XDG_CONFIG_HOME=$HOME/.config
fi

if [ -z "$DEV_ENV" ]; then
    echo "DEV_ENV not set but is required. Setting to default: $HOME/mirror_pi_config."
    DEV_ENV="$HOME/mirror_pi_config"
fi

# if i just did DEV_ENV=$(pwd) ./run then this is needed for the rest of the
# scripts
export DEV_ENV="$DEV_ENV"

grep=""
dry_run="0"

while [[ $# -gt 0 ]]; do
    echo "ARG: \"$1\""
    if [[ "$1" == "--dry" ]]; then
        dry_run="1"
    else
        grep="$1"
    fi
    shift
done

log() {
    if [[ $dry_run == "1" ]]; then
        echo "[DRY_RUN]: $1"
    else
        echo "$1"
    fi
}

log "RUN: env: $env -- grep: $grep"

# Remember that all scripts that we want to run must have their executable permissions set
# i.e., chmod +x ./scripts/{script_name}.sh
scripts_dir=`find $script_dir/scripts -mindepth 1 -maxdepth 1 -type f -perm +111` 

log "$scripts_dir"

for s in $scripts_dir; do
    if basename $s | grep -vq "$grep"; then
        log "grep \"$grep\" filtered out $s"
        continue
    fi

    log "running script: $s"

    if [[ $dry_run == "0" ]]; then
        sh $s
    fi
done
