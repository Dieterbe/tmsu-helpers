#!/bin/bash

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

link_file () {
    local file=$1
    fname="$(filename "$file")"
    [ ! -e "$fname" ] || die_error "'$fname' already exists in '$(pwd)'? wanted to link to '$file'"
    ln -r -s "$file" "$fname"
}

