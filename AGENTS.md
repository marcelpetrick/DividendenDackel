# AGENTS.md

Working agreements for this repository, for human contributors and AI agents
alike. If anything here contradicts a general habit you brought with you, this
file wins.

This file is tool-agnostic on purpose: it is the single source of truth for how
to work here, whatever assistant or editor is reading it. Do not fork its rules
into an assistant-specific file — point that file at this one instead.

DividendenDackel is a Flutter application for Android 10+ and Linux x86_64 that
turns a local portfolio into a timeline of dividends and upcoming events. It is
a single-maintainer project with a deliberately strict quality gate: **the gate
is the point, so do not work around it.**

---

## 1. The golden rule

[`Vision.md`](Vision.md) is the specification. [`docs/BACKLOG.md`](docs/BACKLOG.md)
is the work queue. When this file cites a section like "Vision.md §58", that
section is the authority and this file is the summary.

Never commit red checks. Never accumulate unrelated changes into one commit.

### 1.1 The per-task loop (Vision.md §65)

1. Take the **first unchecked task** in `docs/BACKLOG.md`.
2. Mark it `[~]` and implement the smallest coherent change that completes it.
3. `dart format .`
4. `flutter analyze` — must be clean, with no new ignores.
5. `flutter test` — must pass; add tests for the new behaviour.
6. Self-review the diff (Vision.md §66): unintended files, naming, error and
   empty states, async behaviour, null/empty handling, Android + Linux
   compatibility, docs still accurate.
7. Fix what the review found and re-run the checks.
8. Tick the task to `[x]` and make **one** atomic Conventional Commit.

### 1.2 Definition of Done (Vision.md §87)

Requirement implemented · Android considered · Linux considered · loading,
empty, error and offline states · tests added or updated · format, analyze and
tests pass · diff self-reviewed · docs updated if needed · atomic commit.

---

## 2. Commits

### 2.1 One concern per commit

A commit is a package of: the change, its version bump, its tests and the
documentation it invalidates. If you cannot describe it in one Conventional
Commit subject without "and", it is two commits.

### 2.2 Conventional Commits (Vision.md §63, §64)

`feat`, `fix`, `perf`, `build`, `ci`, `docs`, `test`, `refactor`, `chore`, with
an optional scope and a `!` for a breaking change. The type is not cosmetic:
`tool/release-notes.sh` groups the published release notes from these subjects,
and `tool/check-version.sh` derives the expected version bump from them. A
`feat:` that was really a fix mislabels the release and demands the wrong bump.

### 2.3 Every commit bumps the version — with two exceptions

`pubspec.yaml` is the single source of truth: `version: <semver>+<build>`.
Pre-1.0 the major stays at `0`.

| Commit | Bump |
| --- | --- |
| `feat:`, or any type marked breaking with `!` | minor, patch reset to 0 |
| everything else | patch |

The build number rises by exactly one per commit.

Two kinds of commit may leave the version where it is, because neither can run
the bump script in the first place:

| Commit | Why |
| --- | --- |
| touches only `docs/`, `.github/`, `.idea/`, `.claude/`, a root `*.md` or `LICENSE` | nothing the application is built from changed, so the artifact is bit-identical. Editing `README.md` in the GitHub web UI is the normal case. |
| authored by a bot, i.e. Dependabot | it has no way to bump the version in the branch it opens; the reviewer merging it carries the change. |

**This is a floor, not a licence.** A commit you make locally bumps, whatever it
touches. The exemption exists only for the two cases where the tooling is out of
reach. A commit that *does* move the version is validated like any other, and
the next commit steps on from whatever its parent carries — so the sequence
pauses rather than drifts.

> **Why this exists.** The rule began as a convention and drifted: two feature
> commits once shipped under one version. It became mechanical in `bc3e13d`.
> That first version was absolute, and it broke the build the first time a
> README was edited on github.com, where no script can run — and it would have
> blocked every Dependabot pull request for the same reason. A version
> identifies a build; a commit that cannot change the build does not need one.

### 2.4 Pushing and releasing

Commit locally by default. Push, tag and publish when the maintainer asks for
it — do not do any of the three on your own initiative. A release is public and
cannot be quietly withdrawn.

**Do not push while a release run is in flight.** A manually dispatched release
checks out `${{ inputs.ref || github.ref }}`, and `github.ref` is the branch,
resolved separately by each job when that job starts. A push landing mid-run can
therefore have different jobs build different commits, and the tag is created on
whatever the publishing job happened to see. Wait for the run to finish, then
push.

---

## 3. How to bump the version

```sh
./tool/bump-version.sh feat                  # minor
./tool/bump-version.sh fix                   # patch
./tool/bump-version.sh refactor --breaking   # minor
```

Run it **before** committing; the bump belongs in the same commit as the change.
To check what a branch adds:

```sh
./tool/check-version.sh                # origin/master..HEAD
./tool/check-version.sh <base> <head>
```

Never hand-edit `version:`. The version reaches the About screen, the release
tag, the artifact filenames and the release notes from that one line.

---

## 4. The quality gate

`localPipeline.sh` **is** the gate. CI calls the same script developers run, so
the two cannot drift apart.

**When the gate changes, change `localPipeline.sh`, never the workflow's command
list.** A workflow's job is to install the pinned toolchain and publish
artifacts — nothing else.

```sh
./localPipeline.sh --noRun                    # full gate, no app launch
./localPipeline.sh                            # ... plus the rendered Linux smoke test
./localPipeline.sh --noRun --stage quality    # toolchain, deps, format, analyze, tests
./localPipeline.sh --noRun --stage integration
./localPipeline.sh --stage linux
./localPipeline.sh --noRun --stage android
./localPipeline.sh --selfTest                 # prove the pipeline reports failures as failures
```

Individual commands:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build linux --release   # build/linux/x64/release/bundle
flutter build apk --release     # build/app/outputs/flutter-apk/app-release.apk
```

### 4.1 The gate's own gates

Two checks exist because a gate that silently passes everything is worse than no
gate:

* `./tool/test-check-version.sh` builds throwaway repositories and asserts every
  rule in §2.3, including the ones the exemptions must not weaken. The **Version
  scheme** stage runs it before it trusts the checker's verdict.
* `./localPipeline.sh --selfTest` proves the pipeline reports a failing command
  as a failure.

If you add a rule to the gate, add its counter-case too: a test that fails when
the rule is removed.

---

## 5. Continuous integration

`.github/workflows/ci.yml` runs on pushes to `master`, pull requests and manual
dispatch. Five jobs, each proving something distinct:

| Job | What it proves |
| --- | --- |
| Version scheme | every commit the push adds moves the version exactly one step (§2.3) |
| Format, analyze, test | `--stage quality` is clean |
| Build Android APK | the release APK builds, and `minSdk` is still 29 |
| Android 10 portfolio journey | the real journey passes on an API 29 x86_64 emulator |
| Build Linux x86_64 | the bundle builds and the journey passes under Xvfb |

The **Version scheme** job needs `fetch-depth: 0`: it compares each commit
against its parent, which a shallow clone cannot do.

`.github/workflows/release.yml` publishes on a pushed `v*` tag or on manual
dispatch. On dispatch it reads the version from `pubspec.yaml`, refuses to
continue if that tag exists, runs the full gate, then creates the tag on the
exact commit it tested. It never publishes a draft or a pre-release. Only the
publishing job gets `contents: write`; everything else is read-only, and no
API key or signing secret reaches it.

`.github/workflows/freshness.yml` reports available dependency and toolchain
updates weekly. It reports; it does not change anything.

All third-party actions are pinned to full commit SHAs, never to a floating tag.

---

## 6. Toolchain

| Tool | Version | Where it is pinned |
| --- | --- | --- |
| Flutter | 3.47.1 (stable) | `PINNED_FLUTTER_VERSION` in `localPipeline.sh`, `FLUTTER_VERSION` in every workflow |
| Dart | 3.13.1 (ships with that Flutter) | `pubspec.yaml` `sdk:` |
| Java | 21 | `REQUIRED_JAVA_MAJOR` in `localPipeline.sh`, `java-version` in the workflows |

Change a pin in every place at once, or the local gate and CI disagree about
what "passing" means. Android Lint and the Gradle release build need JDK 21;
building on 17 fails in CI even when it appears to work locally.

Direct dependencies are pinned to exact versions, not ranges.

---

## 7. Hard constraints

These are product requirements, not preferences. Several are asserted
mechanically because review alone let them slip before.

* `minSdk` stays **29** (Android 10). Vision.md §58. The Android stage asserts it
  before it builds.
* No privileged provider secrets in the repository or the built app. API keys
  are user-supplied and stored locally. Vision.md §34, §80. A compiled app can
  be inspected, so a shipped key is not a secret.
* The app is fully usable offline from cached or sample data — never an empty
  screen because a provider is down. Vision.md §2.4, §44.
* **Never fabricate financial values.** Estimated ≠ confirmed, and the UI must
  show which is which. Vision.md §9.4, §48, §79. Where a number cannot be
  computed honestly, it is unavailable, not approximate.
* No BUY/SELL commands, no FOMO, no gamification. Explain, don't instruct.
  Vision.md §2.2, §85.
* One state-management approach: **Riverpod**. Vision.md §54.

---

## 8. Layout (Vision.md §53)

```
lib/app
lib/core/{errors,networking,logging,utils}
lib/domain/{entities,repositories,use_cases}
lib/data/{database,models,repositories,providers}
lib/features/{today,calendar,portfolio,research,status,settings}
lib/platform/{android,linux}
```

Domain logic stays independent of widgets and of provider DTOs. A domain entity
that imports Flutter, or knows a provider's JSON shape, is in the wrong layer.

---

## 9. Code style and tests

The analyzer is strict by configuration, not by convention:
`strict-casts`, `strict-inference` and `strict-raw-types` are on, and dead code,
unused imports and elements, unawaited and discarded futures, and non-assignable
arguments are **errors**. Do not add an `ignore:` to get past one; fix the code.
Generated files (`*.g.dart`, `*.freezed.dart`) are excluded.

Tests live in `test/`, mirroring `lib/`. The real end-to-end journeys live in
`integration_test/` and run on both a Linux desktop and an API 29 emulator —
they are evidence that the app works, not a smoke test, so keep them passing.

New behaviour ships with a test that fails without it. A bug fix ships with the
test that reproduced the bug.

---

## 10. Voice and naming

The product is **DividendenDackel** — a dachshund that fetches dividends out of
a pile of financial data. The name is the identity; use it everywhere the user
can see it (window title, About, store listing, docs).

* User-facing copy may carry the identity lightly — empty states, onboarding and
  the fetch/retrieval metaphor are fair game.
* Code identifiers stay plain and descriptive: `RequestCoordinator`,
  `DividendForecast`, never themed names. Maintainability beats the joke.
* The tone stays calm and trustworthy (Vision.md §24). Funny name, serious
  numbers — never cute about money, losses or estimates.

Application copy is localized in English, German and Croatian. User-visible
strings go through the localization layer, never inline.

---

## 11. Documentation that must stay true

A change that outdates one of these updates it in the same commit:

* [`README.md`](README.md) — badges restate facts the build enforces; if a
  pinned version changes, the badge changes with it.
* [`CHANGELOG.md`](CHANGELOG.md) — user-relevant detail, Keep a Changelog format.
* [`CONTRIBUTING.md`](CONTRIBUTING.md) — the toolchain table in §6.
* [`docs/releases.md`](docs/releases.md) — the version scheme and release flow.
* [`docs/data-providers.md`](docs/data-providers.md) — provider terms, before
  any adapter merges.
