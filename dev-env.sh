#!/bin/bash bash
dry_run="0"

if [ -z "$XDG_CONFIG_HOME" ]; then
    XDG_CONFIG_HOME=$HOME/.config
fi

if [ -z "$DEV_ENV" ]; then
    echo "DEV_ENV not set but is required. Setting to default: $HOME/mirror_pi_config."
    DEV_ENV="$HOME/mirror_pi_config"
fi 

if [[ $1 == "--dry" ]]; then
    dry_run = "1"
fi

log() {
    if [[ $dry_run == "1" ]]; then
        echo "[DRY RUN]: $1"
    else
        echo "$1"
    fi
}

log "env: $DEV_ENV"

sync_directories() {
    log "copying over files from: $1"
    pushd $1 &> /dev/null
    (
        configs=`find . -mindepth 1 -maxdepth 1 -type d`
        for c in $configs; do
            directory=${2%/}/${c#./}
            log "   removing: rm -rf $directory"

            if [[ $dry_run == "0" ]]; then
                rm -rf $directory
            fi

            log "   copying env: cp $c $2"
            if [[ $dry_run == "0" ]]; then
                cp -r ./$c $2
            fi
        done
    )
    popd &> /dev/null
}

replace_file () {
    log "removing: $2"
    if [[ $dry_run == "0" ]]; then
        rm $2
    fi
    log "copying: $1 to $2"
    if [[ $dry_run == "0" ]]; then
        cp $1 $2
    fi
}

replace_file $DEV_ENV/env/.bashrc $HOME/.bashrc
