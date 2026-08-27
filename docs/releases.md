# Releases

DividendenDackel uses Semantic Versioning. `pubspec.yaml` is the authoritative
application version in `major.minor.patch+build` form; Git tags omit the build
number, for example version `0.1.0+1` is tag `v0.1.0`.

## Release artifacts

A public release contains:

| Artifact | Contents |
| --- | --- |
| `dividendendackel-<version>-android.apk` | Android 10+ APK |
| `dividendendackel-<version>-linux-x86_64.tar.gz` | complete Linux desktop bundle |
| `SHA256SUMS` | SHA-256 digest for both downloads |

The Linux archive must be extracted as a directory; the executable depends on
the adjacent `lib/` and `data/` content. The 0.1.0 APK uses a development/debug
signing key and is suitable for direct testing, not Play Store publication. A
production signing configuration and protected credentials are required before
store distribution.

## Pre-release checklist

1. Confirm `CHANGELOG.md`, provider terms, tax assumptions and this document are
   current.
2. Confirm every required item in [`BACKLOG.md`](BACKLOG.md) is complete and the
   engineering review in [`../worst_findings.md`](../worst_findings.md) has no
   unresolved release blocker.
3. Run `./localPipeline.sh` with Flutter 3.47.1. Every stage must pass, including
   the rendered Linux first-frame check and both release builds.
4. Smoke-test the APK on Android 10/API 29 and the Linux bundle on a clean
   supported x86_64 desktop.
5. Verify database upgrades from every previously released schema preserve
   holdings and settings.
6. Review `git status`, the exact release commit and generated notes:

   ```sh
   ./tool/release-notes.sh 0.1.0 > /tmp/dividendendackel-release-notes.md
   ```

7. Create an annotated tag only on the reviewed commit:

   ```sh
   git tag -a v0.1.0 -m "DividendenDackel 0.1.0"
   git show --no-patch v0.1.0
   ```

8. Push the commit and tag deliberately. Pushing `v*` starts the release
   workflow; creating a local tag alone publishes nothing.

## Automated release workflow

`.github/workflows/release.yml` checks out the exact tag and rejects a tag that
does not match `pubspec.yaml`. It installs the pinned Flutter and Java
toolchains, runs the same full local pipeline, copies the raw APK, archives the
Linux bundle, generates checksums and release notes, and publishes a non-draft,
non-prerelease GitHub Release.

Third-party actions are pinned to full commit SHAs. The workflow defaults to
read-only repository access and grants `contents: write` only to the publishing
job. It receives no application API key or signing secret.

`workflow_dispatch` can republish an existing matching tag for recovery. It
must not be used to bypass the tag/version or quality checks.

## Verification after publishing

- Confirm the GitHub Actions run is green and the release is public.
- Download all three files from the release, not the build workspace.
- Run `sha256sum --check SHA256SUMS` in the download directory.
- Extract and launch the Linux bundle; install and launch the APK on a supported
  Android device.
- Check About displays the expected version, build number and source commit.
- Confirm release notes cover features, fixes, provider changes and migrations.

If verification fails, do not move or silently replace the tag. Remove the bad
release assets if necessary, fix the problem in a new reviewed commit, increment
the patch/build version and publish a new tag so artifacts remain traceable.

## Database compatibility

Schema migrations are forward-only and explicit. A release must support every
schema shipped by an earlier public version; destructive reset is not an
upgrade strategy. A change that cannot preserve data needs a documented export
or migration path and is a breaking release concern.

## Conventional commits and notes

Release notes are generated from Conventional Commit subjects by
`tool/release-notes.sh`, then enriched with the exact commit, build timestamp,
Flutter version, Android SDK contract and checksums. Use `feat`, `fix`, `perf`,
`build`, `ci`, `docs`, `test` or `refactor` accurately; put user-relevant detail
in `CHANGELOG.md` rather than relying on commit history alone.

## 0.1.0 verification record

Recorded on 2026-08-23 before tagging:

- full rendered pipeline: 500 tests, strict analyzer, Linux integration and
  release first frame, Android and Linux release builds — all passed;
- Android 10/API 29: the real add-holding → portfolio → calendar → forecast →
  offline journey passed on an x86_64 Google APIs emulator;
- release APK: installed and cold-launched on API 29 in 535 ms, activity resumed
  and Android crash buffer empty;
- migrations: schema 1→4 preserved its legacy dividend row, 2→4 and 3→4 created
  their new tables, and an undefined migration was refused;
- artifacts: Linux bundle 29,653,312 bytes; APK 66,059,207 bytes;
- workflow syntax: CI, release, freshness and Dependabot configuration passed
  `actionlint` 1.7.12 / YAML parsing; all third-party Actions are full-SHA
  pinned.

The Android 10 portfolio journey is also a required CI and release-workflow job,
so future dependency and UI changes must preserve this runtime evidence.

## How to publish a release

Two ways, both producing an identical, public, non-draft release.

### From the Actions tab (no local git needed)

1. Open **Actions → Release → Run workflow**.
2. Leave *ref* empty to build the current head of the default branch, or enter
   a branch or commit to build that instead.
3. **Run workflow**.

The job reads the version from `pubspec.yaml`, refuses to continue if that tag
already exists, runs the full gate, builds both platforms, then creates the tag
on the exact commit it tested and publishes the release.

To release again, bump `version:` in `pubspec.yaml` first — the existing-tag
check is what stops two different builds sharing a version.

### By pushing a tag

```sh
git tag -a v0.42.8 -m "Release 0.42.8"
git push origin v0.42.8
```

The tag must match `pubspec.yaml`; a mismatch fails the job rather than
shipping artifacts labelled with the wrong version.

## What a release contains

| File | Platform | How to run |
| --- | --- | --- |
| `dividendendackel-<version>-android.apk` | Android 10 (API 29)+ | Install directly |
| `DividendenDackel-<version>-x86_64.AppImage` | Linux x86_64 | `chmod +x` it and run |
| `dividendendackel-<version>-linux-x86_64.tar.gz` | Linux x86_64 | Plain bundle |
| `SHA256SUMS` | — | Checksums for every artifact |

Both primary downloads are single files. A Flutter Linux build is a directory,
so the AppImage exists precisely so Linux users get a real direct download
rather than an archive to unpack.

## Release metadata

Every release body is generated, never hand-written:

- **What changed** — grouped from the Conventional Commit history since the
  previous tag: features, fixes, performance, internal changes, build,
  CI, documentation and tests, with breaking changes called out separately.
- **Build metadata** — semantic version and build number, the commit SHA, the
  UTC build time, the pinned Flutter version and channel, and the Android
  `minSdk`/`targetSdk` levels.
- **Checksums** — SHA-256 for every attached file, inline in the body as well
  as in `SHA256SUMS`.
- **Data sources** — what the app can do without an API key.

Generated by [`tool/release-notes.sh`](../tool/release-notes.sh), which can be
run locally to preview:

```sh
./tool/release-notes.sh 0.42.8 v0.42.7
```

## Versioning

`pubspec.yaml` is the single source of truth: `version: <semver>+<build>`.
The history follows Semantic Versioning from `0.0.0`:

| Commit | Bump |
| --- | --- |
| `feat:`, or any type marked breaking with `!` | minor, patch reset to 0 |
| everything else (`fix`, `docs`, `test`, `ci`, `build`, `chore`, `refactor`, `perf`) | patch |

The build number increases by one per commit. Pre-1.0 the major stays at `0`.

### Commits that may keep the version

A version identifies a build. Two commits may leave it where it is, because
neither can run `bump-version.sh` in the first place:

| Commit | Why |
| --- | --- |
| touches only `docs/`, `.github/`, `.idea/`, `.claude/`, a root `*.md` or `LICENSE` | nothing the application is built from changed, so the artifact is bit-identical. Editing `README.md` in the GitHub web UI is the normal case. |
| authored by a bot, i.e. Dependabot | it has no way to bump the version in the branch it opens; the reviewer merging it carries the change. |

This is a floor, not a licence. Such a commit that *does* move the version is
validated like any other, and the next commit steps on from whatever its parent
carries — so the sequence never drifts, it only pauses.

Commits you make locally should still bump, whatever they touch. The exemption
exists for the two cases where the tooling is out of reach.

### It is enforced, not trusted

This started as a convention and drifted: two feature commits once shipped
under the same version. It is now checked mechanically, so the rule and the
repository cannot disagree.

Before committing, apply the bump:

```sh
./tool/bump-version.sh feat        # minor
./tool/bump-version.sh fix         # patch
./tool/bump-version.sh refactor --breaking   # minor
```

To verify what a branch adds:

```sh
./tool/check-version.sh            # origin/master..HEAD
./tool/check-version.sh <base> <head>
```

`localPipeline.sh` runs the check as its **Version scheme** stage, and CI runs
it as a required `Version scheme` job over the commits each push adds. A commit
whose version does not move exactly one step fails the build and names the
version it should have had.

The checker is a gate, so it has its own cases — `./tool/test-check-version.sh`
builds throwaway repositories and asserts every rule above, and the **Version
scheme** stage runs them before it trusts the checker's verdict.
