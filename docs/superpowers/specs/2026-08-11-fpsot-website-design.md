# FPSOT Website (fpsot-org.github.io) — Design

Date: 2026-08-11
Status: approved pending user review

## Goal

A single bilingual (English/French) landing page for the Foundation for Public
Sector Open Technology, aimed first at public-sector decision makers (CIOs, IT
directors, procurement staff). It presents the mission, the four pillars, the
initial focus areas, and how to get involved via GitHub. Served by GitHub Pages
at https://fpsot-org.github.io.

## Decisions

- **Scope:** one landing page per language; no blog, no docs section.
- **Audience:** public-sector decision makers first; contributors second.
- **Tone/visuals:** civic-institutional (gov-design-system family), credible
  and restrained.
- **Languages:** English at `/`, French at `/fr/`. Full human-quality
  translation, not machine-flavored text.
- **Contact:** GitHub org and issue links only. No email anywhere on the site.
- **Domain:** fpsot-org.github.io (custom domain out of scope; can be added
  later with a CNAME file).
- **Stack:** hand-written static HTML + one shared CSS file. No build step, no
  JavaScript, no external dependencies (fonts self-hosted or system stack).

## File structure

```
fpsot-org.github.io/
├── index.html        # English page (lang="en")
├── fr/index.html     # French page (lang="fr")
├── assets/style.css  # shared stylesheet
├── assets/logo.svg   # text-based wordmark
├── .nojekyll         # disable Pages' Jekyll build; serve files as-is
└── LICENSE           # existing Apache-2.0, untouched
```

The language toggle is a plain link: the EN header links to `/fr/`, the FR
header links to `/`. Header/footer markup is duplicated between the two files;
acceptable at two pages, revisit if the site grows.

## Page structure (identical in both languages)

1. **Header** — FPSOT wordmark, EN | FR toggle, GitHub link.
2. **Hero** — mission: public services powered by transparent, interoperable,
   community-owned software. Primary CTA button: "Get involved on GitHub" →
   https://github.com/fpsot-org.
3. **What we do** — four pillars from the org README as a 2×2 card grid:
   support the public sector, build and maintain open technology, advocate for
   policy change, educate and connect.
4. **Focus areas** — compact list, labeled as in progress: reference
   architectures, policy & procurement templates, sample projects, migration
   playbooks.
5. **Get involved** — early-stage message; links to the GitHub org and to
   opening an issue on fpsot-org/.github.
6. **Footer** — © FPSOT, license note (Apache-2.0), GitHub link.

## Head/meta requirements (each page)

- `<html lang>` correct per page (`en` / `fr`).
- `hreflang` alternate links between `/` and `/fr/`, plus `x-default` → `/`.
- Meta description and Open Graph title/description per language.
- Canonical URL per page.

## Visual design

- Deep navy primary, one restrained accent, near-black text on white.
- Typography: system-font stack (or a single self-hosted font file if needed);
  no CDN requests of any kind.
- Generous whitespace; no stock photos or illustrations; logo is a wordmark.
- Accessibility: WCAG AA contrast, semantic landmarks (header/main/footer),
  visible focus states, meaningful link text in both languages.
- Responsive: single column on mobile; card grid collapses to one column.

## Deployment

Push to `main`; GitHub Pages (already enabled, legacy build from `main` root)
serves it. `.nojekyll` prevents Jekyll processing.

## Verification

- Both URLs return the correct language with correct `lang` attribute.
- Language toggle round-trips (EN → FR → EN lands on the same section).
- HTML validates (W3C validator or equivalent).
- Lighthouse: accessibility and SEO ≥ 95, performance ≥ 95 (static page, no
  JS — should be trivially high).
- No external network requests (fonts, scripts, images all first-party).

## Out of scope (v1)

Blog/news, custom domain, analytics, contact form/email, dark mode, CMS,
JavaScript of any kind.
