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
# A code block, to check that code is coloured. It goes before the document history.
python3 - "$src/spec/en/index.adoc" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
block = '[source,json]\n----\n{"name": "FPSOT", "version": 1}\n----\n\n'
# More languages: Rouge compiles each lexer on first use, and pages render in
# parallel, so several blocks give a race a chance to show.
for lang, code in [("yaml", "name: FPSOT\nversion: 1"), ("http", "GET /v1/parties HTTP/1.1\nHost: api.example.com"),
                   ("shell", "git tag -s v1.0.0 -m v1.0.0"), ("xml", "<unit id=\"1\"><source>Hi</source></unit>"),
                   ("properties", "greeting=Hello")] * 4:
    block += f'[source,{lang}]\n----\n{code}\n----\n\n'
open(p, "w", encoding="utf-8").write(s.replace("== Document history", block + "== Document history", 1))
PY
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
# Code is coloured when the site is built: Rouge classes, no inline style.
has good/index.html '<pre class="rouge highlight">'
has good/index.html '<span class="s2">"FPSOT"</span>'
# Rouge's markup carries no inline style (Asciidoctor's table column widths do, elsewhere).
python3 -I -c 'import re,sys; s=open(sys.argv[1],encoding="utf-8").read(); sys.exit(any("style=" in b for b in re.findall(r"<pre class=\"rouge highlight\">.*?</pre>", s, re.S)))' "$out/good/index.html" \
  || { echo "FAIL: highlighted code has an inline style"; fail=1; }
# No token is an error: Rouge lexed every block (book and page render in parallel).
for f in good/index.html good/book/index.html; do
  grep -q 'class="err"' "$out/$f" && { echo "FAIL: $f has a Rouge error token (lexer compiled by two threads at once?)"; fail=1; }
done
# JSON keys are coloured like attributes.
grep -q '\.highlight \.nl' "$out/assets/spec.css" || { echo "FAIL: spec.css does not colour JSON keys (.nl)"; fail=1; }
# Links that leave fpsot.org carry the external-link icon, announced in each language.
has assets/spec.css 'content: "" / "external link";'
has assets/spec.css 'content: "" / "lien externe";'
[ -f "$out/assets/external.svg" ] || { echo "FAIL: assets/external.svg missing"; fail=1; }
python3 -I scripts/test-contrast.py >"$work/contrast.log" || { echo "FAIL: code colour contrast:"; cat "$work/contrast.log"; fail=1; }
[ "$(grep -c '<h1' "$out/fr/good/index.html")" = 1 ] || { echo "FAIL: fr/good/index.html has more than one h1"; fail=1; }
has good/compare/pages/fr/index.html '<html lang="en"'
has fr/good/compare/pages/ca/index.html '<html lang="fr"'
[ $fail -eq 0 ] && echo "PASS"
exit $fail
