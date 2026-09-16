# Agent handoff plan

Updated: 2026-09-16. The maintainer asked to stop and continue with another
agent. Do not start a release or expand the backlog until work is resumed.

## Current state

- Branch: `master`. Final local version: **0.65.7+127**.
- Remote `origin/master`: `e80c2ceae14d7864314dc6b32581c469a9d59671`,
  version **0.65.6+126**. The final documentation/handoff commit is local only.
- Latest public release remains
  [v0.61.8](https://github.com/marcelpetrick/DividendenDackel/releases/tag/v0.61.8).
  No new release was dispatched in this session.
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
- Android-only journey failure diagnosed: lazy USD evidence was outside the
  phone viewport. The journey now scrolls to it and also exercises the API 29
  logical viewport locally.

Atomic commits already pushed:

| Commit | Concern | Version |
| --- | --- | --- |
| `4df7f92` | Stable dependency refresh | 0.65.3+123 |
| `09c87b0` | Finnhub retained quote deletion | 0.65.4+124 |
| `d42c694` | Documentation alignment | 0.65.5+125 |
| `e80c2ce` | Phone currency integration regression | 0.65.6+126 |

The final local documentation commit corrects the Alpha Vantage provider-name
typo, records this handoff and bumps to 0.65.7+127.

## Validation and CI

- The full rendered `./localPipeline.sh` passed for 0.65.6: **678 tests**, strict
  analysis, formatting, Linux application journeys, version scheme, `minSdk 29`,
  Android/Linux release builds and a rendered Linux first frame.
- Final 0.65.7 gate result is recorded below before this handoff is committed.
- The nine version-checker counter-cases passed. Markdown lint and the dated
  changelog check passed before the handoff; run them again including this file.
- [CI run 35074729432](https://github.com/marcelpetrick/DividendenDackel/actions/runs/35074729432)
  tests pushed commit `e80c2ce`, not the final local documentation commit.
  At handoff, quality, version and Linux checks had passed; Android APK and
  Android 10 journey jobs were still running. Inspect its final
  conclusion instead of assuming success.
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
./tool/check-changelog.sh 0.65.7
node /home/mpetrick/.local/share/fnm/node-versions/v20.20.1/installation/lib/node_modules/markdownlint-cli2/markdownlint-cli2-bin.mjs
```

The SDK under `/tmp` may disappear; reinstall the exact pinned version if needed.

## Remaining work, highest priority first

1. **Resume and inspect state.** Read this file and the repository agreements;
   inspect `git status`, local/remote history and the CI run above. Resolve any
   real CI failure with a reproducing test, full gate and atomic versioned
   commit. Do not publish a failing candidate.
2. **Push the final local commit when resumed.** Fetch first and verify the
   version sequence. Check there is no queued/in-progress `release.yml` run
   before pushing. Wait for all five CI jobs on the final exact SHA to pass,
   especially the Android 10 portfolio journey.
3. **Publish only after the maintainer resumes release work.** Confirm
   `v0.65.7` does not already exist (or use the new version if fixes were needed),
   the dated changelog section is nonempty, and remote `master` equals the SHA
   tested by CI. Dispatch `release.yml` from that same `master` SHA, optionally
   supplying that exact SHA as its `ref` input. The workflow metadata/tag target
   use `github.sha`, so do not dispatch from a different branch head.
4. **Do not push during the release run.** Wait for both release jobs to finish.
   Verify the public release is neither draft nor prerelease and that its tag
   resolves to the tested SHA. Download the APK, Linux AppImage, Linux tarball
   and `SHA256SUMS` into a temporary directory; verify all three checksums.
   Report the actual release URL, not just the workflow dispatch.

## Explicitly unfinished or limited

- Public release of the new work: **not published**; paused for agent handoff.
- Optional FMP adapter: blocked on the documented required licensing review,
  not silently marked complete.
- Live keyed Alpha Vantage/Finnhub smoke tests require user-supplied credentials;
  fixture contracts pass, but live keyed responses were not verified here.
- Android APK is debug/development-signed, not Play Store signed.
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
