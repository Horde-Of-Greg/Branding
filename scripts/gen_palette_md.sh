#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$script_dir/gen_swatches.sh"

proj_dir="$(dirname "$script_dir")"

swatches_dir="$proj_dir/.swatches"

markdown="$proj_dir/PALETTE.md"
truncate -s 0 "$markdown"
cat "$proj_dir/.templates/palette-template.md" >> "$markdown"
palette="$proj_dir/palette.json"

format_name() {
    local name="$1"
    name=$(echo "$name" | sed 's/\([a-zA-Z]\)\([0-9]\)/\1 \2/g')
    name="$(echo "${name:0:1}" | tr '[:lower:]' '[:upper:]')${name:1}"
    echo "$name"
}

jq -c '.[]' "$palette" | while read i; do
    color_name=$(echo "$i" | jq -r '.name')
    color_hex=$(echo "$i" | jq -r '.color')

    [[ "$color_hex" == \#* ]] || color_hex="#$color_hex"

    display_name=$(format_name "$color_name")

    echo "| $display_name | \`$color_hex\` | ![$color_name](.swatches/$color_name.svg) |" >> "$markdown"
done

table_start=$(grep -n '^|' "$markdown" | head -1 | cut -d: -f1)
head -n $((table_start - 1)) "$markdown" > "$markdown.tmp"

grep '^|' "$markdown" | column -t -s '|' -o '|' >> "$markdown.tmp"

mv "$markdown.tmp" "$markdown"
