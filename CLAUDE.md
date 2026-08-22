# Working agreement — DividendenDackel

`Vision.md` is the specification. `docs/BACKLOG.md` is the work queue.

## Per-task loop (Vision.md §65)

1. Take the **first unchecked task** in `docs/BACKLOG.md`.
2. Mark it `[~]`, implement the smallest coherent change that completes it.
3. `dart format .`
4. `flutter analyze` — must be clean, no new ignores.
5. `flutter test` — must pass; add tests for the new behaviour.
6. Self-review the diff (Vision.md §66): unintended files, naming, error and
   empty states, async behaviour, null/empty handling, Android + Linux
   compatibility, docs still accurate.
7. Fix what the review found, re-run the checks.
8. Tick the task to `[x]` and make **one** atomic Conventional Commit.

Never accumulate unrelated changes into one commit. Never commit red checks.

## Definition of Done (Vision.md §87)

Requirement implemented · Android considered · Linux considered · loading,
empty, error and offline states · tests added or updated · format, analyze and
tests pass · diff self-reviewed · docs updated if needed · atomic commit.

## Voice and naming

The product is **DividendenDackel** — a dachshund that fetches dividends out of
a pile of financial data. The name is the identity; use it everywhere the user
can see it (window title, About, store listing, docs).

- User-facing copy may carry the identity lightly — empty states, onboarding
  and the fetch/retrieval metaphor are fair game.
- Code identifiers stay plain and descriptive: `RequestCoordinator`,
  `DividendForecast`, not themed names. Maintainability beats the joke.
- The tone stays calm and trustworthy (Vision.md §24). Funny name, serious
  numbers — never cute about money, losses or estimates.

## Hard constraints

- `minSdk` stays **29** (Android 10). Vision.md §58.
- No privileged provider secrets in the repo or the built app. API keys are
  user-supplied and stored locally. Vision.md §34, §80.
- The app must be fully usable offline from cached/sample data — never an empty
  screen because a provider is down. Vision.md §2.4, §44.
- Never fabricate financial values. Estimated ≠ confirmed, and the UI must show
  which is which. Vision.md §9.4, §48, §79.
- No BUY/SELL commands, no FOMO, no gamification. Explain, don't instruct.
  Vision.md §2.2, §85.
- One state-management approach: **Riverpod**. Vision.md §54.
- Conventional Commits, atomic. Vision.md §63, §64.

## Layout (Vision.md §53)

```
lib/app · lib/core/{errors,networking,logging,utils} · lib/domain/{entities,repositories,use_cases}
lib/data/{database,models,repositories,providers} · lib/features/{today,calendar,portfolio,research,status,settings}
lib/platform/{android,linux}
```

Domain logic stays independent of widgets and provider DTOs.

## Commands

```
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build linux --release
flutter build apk --release
```
