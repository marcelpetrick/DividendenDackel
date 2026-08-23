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
