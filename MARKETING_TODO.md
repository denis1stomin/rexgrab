# RexGrab — Marketing / Growth TODO

A working checklist for getting RexGrab some visibility (findable on Google, decent GitHub
star count) — separate from `CLAUDE.md`, which stays scoped to product/architecture decisions.
Seeded from an ad-hoc AI chat asking how to make the repo more discoverable; items below are
untouched so far.

## 1. GitHub repo "storefront"

Developers decide whether to trust a repo in under 10 seconds — the repo page itself needs to sell it.

- [ ] Add a short (~5s) demo GIF/video at the very top of `README.md` — the live thumbnail
      picker or a recording in progress, not just static screenshots.
- [ ] Add GitHub repo Topics (Settings → Topics): `screen-recorder`, `macos`,
      `screencapturekit`, `swiftui`, `zoom-recorder`, `open-source` — feeds GitHub's own
      Explore/search recommendations.
- [ ] Set a custom Social Preview image (Settings → Social preview) — a clean image built
      around the 🦖 dino icon, so shared links get a real preview card instead of a blank one.

## 2. Launch on developer platforms

Don't wait on organic Google crawling — post where the target audience already is.

- [ ] Reddit: r/sideproject, r/macapps, r/swift. Humble, specific framing, e.g. "I got tired
      of bloated Electron screen recorders, so I built RexGrab — a tiny, native macOS app that
      splits mic and system audio."
- [ ] Hacker News: "Show HN: RexGrab – a native, local-only macOS screen recorder."
- [ ] Product Hunt launch.
- [ ] DevHunt launch.

## 3. Lean into the privacy angle

- [ ] Make "fully local, nothing uploaded, no account" the headline pitch in every launch post
      — it's RexGrab's clearest differentiator from Loom/Zoom-style cloud recorders.
- [ ] Target remote tech workers documenting bugs / making quick internal demos.
- [ ] Call out that it's sandboxed + local-only as a plus for anyone under a company data
      policy that's wary of cloud-upload recording tools.

## 4. Reduce Gatekeeper friction (longer term, only once there's real traction)

- [ ] Revisit Apple Developer ID signing/notarization — cost/tradeoff already tracked in
      `CLAUDE.md`'s decision log ("Code signing / notarization").
- [ ] Add a Homebrew tap (`brew install --cask rexgrab`) as an easier install path than
      download-and-unzip, which is what most macOS devs expect. A personal tap (own
      `homebrew-rexgrab` repo + a ~15-line Cask file) is easy to set up and would also fix the
      Gatekeeper right-click friction for free (Homebrew strips the quarantine flag on cask
      installs since it verifies the checksum itself) — the official `homebrew-cask` repo is a
      separate, much harder bar (notability/usage requirements, PR review) not worth attempting
      yet. **Decision: hold off until after the next release**, not before.
