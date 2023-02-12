#!/bin/bash
INPUT_SCANDIR="$1"
INPUT_IGNORE_NAMES="$2"
INPUT_IGNORE_PATHS="$3"

declare -a excludes
set -f # temporarily disable globbing so that globs in input aren't expanded

for name in ${INPUT_IGNORE_NAMES}; do
    excludes+=('!' '-name' "$name")
done

excludes+=('!' '-path' '*./.git/*')
excludes+=('!' '-path' '*.go')
excludes+=('!' '-path' '*/mvnw')
if [[ -n "${INPUT_IGNORE_PATHS}" ]]; then
	for path in ${INPUT_IGNORE_PATHS}; do
		excludes+=('!' '-path' "*./$path/*")
		excludes+=('!' '-path' "*/$path/*")
		excludes+=('!' '-path' "$path")
	done
fi

find "$INPUT_SCANDIR" -type f -name '*.md' "${excludes[@]}" -exec proselint {} \;

set +f # enable globbing again
