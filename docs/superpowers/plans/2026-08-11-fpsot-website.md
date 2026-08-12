# FPSOT Website Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the bilingual (EN/FR) single-page FPSOT site at https://fpsot-org.github.io per the 2026-08-11 design spec.

**Architecture:** Hand-written static HTML — `index.html` (EN) and `fr/index.html` (FR) sharing `assets/style.css` and `assets/logo.svg`. No JavaScript, no build step; GitHub Pages serves `main` as-is (`.nojekyll`).

**Tech Stack:** HTML5, CSS3, GitHub Pages. Verification with `python3 -m http.server`, `curl`, and `grep`.

## Global Constraints

- No external network requests: no CDN fonts, scripts, images, or analytics. System font stack only.
- No JavaScript anywhere.
- All contact routes are GitHub links (`https://github.com/fpsot-org`, `https://github.com/fpsot-org/.github/issues`). No email addresses anywhere.
- `<html lang="en">` on `/`, `<html lang="fr">` on `/fr/`.
- Every page has: canonical URL, `hreflang` alternates (`en`, `fr`, `x-default` → EN), meta description, Open Graph title/description, viewport meta.
- WCAG AA: color contrast ≥ 4.5:1 for body text, visible `:focus-visible` outlines, semantic `<header>/<main>/<footer>`, one `<h1>` per page.
- Commit identity is the repo default (`jnbdz <237008+jnbdz@users.noreply.github.com>`); commit messages carry no attribution trailers.
- The existing `LICENSE` file must not be modified.

---

### Task 1: Scaffold — stylesheet, logo, .nojekyll

**Files:**
- Create: `.nojekyll` (empty)
- Create: `assets/style.css`
- Create: `assets/logo.svg`

**Interfaces:**
- Produces: class names used by both HTML pages in Tasks 2–3: `site-header`, `lang-switch`, `hero`, `cta-button`, `pillars`, `card`, `focus-list`, `get-involved`, `site-footer`, `container`.

- [ ] **Step 1: Create `.nojekyll`**

```bash
cd /home/jn/Projects/fpsot-org/fpsot-org.github.io
touch .nojekyll
```

- [ ] **Step 2: Create `assets/style.css`** with exactly:

```css
/* FPSOT — civic-institutional. Navy primary, restrained accent, system fonts. */
:root {
  --navy: #14324f;
  --navy-dark: #0d2337;
  --accent: #b45309;
  --ink: #1a1a1a;
  --muted: #4b5563;
  --paper: #ffffff;
  --wash: #f3f6f9;
  --line: #d7dee6;
}

* { box-sizing: border-box; }

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
    "Helvetica Neue", Arial, sans-serif;
  color: var(--ink);
  background: var(--paper);
  line-height: 1.6;
}

.container {
  max-width: 60rem;
  margin: 0 auto;
  padding: 0 1.25rem;
}

a { color: var(--navy); }
a:focus-visible, button:focus-visible {
  outline: 3px solid var(--accent);
  outline-offset: 2px;
}

/* Header */
.site-header {
  border-top: 6px solid var(--navy);
  border-bottom: 1px solid var(--line);
}
.site-header .container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding-top: 0.9rem;
  padding-bottom: 0.9rem;
}
.site-header .brand { display: flex; align-items: center; gap: 0.6rem; text-decoration: none; }
.site-header .brand img { height: 2rem; width: auto; }
.site-header nav { display: flex; align-items: center; gap: 1.25rem; }
.site-header nav a { text-decoration: none; font-weight: 600; }
.lang-switch { border: 1px solid var(--line); border-radius: 4px; padding: 0.25rem 0.6rem; }

/* Hero */
.hero { background: var(--navy); color: #ffffff; padding: 4rem 0 4.5rem; }
.hero h1 { font-size: clamp(1.9rem, 4.5vw, 3rem); line-height: 1.15; margin: 0 0 1rem; max-width: 40rem; }
.hero p { font-size: 1.15rem; max-width: 38rem; margin: 0 0 2rem; color: #dbe5ee; }
.cta-button {
  display: inline-block;
  background: #ffffff;
  color: var(--navy-dark);
  font-weight: 700;
  text-decoration: none;
  padding: 0.8rem 1.5rem;
  border-radius: 4px;
}
.cta-button:hover { background: var(--wash); }

/* Sections */
main section { padding: 3.5rem 0; }
main section h2 { font-size: 1.6rem; margin: 0 0 1.5rem; color: var(--navy-dark); }

/* Pillars */
.pillars { background: var(--paper); }
.pillars .grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.25rem;
}
.card { border: 1px solid var(--line); border-left: 4px solid var(--navy); border-radius: 4px; padding: 1.25rem 1.4rem; }
.card h3 { margin: 0 0 0.5rem; font-size: 1.1rem; }
.card p { margin: 0; color: var(--muted); }

/* Focus areas */
.focus { background: var(--wash); }
.focus-list { list-style: none; margin: 0; padding: 0; display: grid; gap: 0.75rem; }
.focus-list li { background: var(--paper); border: 1px solid var(--line); border-radius: 4px; padding: 0.9rem 1.2rem; }
.focus-list strong { color: var(--navy-dark); }
.focus .status { color: var(--muted); font-size: 0.95rem; margin-top: 1.25rem; }

/* Get involved */
.get-involved ul { margin: 0; padding-left: 1.2rem; }
.get-involved li { margin-bottom: 0.5rem; }

/* Footer */
.site-footer { border-top: 1px solid var(--line); padding: 1.5rem 0 2rem; color: var(--muted); font-size: 0.95rem; }
.site-footer .container { display: flex; flex-wrap: wrap; gap: 0.5rem 2rem; justify-content: space-between; }
.site-footer a { color: var(--muted); }

@media (max-width: 40rem) {
  .pillars .grid { grid-template-columns: 1fr; }
  .hero { padding: 3rem 0; }
}
```

- [ ] **Step 3: Create `assets/logo.svg`** — text wordmark, navy, accessible title:

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 132 40" role="img" aria-label="FPSOT">
  <title>FPSOT</title>
  <rect x="0" y="0" width="8" height="40" fill="#b45309"/>
  <text x="18" y="29" font-family="Georgia, 'Times New Roman', serif" font-size="26" font-weight="bold" fill="#14324f">FPSOT</text>
</svg>
```

- [ ] **Step 4: Verify files exist and CSS parses (no unclosed braces)**

Run: `test -f .nojekyll && grep -c '{' assets/style.css && grep -c '}' assets/style.css`
Expected: the two counts are equal (every `{` has a matching `}`).

- [ ] **Step 5: Commit**

```bash
git add .nojekyll assets/
git commit -m "Add stylesheet, wordmark, and .nojekyll scaffold"
```

---

### Task 2: English page (`index.html`)

**Files:**
- Create: `index.html`

**Interfaces:**
- Consumes: class names and assets from Task 1 (`assets/style.css`, `assets/logo.svg`).
- Produces: section ids `what-we-do`, `focus-areas`, `get-involved` — the FR page (Task 3) uses the same ids so the language toggle lands on equivalent sections.

- [ ] **Step 1: Create `index.html`** with exactly:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>FPSOT — Foundation for Public Sector Open Technology</title>
  <meta name="description" content="FPSOT helps governments and public institutions adopt, build, and sustain free and open technologies.">
  <link rel="canonical" href="https://fpsot-org.github.io/">
  <link rel="alternate" hreflang="en" href="https://fpsot-org.github.io/">
  <link rel="alternate" hreflang="fr" href="https://fpsot-org.github.io/fr/">
  <link rel="alternate" hreflang="x-default" href="https://fpsot-org.github.io/">
  <meta property="og:type" content="website">
  <meta property="og:title" content="FPSOT — Foundation for Public Sector Open Technology">
  <meta property="og:description" content="Where public sector meets open innovation. Helping governments adopt, build, and sustain free and open technologies.">
  <meta property="og:url" content="https://fpsot-org.github.io/">
  <link rel="icon" href="assets/logo.svg" type="image/svg+xml">
  <link rel="stylesheet" href="assets/style.css">
</head>
<body>
  <header class="site-header">
    <div class="container">
      <a class="brand" href="/"><img src="assets/logo.svg" alt="FPSOT home"></a>
      <nav aria-label="Site">
        <a href="https://github.com/fpsot-org">GitHub</a>
        <a class="lang-switch" href="/fr/" lang="fr" hreflang="fr">Français</a>
      </nav>
    </div>
  </header>

  <main>
    <section class="hero">
      <div class="container">
        <h1>Public services should run on open technology.</h1>
        <p>The Foundation for Public Sector Open Technology (FPSOT) helps governments and public institutions adopt, build, and sustain software that is transparent, interoperable, and community-owned.</p>
        <a class="cta-button" href="https://github.com/fpsot-org">Get involved on GitHub</a>
      </div>
    </section>

    <section class="pillars" id="what-we-do">
      <div class="container">
        <h2>What we do</h2>
        <div class="grid">
          <div class="card">
            <h3>Support the public sector</h3>
            <p>Guidance, reference architectures, and best practices for governments adopting open source and open standards.</p>
          </div>
          <div class="card">
            <h3>Build and maintain open technology</h3>
            <p>Reusable, government-grade open source components and reference implementations.</p>
          </div>
          <div class="card">
            <h3>Advocate for policy change</h3>
            <p>Procurement, funding, and legal frameworks that prioritize open technologies and digital sovereignty.</p>
          </div>
          <div class="card">
            <h3>Educate and connect</h3>
            <p>Learning resources, worked examples, and communities of practice for public servants, vendors, and contributors.</p>
          </div>
        </div>
      </div>
    </section>

    <section class="focus" id="focus-areas">
      <div class="container">
        <h2>What we're working on first</h2>
        <ul class="focus-list">
          <li><strong>Reference architectures</strong> for modern public-sector systems</li>
          <li><strong>Policy &amp; procurement templates</strong> for FOSS-friendly RFPs</li>
          <li><strong>Sample projects</strong> showing how to build government-ready systems with open technologies</li>
          <li><strong>Migration playbooks</strong> for moving from proprietary stacks to open source</li>
        </ul>
        <p class="status">All of this is in progress and shaped in the open — early input is welcome.</p>
      </div>
    </section>

    <section class="get-involved" id="get-involved">
      <div class="container">
        <h2>Get involved</h2>
        <p>FPSOT is at an early stage, and the people who show up now will shape its direction.</p>
        <ul>
          <li><a href="https://github.com/fpsot-org/.github/issues">Open an issue</a> with an idea or question — this is our front door.</li>
          <li>Contribute documentation, examples, or code through <a href="https://github.com/fpsot-org">any FPSOT repository</a>.</li>
          <li>Work in the public sector? We would especially like to hear from you — say hello in an issue.</li>
        </ul>
      </div>
    </section>
  </main>

  <footer class="site-footer">
    <div class="container">
      <span>© FPSOT — Foundation for Public Sector Open Technology</span>
      <span><a href="https://github.com/fpsot-org/fpsot-org.github.io/blob/main/LICENSE">Apache-2.0</a> · <a href="https://github.com/fpsot-org">GitHub</a></span>
    </div>
  </footer>
</body>
</html>
```

- [ ] **Step 2: Verify locally**

```bash
python3 -m http.server 8321 --directory /home/jn/Projects/fpsot-org/fpsot-org.github.io &
sleep 1
curl -s http://localhost:8321/ | grep -c 'lang="en"'   # expect ≥ 1
curl -s http://localhost:8321/ | grep -c 'hreflang'    # expect 3
curl -s http://localhost:8321/ | grep -cE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' # expect 0 (no email addresses)
kill %1
```

Expected: `lang="en"` present, 3 hreflang links, no email addresses.

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "Add English landing page"
```

---

### Task 3: French page (`fr/index.html`)

**Files:**
- Create: `fr/index.html`

**Interfaces:**
- Consumes: `../assets/style.css`, `../assets/logo.svg`, section ids from Task 2 (`what-we-do`, `focus-areas`, `get-involved`).

- [ ] **Step 1: Create `fr/index.html`** with exactly:

```html
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>FPSOT — Fondation pour la technologie ouverte du secteur public</title>
  <meta name="description" content="La FPSOT aide les gouvernements et les institutions publiques à adopter, à développer et à maintenir des technologies libres et ouvertes.">
  <link rel="canonical" href="https://fpsot-org.github.io/fr/">
  <link rel="alternate" hreflang="en" href="https://fpsot-org.github.io/">
  <link rel="alternate" hreflang="fr" href="https://fpsot-org.github.io/fr/">
  <link rel="alternate" hreflang="x-default" href="https://fpsot-org.github.io/">
  <meta property="og:type" content="website">
  <meta property="og:title" content="FPSOT — Fondation pour la technologie ouverte du secteur public">
  <meta property="og:description" content="Là où le secteur public rencontre l'innovation ouverte. Aider les gouvernements à adopter, à développer et à maintenir des technologies libres et ouvertes.">
  <meta property="og:url" content="https://fpsot-org.github.io/fr/">
  <link rel="icon" href="../assets/logo.svg" type="image/svg+xml">
  <link rel="stylesheet" href="../assets/style.css">
</head>
<body>
  <header class="site-header">
    <div class="container">
      <a class="brand" href="/fr/"><img src="../assets/logo.svg" alt="Accueil FPSOT"></a>
      <nav aria-label="Site">
        <a href="https://github.com/fpsot-org">GitHub</a>
        <a class="lang-switch" href="/" lang="en" hreflang="en">English</a>
      </nav>
    </div>
  </header>

  <main>
    <section class="hero">
      <div class="container">
        <h1>Les services publics devraient reposer sur des technologies ouvertes.</h1>
        <p>La Fondation pour la technologie ouverte du secteur public (FPSOT) aide les gouvernements et les institutions publiques à adopter, à développer et à maintenir des logiciels transparents, interopérables et appartenant à la communauté.</p>
        <a class="cta-button" href="https://github.com/fpsot-org">Participer sur GitHub</a>
      </div>
    </section>

    <section class="pillars" id="what-we-do">
      <div class="container">
        <h2>Ce que nous faisons</h2>
        <div class="grid">
          <div class="card">
            <h3>Soutenir le secteur public</h3>
            <p>Conseils, architectures de référence et bonnes pratiques pour les gouvernements qui adoptent le logiciel libre et les normes ouvertes.</p>
          </div>
          <div class="card">
            <h3>Développer et maintenir des technologies ouvertes</h3>
            <p>Des composants libres réutilisables de qualité gouvernementale et des implémentations de référence.</p>
          </div>
          <div class="card">
            <h3>Promouvoir des politiques ouvertes</h3>
            <p>Des cadres d'approvisionnement, de financement et juridiques qui privilégient les technologies ouvertes et la souveraineté numérique.</p>
          </div>
          <div class="card">
            <h3>Former et rassembler</h3>
            <p>Des ressources d'apprentissage, des exemples concrets et des communautés de pratique pour les fonctionnaires, les fournisseurs et les contributeurs.</p>
          </div>
        </div>
      </div>
    </section>

    <section class="focus" id="focus-areas">
      <div class="container">
        <h2>Nos premiers chantiers</h2>
        <ul class="focus-list">
          <li><strong>Architectures de référence</strong> pour des systèmes publics modernes</li>
          <li><strong>Modèles de politiques et d'approvisionnement</strong> pour des appels d'offres favorables au logiciel libre</li>
          <li><strong>Projets exemples</strong> montrant comment bâtir des systèmes prêts pour le gouvernement avec des technologies ouvertes</li>
          <li><strong>Guides de migration</strong> pour passer de solutions propriétaires au logiciel libre</li>
        </ul>
        <p class="status">Tout cela est en cours et se construit ouvertement — vos idées sont les bienvenues dès maintenant.</p>
      </div>
    </section>

    <section class="get-involved" id="get-involved">
      <div class="container">
        <h2>Participer</h2>
        <p>La FPSOT en est à ses débuts : celles et ceux qui s'impliquent maintenant façonneront son orientation.</p>
        <ul>
          <li><a href="https://github.com/fpsot-org/.github/issues">Ouvrez un billet</a> avec une idée ou une question — c'est notre porte d'entrée.</li>
          <li>Contribuez à la documentation, aux exemples ou au code dans <a href="https://github.com/fpsot-org">n'importe quel dépôt FPSOT</a>.</li>
          <li>Vous travaillez dans le secteur public? Nous voulons particulièrement vous entendre — écrivez-nous dans un billet.</li>
        </ul>
      </div>
    </section>
  </main>

  <footer class="site-footer">
    <div class="container">
      <span>© FPSOT — Fondation pour la technologie ouverte du secteur public</span>
      <span><a href="https://github.com/fpsot-org/fpsot-org.github.io/blob/main/LICENSE">Apache-2.0</a> · <a href="https://github.com/fpsot-org">GitHub</a></span>
    </div>
  </footer>
</body>
</html>
```

- [ ] **Step 2: Verify locally**

```bash
python3 -m http.server 8321 --directory /home/jn/Projects/fpsot-org/fpsot-org.github.io &
sleep 1
curl -s http://localhost:8321/fr/ | grep -c 'lang="fr"'          # expect ≥ 1
curl -s http://localhost:8321/fr/ | grep -c '../assets/style.css' # expect 1
kill %1
```

Expected: `lang="fr"` present, stylesheet path resolves relative to `/fr/`.

- [ ] **Step 3: Commit**

```bash
git add fr/index.html
git commit -m "Add French landing page"
```

---

### Task 4: Full verification and deploy

**Files:**
- No new files. Push existing commits.

- [ ] **Step 1: Whole-site checks (local)**

```bash
cd /home/jn/Projects/fpsot-org/fpsot-org.github.io
# No external requests: no http(s) resources loaded except link/anchor hrefs to github.com
grep -RnoE 'src="https?://|<script' index.html fr/index.html && echo "FAIL: external resource or script" || echo "OK"
# No email addresses anywhere
grep -RnoE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' index.html fr/index.html assets/ && echo "FAIL: email found" || echo "OK"
# Both pages have exactly one h1
grep -c '<h1>' index.html; grep -c '<h1>' fr/index.html   # expect 1 and 1
```

Expected: both "OK" lines, h1 counts both 1.

- [ ] **Step 2: HTML validation** (best effort — use tidy if installed)

```bash
command -v tidy >/dev/null && (tidy -q -e index.html; tidy -q -e fr/index.html) || echo "tidy not installed — skip"
```

Expected: no errors (warnings acceptable).

- [ ] **Step 3: Push**

```bash
git push origin main
```

- [ ] **Step 4: Verify live site**

```bash
sleep 60   # allow Pages build
curl -s https://fpsot-org.github.io/ | grep -c 'lang="en"'      # expect ≥ 1
curl -s https://fpsot-org.github.io/fr/ | grep -c 'lang="fr"'   # expect ≥ 1
curl -s -o /dev/null -w '%{http_code}\n' https://fpsot-org.github.io/assets/style.css  # expect 200
```

Expected: both pages live with correct lang, stylesheet served.

- [ ] **Step 5: Lighthouse (best effort)**

If a Chromium binary is available: `npx --yes lighthouse https://fpsot-org.github.io/ --only-categories=performance,accessibility,seo --chrome-flags="--headless" --output=json --output-path=/tmp/lh.json && jq '.categories | map_values(.score)' /tmp/lh.json` — expect all scores ≥ 0.95. If no Chromium is available, note it and rely on the Step 1 checks (the page is static with no JS, so performance/SEO risks are structural, already covered).
