#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Checks that the home page lists every spec in data/specs.yml, in English and
# French, and no other spec.
set -u
cd "$(dirname "$0")/.."
fail=0
want=$(sed -n 's/^- repo: fpsot-spec-//p' data/specs.yml | sort)
for page in content/index.html:/ content/fr/index.html:/fr/; do
  file=${page%%:*}; prefix=${page#*:}
  have=$(grep -o "<li><a href=\"${prefix}[a-z0-9-]*/\"" "$file" | sed "s|.*href=\"${prefix}||; s|/\"$||" | sort)
  if [ "$have" != "$want" ]; then
    echo "FAIL: $file does not list the specs of data/specs.yml:"
    diff <(echo "$want") <(echo "$have") | sed -n 's/^</  missing: /p; s/^>/  extra: /p'
    fail=1
  fi
done
[ "$fail" = 0 ] && echo PASS
exit "$fail"
