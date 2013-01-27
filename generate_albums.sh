#!/bin/bash
# generate albums in a very cheap (symlinks) and
# deterministic/idempotent way (so that you can throw them away if you want to),
# based on tmsu tags.

# dependencies: bash, tmsu, exiv2

source "$(dirname "$0")"/lib.sh
config="$(dirname "$0")/config"
source $config/main.sh



for album in "$config/albums"/*; do
    echo "Processing '$album'"
    source $album || die_error "Can't source '$album'"
    dir="$album_dir/$(basename $album .sh)"
    mkdir -p "$dir.new" || die_error "Can't make '$dir.new'"
    cd "$dir.new" || die_error "Can't cd '$dir.new'"
    for matching_file in $(tmsu files $match); do
        link_file "$matching_file"
    done
    cd - >/dev/null || die_error "Can't cd back to start dir"
    rm -rf "$dir" || die_error "Can't rm '$dir'"
    mv "$dir.new" "$dir" || die_error "Can't mv '$dir.new' '$dir'"
done
