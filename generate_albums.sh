#!/bin/bash
# generate albums in a very cheap (symlinks) and
# deterministic/idempotent way (so that you can throw them away if you want to),
# based on tmsu tags.

# dependencies: bash, tmsu, exiv2

config="$(dirname $0)/config"

source $config/main.sh

die_error () {
    echo "ERROR: $@"
    exit 2
}

filename () {
    # some things (ex. facebook) look at filenames, not exif timestamps.
    # so all pictures must be ordered by time irrespective of original
    # filename or src dir, we can easily do this by divising
    # appropriate filenames based on exif time.
    local file=$1
    local file_base="$(basename "$file")"
    local fname=$(exiv2 -g Exif.Image.DateTime -P v "$file" | tr ' ' '_')_"$file_base"
    echo "$fname"
}

for album in "$config/albums"/*; do
    echo "Processing '$album'"
    source $album || die_error "Can't source '$album'"
    dir="$album_dir/$(basename $album .sh)"
    mkdir -p "$dir.new" || die_error "Can't make '$dir.new'"
    cd "$dir.new" || die_error "Can't cd '$dir.new'"
    for src_dir in "${source_dirs[@]}"; do
        for matching_file in $(cd "$src_dir" && tmsu files $match); do
            ln -s "$src_dir/$matching_file" "$(filename "$src_dir/$matching_file")"
        done
    done
    rm -rf "$dir" || die_error "Can't rm '$dir'"
    mv "$dir.new" "$dir" || die_error "Can't mv '$dir.new' '$dir'"
done
