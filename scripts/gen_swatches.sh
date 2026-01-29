#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
proj_dir="$(dirname "$script_dir")"

out_dir="$proj_dir/.swatches"
mkdir -p "$out_dir"

palette="$proj_dir/palette.json"

jq -c '.[]' "$palette" | while read i; do
    color_name=$(echo "$i" | jq -r '.name')
    color_hex=$(echo "$i" | jq -r '.color')

    [[ "$color_hex" == \#* ]] || color_hex="#$color_hex"

    svg_out_path="${out_dir}/${color_name}.svg"
    svg_template_path="${proj_dir}/.templates/swatch-template.svg"

    cat "$svg_template_path" | sed -e "s/#ffffff/${color_hex}/g" > "$svg_out_path"
done
