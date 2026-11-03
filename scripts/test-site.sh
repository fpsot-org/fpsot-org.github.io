#!/usr/bin/env bash
# Builds the site with the spec-good fixture of fpsot-org/GitHub-Actions collected
# into it, then checks the home pages and the fixture's spec pages.
# Environment: FPSOT_TOOLS (a GitHub-Actions checkout, required), TOOLS_BIN (its
# built tools, required), MVN (default ./mvnw).
set -u
cd "$(dirname "$0")/.."
: "${FPSOT_TOOLS:?FPSOT_TOOLS must point to a GitHub-Actions checkout}" "${TOOLS_BIN:?TOOLS_BIN must hold the built tools}"
work="$(mktemp -d)"
cleanup() { rm -rf "$work" content/_src/good content/good content/fr/good public/good; }
trap cleanup EXIT
fail=0
src="$work/fpsot-spec-good"
cp -r "$FPSOT_TOOLS/testdata/spec-good" "$src"
git -C "$src" init -q
git -C "$src" add -A
git -C "$src" -c user.name=t -c user.email=t@example.org -c commit.gpgsign=false commit -q -m fixture
git -C "$src" -c tag.gpgsign=false tag -a v0.1.0 -m v0.1.0
git -C "$src" remote add origin https://github.com/fpsot-org/fpsot-spec-good
TERMBASE="$FPSOT_TOOLS/testdata/terms.yaml" bash "$FPSOT_TOOLS/scripts/site-bundle.sh" "$src" content public >"$work/bundle.log" 2>&1 \
  || { echo "FAIL: site-bundle.sh:"; cat "$work/bundle.log"; exit 1; }
rm -rf target
QUARKUS_ROQ_GENERATOR_BATCH=true ${MVN:-./mvnw} -B -q package quarkus:run >"$work/build.log" 2>&1 \
  || { echo "FAIL: site build:"; tail -40 "$work/build.log"; exit 1; }
out=target/roq
has() { grep -qF -- "$2" "$out/$1" 2>/dev/null || { echo "FAIL: $1 lacks: $2"; fail=1; }; }
hasnot() { ! grep -qF -- "$2" "$out/$1" 2>/dev/null || { echo "FAIL: $1 contains: $2"; fail=1; }; }
for f in index.html fr/index.html assets/style.css assets/spec.css assets/js/theme.js assets/fpsot-logo.svg; do
  [ -f "$out/$f" ] || { echo "FAIL: $f missing"; fail=1; }
done
has index.html '<html lang="en"'
has fr/index.html '<html lang="fr"'
has fr/good/index.html '<html lang="fr"'
has fr/good/index.html 'Version 0.1.0'
has fr/good/index.html 'href="/good/" lang="en" hreflang="en"'
has fr/good/index.html '<link rel="alternate" hreflang="en" href="https://fpsot.org/good/">'
has fr/good/index.html 'href="/fr/good/glossary/#gl-api"'
hasnot fr/good/index.html '{abbr-'
has good/index.html '<html lang="en"'
[ "$(grep -c '<h1' "$out/fr/good/index.html")" = 1 ] || { echo "FAIL: fr/good/index.html has more than one h1"; fail=1; }
has good/compare/pages/fr/index.html '<html lang="en"'
has fr/good/compare/pages/ca/index.html '<html lang="fr"'
[ $fail -eq 0 ] && echo "PASS"
exit $fail
