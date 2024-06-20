#!/bin/bash

set -xeu -o pipefail

# exporting for subshell
src="$(realpath scripts_src)"
export src
dst="$(realpath data/scripts)"
export dst
scripts_lst="$dst/scripts.lst"
export scripts_lst
# shellcheck disable=SC2154  # bin_dir defined in env.sh
compile_exe="$bin_dir/compile.exe"
export compile_exe

# wine doesn't return proper error code on missing file
if [[ ! -f $compile_exe ]]; then
    echo "compile.exe missing, failed"
    exit 1
fi

# compile single script 
# shellcheck disable=SC2045  # We shouldn't have non-alphanumeric names here.
cd "$(realpath $(dirname ${script_to_be_compiled}))"
script_directory="$(basename $(dirname ${script_to_be_compiled}))"
        # build file list
        # shellcheck disable=SC2010  # We shouldn't have non-alphanumeric names here.
        # shellcheck disable=SC2001  # Simple replacement doesn't work, need regex.
script_filename="$(basename ${script_to_be_compiled})"
int="$(echo "$script_filename" | sed 's|\.ssl$|.int|')"

if grep -qi "^$int " "$scripts_lst" || [[ "$script_directory" == "global" ]]; then # if file is in scripts.lst or a global script
    gcc -E -x c -P -Werror -Wfatal-errors -o "${script_filename}.tmp" "$script_filename"        # preprocess
    set +e
    wine "$compile_exe" -n -l -q -O2 "${script_filename}.tmp" -o "$dst/$int" # compile
    # shellcheck disable=SC2181  # Long commands are unwieldy in if conditions.
    if [[ "$?" != "0" ]]; then # 1 retry on wine connection reset
        set -e
        sleep 1
        wine "$compile_exe" -n -l -q -O2 "${script_filename}.tmp" -o "$dst/$int" # compile
    fi
    set -e
fi
cd ..
