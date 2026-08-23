# Privacy

This document describes DividendenDackel 0.1.0. The app is local-first and has
no DividendenDackel account, hosted backend, advertising SDK, analytics SDK or
crash-reporting service.

## Data stored on the device

The app stores the following in its platform application-data directory:

- portfolio names, holdings, watchlist entries, immutable activities and user
  preferences;
- cached instruments, quotes, dividends, events, headlines, filings, research
  snapshots and daily FX rates;
- cache metadata, provider health and privacy-safe synchronization logs;
- notification mode and stable identifiers of events already delivered;
- per-portfolio display-currency choices, tax-profile inputs and withholding
  assumptions.

CSV files selected for portfolio import are read locally for a review preview.
The source file and filename are not copied into the database or sent over the
network. Only validated activities, a stable duplicate-detection identity and
an import-batch identifier are retained. Undo appends local reversal records.
Interactive Brokers account ids or aliases are used only to hash a
collision-safe duplicate identity; the raw account value is not retained.

Calendar export creates an `.ics` snapshot only after the user selects Export
and a destination. The file contains the currently filtered instrument names,
symbols, per-share dividend amounts, dates, certainty and source labels. It
does not contain portfolio quantities, purchase prices, tax settings or account
credentials. Android grants the app temporary access only to the document the
user chose; Linux writes only to the selected path. The app does not upload,
host or subscribe the calendar and does not retain the export destination.

Optional third-party API keys are stored separately through Android secure
storage backed by the Keystore or Linux Secret Service. The application never
includes a shared provider credential in its source code or artifacts. Android
backup is disabled so device-bound encrypted values are not restored without
their key.

There is currently no in-app cloud synchronization. Uninstalling the Android
app removes its application data under normal Android behavior. Linux users can
remove the application data through their desktop/user-data management tools;
the exact directory is selected by the platform application-data API.

## Network requests

Live refresh uses HTTPS and contacts only enabled data sources:

| Destination | Data sent | Purpose |
| --- | --- | --- |
| `sec.gov` / `data.sec.gov` | public ticker or CIK lookup, declared application/contact user agent, normal network metadata such as IP address | US instruments, company facts and filing metadata |
| `api.frankfurter.dev` | currency pair, bounded dates, `providers=ECB`, normal network metadata | ECB daily reference rates |

Portfolio names, quantities, purchase prices, activities, tax profiles and
calculated scores are not sent to these keyless providers. A ticker or CIK can reveal which company
the user requested. Those services process requests under their own privacy and
access policies; links are recorded in [`data-providers.md`](data-providers.md).

Settings contain reserved entries for optional keyed sources, but version 0.1.0
does not ship those adapters and therefore sends them no data.

## External links

Opening a filing or publisher link hands the validated HTTPS URL to the system
browser. From that point the destination site and browser apply their own
privacy, cookie and telemetry policies. DividendenDackel does not fetch or
republish article bodies.

## Notifications and permissions

Notifications are disabled by default and require explicit opt-in. Android asks
for the notification permission; Linux uses the desktop notification service.
Due-event selection and delivered-event tracking happen locally. Notification
text contains the followed company and factual event details, which can be
visible on the device lock screen according to operating-system settings.

Android declares only internet and notification permissions. It does not ask
for contacts, location, camera, microphone, files or phone state.

## Logging

Structured logs contain component, provider, operation, duration and a safe
error category. They deliberately exclude portfolio contents, API-key values
and raw provider payloads. No log is uploaded by the app. A user who manually
shares diagnostics should still review them first.

## Scope and changes

Tax and research calculations run on the device. They are estimates, not tax or
investment advice. If a future version adds sync, analytics, crash reporting or
a new provider, this document and the relevant provider review must change
before release.

Privacy questions can be sent to the maintainer address in the repository
README.
