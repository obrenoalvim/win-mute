# TODO SEO

> Last updated: 2026-09-11

## Pending Changes

### Custom social preview image
- **Source:** https://www.gitdevtool.com/blog/github-seo (GitHub SEO guide, 2025) + generic OG/link-preview best practice
- **What:** Upload a 1280x640px social preview image (Settings > General > Social preview) so links shared on Slack/Discord/Twitter/LinkedIn show a designed card instead of GitHub's generic default.
- **Where:** GitHub web UI only, no API/CLI endpoint exists for this (confirmed: `gh repo edit` has no flag for it, no public REST/GraphQL mutation either).
- **Why:** Higher click-through when the repo link is shared; also referenced repeatedly as a discoverability signal in GitHub SEO guides.
- **Risk:** None, purely additive. Needs actual design work (a simple dark card with "win-mute" + a one-line tagline would match the GUI's own dark/teal look).
- **Effort:** Low (design) + manual upload.

### Submit to relevant awesome-lists
- **Source:** GitHub SEO research (2026) — awesome-lists cited as a real backlink/discoverability source for AI-citation probability and search indexing.
- **What:** Open PRs adding win-mute to `awesome-windows`, `awesome-powershell`, and possibly `awesome-privacy` style curated lists.
- **Where:** External repos, not this one. Each list has its own contribution rules (format, one-line description, alphabetical ordering) — read each CONTRIBUTING.md before submitting.
- **Why:** Real backlinks from high-traffic curated lists is one of the few reliable ways to get a small OSS repo discovered outside GitHub's own search.
- **Risk:** This is action on someone else's repo (opening a PR), needs explicit go-ahead before doing it — not something to automate silently.
- **Effort:** Low per list, but needs the user (or an explicit ask) to pick which lists and approve the PRs.

### Consider a GitHub Pages landing page
- **Source:** General GEO/SEO research this cycle — most of the classic tactics (robots.txt, sitemap.xml, Open Graph/Twitter meta tags, JSON-LD structured data) only apply to a hosted HTML page, which this project doesn't have (it's a script repo, README is the landing page).
- **What:** A one-page GitHub Pages site (docs/ folder or gh-pages branch) would unlock the full classic SEO toolkit: proper `<meta>` tags, JSON-LD `SoftwareApplication` structured data, a real sitemap.xml/robots.txt, and a shareable URL prettier than a raw GitHub repo link.
- **Where:** New `docs/index.html` (or separate branch) + repo Settings > Pages.
- **Why:** README-as-landing-page caps how much on-page SEO is possible; a real page can rank for "windows privacy tool" style queries in ways a repo page can't.
- **Risk:** Bigger scope decision (new deploy surface to maintain), not a quick additive fix. Worth doing only if the project gets enough traction to justify it.
- **Effort:** Medium.
