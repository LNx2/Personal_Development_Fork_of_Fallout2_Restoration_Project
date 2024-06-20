#!/bin/bash

## usage syntax:     ./extra/build_single_script.sh <<path_to_script_file>>
## usage example:    ./extra/build_single_script.sh ./scripts_src/sanfran/fclopan.ssl

set -xeu -o pipefail

rm -f ./*.7z ./*.zip ./*.exe ./*.list

# shellcheck source=/dev/null  # doesn't matter, no vars used in this script
source ./extra/env.sh
./extra/prepare.sh

script_to_be_compiled="${1}"

export script_to_be_compiled
./extra/compile_single_script.sh
## ./extra/package.sh
