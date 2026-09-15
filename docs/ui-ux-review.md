# UI/UX review and improvement plan

Review date: 2026-09-14
Review scope: Android phone and Linux desktop, light and dark themes, first-run,
empty, data-rich, loading, error and offline states
Perspective: product design for a local-first personal-finance application

## Executive assessment

DividendenDackel already has the harder half of a trustworthy finance product:
amounts keep their currency, estimates are labelled, unavailable evidence is not
silently replaced with zero, provider freshness is visible, destructive actions
are confirmed, and colour is not the only status signal. The UI is calm and
consistent and the primary navigation is appropriately small.

The main weakness is not correctness but prioritisation. Most surfaces use the
same card weight, padding and text density, so a user has to read rather than
scan. The first-run path explains the product well but ends at an empty Today
screen without a dominant next action. On a wide Linux window, Today remains a
single long column; Research is a plain list that conceals its most useful
signal; and Calendar devotes a large first band to controls before showing the
financial schedule.

The goal of this pass is therefore **faster comprehension without reducing
financial honesty**. It must not create a more colourful dashboard by hiding
assumptions, merging currencies or turning research into advice.

## What already works

- Calm green-led palette and restrained positive/negative tones suit a serious
  money product; signs, icons and labels keep meaning independent of colour.
- Four top-level destinations match the user's recurring jobs and work as a
  bottom bar on phones and a rail on desktop.
- Gross and estimated net values remain separate, with tax and FX limitations
  close to the number they qualify.
- Cached data remains visible through refresh and provider errors.
- Cards and controls scale without overflow at the tested large text sizes.
- Calendar estimates use both a shape/letter marker and a written status.
- The copy explains evidence and uncertainty instead of suggesting BUY/SELL
  actions or inventing precision.

## Ranked findings

### 1. High — first-run activation ends in a dead end

The three onboarding pages are informative, but they are passive. Completion
opens Today with `0 holdings`, six data regions and no primary action in the
visible content. A beginner has to infer that Portfolio is the place to start.
This is the largest likely abandonment point.

Improve by giving the empty Today state one clear action, explaining the short
path from holding to useful schedule, and carrying the product identity into
onboarding. Do not auto-create a portfolio or fabricate financial values.

### 2. High — Today lacks a finance-dashboard hierarchy

Portfolio value, day change, holdings and relevant events appear as ordinary
body rows. `Today matters`, empty sections and secondary operational detail use
similar visual weight. A user cannot answer “what changed?” or “what pays me
next?” with one glance.

Improve with an explicit at-a-glance band, typographic KPI hierarchy, signed
direction cues, and a responsive two-column desktop composition. Native
currencies must remain separate and unavailable totals must stay unavailable.

### 3. High — wide layouts do not earn their space

At 1280 px, Today is one very wide column and produces long reading lines.
Portfolio cards wrap but leave a large unused region, and Research stretches a
two-line row across the whole window. The vision explicitly expects desktop to
use extra width for multi-column dashboards and expanded information.

Improve with a centred content canvas, bounded reading width and adaptive grids
that collapse cleanly to the existing phone layout.

### 4. Medium — Research hides the assessment

The Research landing page shows only instrument identity and sector. It gives
no indication whether an assessment exists, how much evidence supports it, or
what kind of score the detail view contains. Every row therefore has the same
priority and experienced users cannot compare their followed companies.

Improve with honest score previews, available-dimension counts and a permanent
“research context, not a recommendation” explanation. Missing evidence should
be a labelled state, never a zero score.

### 5. Medium — Calendar controls compete with the calendar

Period navigation, forecast, view mode, date mode, scope, currency, weekend
filter, explanation and export all appear before the grid. Each control is
valid, but their equal prominence makes the screen feel like a configuration
form. On phones this also delays the first dividend event.

Improve by separating primary navigation from secondary filters, using a clear
filter summary and preserving every control's labelled touch target.

### 6. Medium — finance typography is not specialised

Amounts use the default proportional figures. Columns and adjacent cards can
visually shift as values change, which slows comparison. Section headings also
have little contrast from card titles.

Improve money and percentage rendering with tabular figures, strengthen only
the hierarchy-relevant weights, and retain the current accessible type scaling.

### 7. Low — visual identity is largely absent after the launcher

The onboarding screen and application chrome could belong to any Material app.
The dachshund identity need not become decorative financial gamification, but a
restrained mark and consistent brand title would improve recognition and
finish.

## Delivery plan

The work is split so every step is independently testable and reversible.

1. **Activation and identity.** Add an actionable first-holding prompt to empty
   Today, refine onboarding hierarchy and retain the honest empty state.
2. **Today dashboard.** Introduce KPI hierarchy, tabular financial figures and
   a bounded two-column desktop layout while preserving one column on Android.
3. **Research overview.** Add assessment/evidence previews and an adaptive card
   grid without turning scores into recommendations.
4. **Calendar hierarchy.** Separate period/view controls from secondary filters
   and make the schedule the dominant surface.
5. **Final UX gate.** Exercise phone, large text, keyboard, dark theme, empty,
   partial-data and mixed-currency states; self-review every changed surface.

## Success criteria

- A first-time user can reach the add-instrument flow from empty Today with one
  obvious decision.
- The first desktop viewport exposes portfolio context, highest-ranked events
  and near-term income without excessively long reading lines.
- No cross-currency total is introduced and no missing research dimension is
  scored as zero.
- All new controls meet labelled and Android tap-target guidance.
- Phone layouts remain one-column and do not overflow at the repository's
  largest tested text scale.
- English, German and Croatian receive every new user-visible string.
- `localPipeline.sh --noRun` remains green after each atomic commit.

## Final verification — 2026-09-15

All seven findings above are resolved in the delivered UI pass:

- Onboarding now carries the product identity, and empty Today opens the real
  add-instrument flow with one primary action.
- Today leads with holdings, near-term events and separate native-currency
  values. It uses a bounded two-column desktop dashboard and one ordered phone
  column; financial figures use tabular numerals.
- Research previews a real score only when evidence supports it, names the
  available dimensions and labels missing evidence. Cards form a lazy adaptive
  grid so a large imported instrument set does not compute every assessment at
  once.
- Calendar gives period and view navigation first priority. Secondary date,
  scope, FX, weekend and export controls collapse to a readable summary on a
  phone and remain directly available on desktop.

The verification matrix is automated rather than dependent on screenshots:

| Risk | Evidence |
| --- | --- |
| First run and empty state | onboarding widget tests and compiled `/portfolio/add` journey |
| Phone and 200% text | onboarding, Research, Calendar and all-destination widget tests at 412 px |
| Wide desktop | Today two-column and Research multi-column position assertions |
| Keyboard | Linux `Alt+number` destination-navigation regression |
| Dark theme | live theme switch followed by Today, Calendar and Research rendering |
| Offline/error states | Today cached-without-quotes and Research unavailable-evidence regressions |
| Financial honesty | mixed EUR/USD KPI test, gross/net tests and missing-score-is-not-zero test |
| Touch targets | labelled and Android tap-target guidelines plus the 48 px phone filter assertion |
| Localization | mechanical English/German/Croatian catalog coverage |

The final risk review found one medium scalability issue in the first Research
grid implementation: a `Wrap` eagerly started an assessment for every known
instrument. It was replaced with lazy slivers, and a 100-instrument regression
proves off-screen assessments remain idle. No high- or medium-priority UX,
correctness or architecture finding remains open in this scope.

Verdict: the interface is substantially easier to scan and activate while
remaining calm, offline-capable and financially honest. The full rendered
Linux and Android release gate is the final automated evidence for this
version.
