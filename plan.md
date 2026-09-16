# Agent handoff plan

Updated: 2026-09-16. The maintainer resumed work and requested iterative fixes,
with this plan updated in every commit. The active scope is release blockers,
final CI and the requested public release; optional product candidates remain
separate work.

## Current state

- Branch: `master`. Public release candidate: **0.65.8+128** at
  `6d91da29baa9d8292097c2d190da284462d80dcf`. Development documentation follow-up:
  **0.65.9+129**, required by the per-local-commit version rule. This follow-up
  records release verification; it does not replace the immutable 0.65.8 build.
- Remote `origin/master`: `6d91da29baa9d8292097c2d190da284462d80dcf`, version
  **0.65.8+128**. The release run is complete, so its no-push window has ended.
- Latest public release is
  [v0.65.8](https://github.com/marcelpetrick/DividendenDackel/releases/tag/v0.65.8).
  The [release run](https://github.com/marcelpetrick/DividendenDackel/actions/runs/35077311855)
  passed both jobs on the exact tested SHA, and the published tag and downloads
  were independently verified as recorded below.
- No open GitHub issues or pull requests were found. Dependabot PRs
  [#1](https://github.com/marcelpetrick/DividendenDackel/pull/1) and
  [#2](https://github.com/marcelpetrick/DividendenDackel/pull/2) are closed;
  their action updates are incorporated, with a newer stable release-action pin.
- Follow [`AGENTS.md`](AGENTS.md), [`Vision.md`](Vision.md) and
  [`docs/BACKLOG.md`](docs/BACKLOG.md). Never bypass a gate or hand-edit the
  application version.

## Completed work

- UI/UX backlog UX1–UX5: onboarding, Today hierarchy and native-currency KPIs,
  Research evidence previews, Calendar hierarchy, responsive/large-text/dark
  theme/keyboard/tap-target tests and lazy-list regression coverage. See
  [`docs/ui-ux-review.md`](docs/ui-ux-review.md) and
  [`worst_findings.md`](worst_findings.md).
- Dependency audit: all direct/dev dependencies and toolchain/action pins
  checked against stable upstream releases. Notifications updated to 22.3.1;
  compatible transitive locks refreshed. Flutter remains 3.47.4/Dart 3.13.3.
  Three newer transitive releases cannot resolve under the current stable SDK
  constraints: `cli_util`, `material_color_utilities` and `test_api`. Do not
  force dependency overrides to manufacture a clean freshness report.
- Finnhub quote/cache deletion before credential removal, with source-isolation
  and deletion-failure regressions. Other providers' data stays intact.
- All 25 pre-handoff Markdown files reviewed and linted; local links checked;
  stale provider, privacy, tax, release, route and status descriptions corrected.
  `.markdownlint-cli2.jsonc` records the repository's Markdown conventions.
- The first Android currency fix added scrolling and a phone-sized viewport,
  but final CI proved it insufficient. The resumed investigation reproduced
  the failure on a local API 29 Pixel: amount labels lacked currency codes,
  and desktop's expanded currency controls could satisfy a global USD finder.
  E3 now adds explicit native gross/converted net codes and scopes the journey
  to the held USD dividend. Five widget regressions cover English/German/
  Croatian, missing FX and currencies without a symbol.

Atomic commits already pushed:

| Commit | Concern | Version |
| --- | --- | --- |
| `4df7f92` | Stable dependency refresh | 0.65.3+123 |
| `09c87b0` | Finnhub retained quote deletion | 0.65.4+124 |
| `d42c694` | Documentation alignment | 0.65.5+125 |
| `e80c2ce` | Phone currency integration regression | 0.65.6+126 |
| `a612b11` | Initial agent handoff | 0.65.7+127 |
| `6d91da2` | Explicit held gross/net currency units | 0.65.8+128 |

Handoff commit `a612b11` corrects the Alpha Vantage provider-name typo and
records the initial handoff. The 0.65.8 fix also updates this plan, the backlog,
changelog and current-version documentation.

## Validation and CI

- The full rendered `./localPipeline.sh` passed for 0.65.6: **678 tests**, strict
  analysis, formatting, Linux application journeys, version scheme, `minSdk 29`,
  Android/Linux release builds and a rendered Linux first frame.
- The complete 0.65.7 rendered gate also passed, as recorded below.
- The nine version-checker counter-cases passed. Markdown lint and the dated
  changelog check passed before the handoff; run them again including this file.
- [CI run 35074729432](https://github.com/marcelpetrick/DividendenDackel/actions/runs/35074729432)
  tests pushed commit `e80c2ce`, not the final local documentation commit.
  **Final conclusion: failure.** Quality, version, Linux and Android APK passed;
  the Android 10 currency journey failed after scrolling without finding USD
  evidence (nine journeys passed, one failed). E3 addresses this failure.
- Previous CI run 35017903539 failed the Android currency visibility assertion;
  all four other jobs passed. The regression fix is in `e80c2ce`.
- An abandoned local integration-test process from the previous session failed
  an asynchronous changelog asset load and never exited. It was terminated;
  the subsequent complete rendered gate passed. No gate was bypassed.

Use the isolated pinned Flutter SDK, not the developer's older dirty SDK:

```sh
export PATH=/tmp/dividendendackel-flutter-3.47.4/bin:$PATH
./localPipeline.sh
./tool/test-check-version.sh
./tool/check-version.sh origin/master HEAD
./tool/check-changelog.sh 0.65.9
node /home/mpetrick/.local/share/fnm/node-versions/v20.20.1/installation/lib/node_modules/markdownlint-cli2/markdownlint-cli2-bin.mjs
```

The SDK under `/tmp` may disappear; reinstall the exact pinned version if needed.

## Completed release checklist

1. **E3 — fix the release-blocking currency evidence failure (complete).**
   Reproduced on the local API 29 Pixel. Five widget regressions failed before
   the production fix and now pass. All ten Android 10 journeys and the full
   rendered 683-test local gate pass. Diff self-reviewed; E3 is checked off.
   This atomic fix bumps to 0.65.8+128.
2. **Push and validate the candidate (complete).** `6d91da2` is pushed, and
   [CI run 35076379791](https://github.com/marcelpetrick/DividendenDackel/actions/runs/35076379791)
   passed all five jobs on its exact SHA, including Android 10 journeys.
3. **Publish (complete).** Version/tag absence and the dated changelog were
   checked, remote `master` matched the tested SHA, and `release.yml` was
   dispatched from that same head with the exact SHA as its `ref` input.
   [Run 35077311855](https://github.com/marcelpetrick/DividendenDackel/actions/runs/35077311855)
   passed Android 10 and build-and-publish.
4. **Verify publication (complete).** The public release is neither draft nor
   pre-release, its tag resolves to the tested SHA, all four assets downloaded,
   and all three artifact checksums match. The actual release is
   [v0.65.8](https://github.com/marcelpetrick/DividendenDackel/releases/tag/v0.65.8).

## Explicitly unfinished or limited

- Optional FMP adapter: blocked on the documented required licensing review,
  not silently marked complete.
- Live keyed Alpha Vantage/Finnhub smoke tests require user-supplied credentials;
  fixture contracts pass, but live keyed responses were not verified here.
- Android APK is debug/development-signed, not Play Store signed. Debug signing
  keys are not persisted across release runners, so in-place upgrades may fail.
  Do not uninstall to bypass a signing mismatch: that deletes local financial
  data. Persistent signing and a reviewed backup/upgrade strategy require a
  maintainer decision; no private key was invented or committed.
- Linux compositor/window-manager/HiDPI behavior is outside the compiled journey;
  Flutter's Linux integration plugin does not support screenshots.
- Optional post-MVP P7 encrypted sync, P8 widgets/tray mode and P9 advanced
  Research history remain open in the backlog. These are separate product work,
  not completed by the UI review or this release. Choose their scope explicitly
  after the release; preserve the local-first/offline and financial-integrity
  requirements.

## Final local gate

**PASS**, 2026-09-16, version 0.65.7+127: Flutter 3.47.4/Java 21, dependencies,
format, strict analysis, all 678 tests, all 10 compiled Linux journeys, version
scheme, `minSdk 29`, both release builds and rendered Linux first frame. The
saved log is `/tmp/dividendendackel-final-0.65.7-gate.log`.

Handoff-inclusive Markdown lint: **26 files, zero errors**. The 0.65.7 changelog
has two entries. The diff was self-reviewed before the atomic documentation
commit; no application logic changed in that commit.

### Resumed iteration: 0.65.8 currency evidence

**PASS**, 2026-09-16: all five widget regressions, all ten compiled API 29 Pixel
journeys, all 683 tests, strict analysis, formatting, all ten Linux journeys,
`minSdk 29`, both release builds and rendered Linux first frame. All nine
version-checker counter-cases, Markdown lint and changelog checks also pass.
Self-review is recorded in `worst_findings.md`. No financial calculation,
provider data or localization pattern was changed; labels retain explicit
native/converted units even without FX.

Logs:

- Before-fix Android reproduction:
  `/tmp/dividendendackel-android-currency-before.log` (failed as expected).
- Before-fix widget regressions:
  `/tmp/dividendendackel-currency-units-red.log` (five failed as expected).
- Complete Android 10 journeys:
  `/tmp/dividendendackel-android-0.65.8-journeys.log`.
- Full rendered local gate: `/tmp/dividendendackel-0.65.8-gate.log`.

### Final iteration: release verification documentation (0.65.9)

E4 is complete. The generated notes warn against destructive Android
reinstallation, with an automated regression ensuring the warning stays
present. The published 0.65.8 notes carry the same warning without changing its
assets or tag.

The full rendered documentation-follow-up gate passed on 2026-09-16:
**684 tests**, strict analysis, format, ten Linux journeys, version scheme,
`minSdk 29`, both release builds and rendered Linux first frame. Saved log:
`/tmp/dividendendackel-0.65.9-verification-gate.log`. Markdown lint is also clean
across all 26 files.

Release verification completed on 2026-09-16:

- both release jobs succeeded on
  `6d91da29baa9d8292097c2d190da284462d80dcf`;
- public tag `v0.65.8` resolves to that exact SHA, and the release is neither a
  draft nor a pre-release;
- the APK, AppImage, Linux tarball and `SHA256SUMS` downloaded into
  `/tmp/dividendendackel-v0.65.8-verify.w42bUb`;
- `sha256sum -c SHA256SUMS` passed for all three artifacts: AppImage
  `b0a203e7…f3ccee`, APK `a3cbde5c…07af2`, and tarball
  `4f1b2185…00835`;
- the AppImage reports its embedded type-2 runtime, and the tarball retains an
  executable `dividendendackel` binary with the expected Flutter bundle;
- `apksigner` verifies the APK's v2 signature and its sole certificate is
  `C=US, O=Android, CN=Android Debug`, SHA-256
  `27b636464f53d2cf99f49cb05ea6425dda6e5d5e8358ef0b2c4d5835d7337774`.

The public release URL is
<https://github.com/marcelpetrick/DividendenDackel/releases/tag/v0.65.8>.
