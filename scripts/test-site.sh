#!/usr/bin/env bash
# Builds the site with the spec-good fixture of fpsot-org/GitHub-Actions collected
# into it, then checks the home pages and the fixture's spec pages.
# Environment: FPSOT_TOOLS (a GitHub-Actions checkout, required), TOOLS_BIN (its
# built tools, required), MVN (default ./mvnw).
set -u
cd "$(dirname "$0")/.."
: "${FPSOT_TOOLS:?FPSOT_TOOLS must point to a GitHub-Actions checkout}" "${TOOLS_BIN:?TOOLS_BIN must hold the built tools}"
work="$(mktemp -d)"
cleanup() { rm -rf "$work" content/_src/good content/good content/fr/good public/good public/fr/good; }
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
# Release PDFs of 421,888 and 1,234,567 bytes, and a combined book of 3,456,789 and
# 3,500,000 bytes: the pages give their sizes in kB or MB, in each language's format.
mkdir -p "$work/pdf"
head -c 421888 /dev/zero > "$work/pdf/fpsot-spec-good-en.pdf"
head -c 1234567 /dev/zero > "$work/pdf/fpsot-spec-good-fr.pdf"
export FPSOT_BOOK_EN_BYTES=3456789 FPSOT_BOOK_FR_BYTES=3500000
PDF_DIR="$work/pdf" TERMBASE="$FPSOT_TOOLS/testdata/terms.yaml" bash "$FPSOT_TOOLS/scripts/site-bundle.sh" "$src" content public >"$work/bundle.log" 2>&1 \
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
# Browsers without alternative text for generated content keep the icon: a plain declaration comes first.
grep -B1 'content: "" / "external link";' "$out/assets/spec.css" | head -1 | grep -qF 'content: "";' || { echo "FAIL: no plain content fallback before the icon's alternative text"; fail=1; }
has assets/spec.css 'content: "" / "lien externe";'
[ -f "$out/assets/external.svg" ] || { echo "FAIL: assets/external.svg missing"; fail=1; }
python3 -I scripts/test-contrast.py >"$work/contrast.log" || { echo "FAIL: code colour contrast:"; cat "$work/contrast.log"; fail=1; }
[ "$(grep -c '<h1' "$out/fr/good/index.html")" = 1 ] || { echo "FAIL: fr/good/index.html has more than one h1"; fail=1; }
has good/compare/pages/fr/index.html '<html lang="en"'
has fr/good/compare/pages/ca/index.html '<html lang="fr"'
# Each spec page links its PDF and the other language's, with their sizes; a space that
# does not break separates each number from its unit.
nb=$'\u00a0'
for f in good/index.html good/glossary/index.html; do
  has $f "<a href=\"/good/fpsot-spec-good-en.pdf\" type=\"application/pdf\" hreflang=\"en\">Download the PDF (English, 422${nb}KB)</a>"
  has $f "<a href=\"/fr/good/fpsot-spec-good-fr.pdf\" type=\"application/pdf\" hreflang=\"fr\">French PDF (1.2${nb}MB)</a>"
done
has fr/good/index.html "<a href=\"/fr/good/fpsot-spec-good-fr.pdf\" type=\"application/pdf\" hreflang=\"fr\">Télécharger le PDF (français, 1,2${nb}Mo)</a>"
has fr/good/index.html "<a href=\"/good/fpsot-spec-good-en.pdf\" type=\"application/pdf\" hreflang=\"en\">PDF anglais (422${nb}Ko)</a>"
[ -f "$out/good/fpsot-spec-good-en.pdf" ] && [ -f "$out/fr/good/fpsot-spec-good-fr.pdf" ] || { echo "FAIL: spec PDFs not published"; fail=1; }
# The home pages link the book with every spec, in both languages.
has index.html "<a href=\"/fpsot-specifications-en.pdf\" type=\"application/pdf\" hreflang=\"en\">Download all the specifications as one PDF (English, 3.5${nb}MB)</a>"
has index.html "<a href=\"/fr/fpsot-specifications-fr.pdf\" type=\"application/pdf\" hreflang=\"fr\">French PDF (3.5${nb}MB)</a>"
has fr/index.html "<a href=\"/fr/fpsot-specifications-fr.pdf\" type=\"application/pdf\" hreflang=\"fr\">Télécharger toutes les spécifications en un seul PDF (français, 3,5${nb}Mo)</a>"
has fr/index.html "<a href=\"/fpsot-specifications-en.pdf\" type=\"application/pdf\" hreflang=\"en\">PDF anglais (3,5${nb}Mo)</a>"
# Each spec page names the spec's own copyright and licenses; the footer says that
# the site's license covers the website's code.
for f in good/index.html good/glossary/index.html; do
  has $f '<p class="spec-legal">Copyright 2026 The FPSOT Authors<span aria-hidden="true"> · </span>Specification: <a href="https://github.com/CommunitySpecification/1.0">Community Specification License 1.0</a><span aria-hidden="true"> · </span>Code samples: <a href="https://www.apache.org/licenses/LICENSE-2.0">Apache License 2.0</a></p>'
done
has fr/good/index.html '<p class="spec-legal">© 2026 Les auteurs de la FPSOT<span aria-hidden="true"> · </span>Spécification&nbsp;: <a href="https://github.com/CommunitySpecification/1.0">licence Community Specification 1.0</a><span aria-hidden="true"> · </span>Exemples de code&nbsp;: <a href="https://www.apache.org/licenses/LICENSE-2.0">licence Apache 2.0</a></p>'
for f in index.html good/index.html; do
  has $f 'Website code: <a href="https://github.com/fpsot-org/fpsot-org.github.io/blob/main/LICENSE">Apache-2.0</a>'
done
for f in fr/index.html fr/good/index.html; do
  has $f 'Code du site&nbsp;: <a href="https://github.com/fpsot-org/fpsot-org.github.io/blob/main/LICENSE">Apache-2.0</a>'
done
[ $fail -eq 0 ] && echo "PASS"
exit $fail
