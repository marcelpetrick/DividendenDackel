# Data-provider policy and licensing review

Every adapter must have an entry here before it is merged. This is an
engineering record, not legal advice. Terms can change; release readiness must
recheck the linked primary sources and update the review date.

Version 0.1.0 ships only the SEC EDGAR and Frankfurter/ECB adapters below.
Settings reserve secure credential slots for Financial Modeling Prep, Finnhub
and Alpha Vantage, but those entries are configuration boundaries rather than
working adapters; they make no network request until an adapter, contract test
and licensing review are implemented.

## SEC EDGAR

| Question | Review |
| --- | --- |
| Provider | U.S. Securities and Exchange Commission, EDGAR public data APIs |
| Endpoints used | `www.sec.gov/files/company_tickers.json`, `data.sec.gov/api/xbrl/companyfacts/CIK##########.json`, `data.sec.gov/submissions/CIK##########.json` |
| Free usage allowed? | Yes. The APIs require no authentication or API key, and public EDGAR material is free to access. |
| Client-side usage allowed? | Yes, subject to the SEC's automated-access policy. Requests declare the application and the repository author's public contact address in `User-Agent`, matching the SEC's documented bot-header format. |
| Caching allowed? | The SEC encourages efficient access and offers nightly bulk archives. DividendenDackel caches only the records needed for followed instruments. |
| Redistribution allowed? | Government-created SEC content and public EDGAR filing content are stated to be free to access and reuse. The app stores normalized facts and links to the original filing; it does not redistribute bulk archives. |
| Attribution required? | No specific attribution requirement was found. The UI still identifies SEC EDGAR as the source and links filings to SEC.gov for provenance. |
| Rate limit | No more than 10 requests per second in total. The coordinator allows one SEC operation at a time and at least 220 ms between starts. An unmapped instrument may require two sequential HTTP requests, keeping the worst-case path below the ceiling. |
| Retention limit | None stated in the reviewed sources. Normal cache expiry remains configurable. |
| Commercial restrictions | None stated for the public API/content reviewed. |
| API-key restrictions | No key is required. |
| Reviewed | 2026-08-22 |

Primary sources:

- [EDGAR data API documentation](https://www.sec.gov/search-filings/edgar-application-programming-interfaces)
- [SEC developer resources and Fair Access limit](https://www.sec.gov/about/developer-resources)
- [SEC webmaster FAQ: reuse, declared user agents and ticker mapping](https://www.sec.gov/about/webmaster-frequently-asked-questions)
- [Official company ticker file](https://www.sec.gov/files/company_tickers.json)

### Normalization limits

`CommonStockDividendsPerShareDeclared` is a filing fact for a reporting
period. Its period boundary is not an ex-date, declaration date or payment
date. The adapter therefore stores the reported period separately and leaves
those event dates unknown. Downstream history analytics may group by the
reported period; calendars must never present that boundary as a payment or
entitlement date. When an annual fact and discrete quarterly facts overlap, the
adapter keeps the annual total to prevent downstream calculations from counting
the same dividend twice; quarters remain available until an annual filing is
published.

The ticker file maps ticker, CIK and EDGAR-conformed company name. It does not
contain ISINs or exchange-qualified identities and the SEC warns that its
associations are not guaranteed complete. Instruments found through SEC search
retain an explicit SEC provider mapping. Existing instruments resolve through
that mapping first, then an exact ticker match; no CIK is guessed from an ISIN.

The submissions endpoint contains recent filings inline and may point to older
history fragments. The initial adapter exposes the inline set (at least one
year or 1,000 filings according to SEC documentation) and reports no data for
older ranges instead of pretending the history is exhaustive.

## Alpha Vantage (optional, user-supplied key)

| Question | Review |
| --- | --- |
| Provider | Alpha Vantage, used only when the user supplies their own credential |
| Endpoint used | `www.alphavantage.co/query?function=GLOBAL_QUOTE`, one symbol per call |
| Free usage allowed? | Yes, with a free key the user claims themselves. No credential is bundled (Vision.md §34, §80). |
| Client-side usage allowed? | Yes. The key is read from Android Keystore / Linux Secret Service for each request and never enters widget state, a log line or an error message. |
| Caching allowed? | Yes, and necessary here. The free tier returns end-of-day prices, so a quote stays valid until the next close. |
| Redistribution allowed? | Not attempted. Quotes are stored locally for the user's own portfolio only. |
| Attribution required? | Provenance shows `alpha_vantage` as the source, as for every other adapter. |
| Rate limit | **25 requests per day** on the free tier. The coordinator carries this as `dailyRequestBudget`, so the twenty-sixth request of a day fails with a typed `RateLimitFailure` naming when it resets rather than being sent and wasted. |
| Retention limit | None stated for the user's own cached values. |
| Commercial restrictions | Premium tiers exist for higher volume; the app never assumes one. |
| API-key restrictions | Required. The source stays disabled until the user adds a key. |
| Data warning | The free tier is **end-of-day, not real-time**. A quote is a closing price and is dated by its trading day rather than by download time, so the app never presents yesterday's close as the current market price. |
| Reviewed | 2026-08-28 |

Primary sources:

- [Alpha Vantage API documentation](https://www.alphavantage.co/documentation/)
- [Alpha Vantage premium plans, which state the free limit](https://www.alphavantage.co/premium/)

Why this provider. No keyless source prices German listings: Stooq's CSV
endpoint now serves a JavaScript bot challenge, Yahoo's quote endpoints are
unofficial and against its terms, and the free tiers of Twelve Data, Finnhub and
Financial Modeling Prep cover US equities only — Twelve Data places EU market
data on Pro and above. Alpha Vantage is the one free tier that answers for
Xetra, through a `.DEX` suffix, so `ALV.DEX` is Allianz on Xetra.

Alpha Vantage publishes a `demo` API key. It answers for a handful of US
symbols such as IBM and refuses the rest, which is enough to exercise the quote
path end to end without an account and not enough to price a real portfolio.
The fixtures in the tests are captured from live `demo` responses, so the field
names are the provider's own rather than a reading of its documentation. Its
refusal is mapped to an authentication failure rather than an outage: asking
the user for a key is something they can act on, while an outage invites them
to wait for a recovery that will not come.

Alpha Vantage answers **200 OK for errors**. An exhausted quota, an unknown
symbol and a rejected key all arrive as a successful response carrying an
advisory string, so the body decides the failure and not the status code. `Note`
is the throttling message whatever wording it carries; `Information` may be
either a quota notice or a genuine advisory, so there the wording decides. A
missing price, a zero price and a negative price are all refused rather than
shown, because a confident wrong number is the defect this app exists to avoid.

## Finnhub (optional, user-supplied key)

| Question | Review |
| --- | --- |
| Provider | Finnhub, used only when the user supplies their own credential |
| Endpoint used | `finnhub.io/api/v1/quote`, one symbol per call |
| Free usage allowed? | Yes, with a free key the user claims themselves. No credential is bundled (Vision.md §34, §80). |
| Client-side usage allowed? | Yes. The key is read from secure storage per request and never enters widget state or a log line. |
| Caching allowed? | Not addressed by the terms. The app stores quotes locally for the user's own portfolio only, which is the personal use the plan is for. |
| Redistribution allowed? | **No.** "You agree to not redistribute or share access to data or derived results from the data obtained from Finnhub with anyone or any 3rd party without written approval." The app forwards nothing; a quote reaches only the device that requested it. |
| Attribution required? | Not stated. Provenance records `finnhub` as the source, as for every adapter. |
| Rate limit | Paced rather than capped daily, so the coordinator spaces requests at about one per second and carries no daily budget. |
| Retention limit | None stated for the user's own cached values. |
| Commercial restrictions | **The personal plan is for personal use.** "Personal plan can't be used by any business even internally without a written approval," and it is "strictly for personal use unless explicitly stated otherwise". The app states this where the key is asked for, because a user tracking a company portfolio would otherwise breach it unknowingly. |
| API-key restrictions | Required. The source stays disabled until the user adds a key. |
| Data warning | The free tier covers US equities. A non-US listing is refused rather than sent unsuffixed, which would resolve a US company of the same ticker. An unknown symbol returns HTTP 200 with every field zero, so a zero price is treated as no data rather than as a company worth nothing. |
| Reviewed | 2026-08-28 |

Primary sources:

- [Finnhub terms of service](https://finnhub.io/terms-of-service)
- [Finnhub API documentation](https://finnhub.io/docs/api/quote)

Finnhub is ordered ahead of Alpha Vantage for the listings it covers. Its free
tier is paced per second while Alpha Vantage's is 25 requests for an entire
day, so spending the scarcer allowance only where nothing else can serve leaves
it for the German listings that depend on it.

The response contract here was taken from Finnhub's published documentation
rather than captured from a live call, because the endpoint requires a
credential this project does not hold. The adapter is written so that a shape
it does not recognise produces a parsing or no-data failure rather than a
number: an unexpected contract costs the user a missing price, never a wrong
one.

## Financial Modeling Prep

**Not implemented.** The licensing review could not be completed: the pricing
and terms pages return HTTP 403 to any automated request, so the free tier's
limits, coverage and commercial conditions could not be established. This
document requires that review before an adapter merges, so no adapter exists.
It can be added once someone can read and record those terms.

## OpenFIGI

| Question | Review |
| --- | --- |
| Provider | OpenFIGI, operated by Bloomberg, for the Financial Instrument Global Identifier (FIGI) standard |
| Endpoint used | `api.openfigi.com/v3/mapping` for an ISIN, `api.openfigi.com/v3/search` for a name, restricted to the German venue codes `GY`, `GR` and `GF` |
| Free usage allowed? | Yes. OpenFIGI states the API is "free to use without daily, weekly or monthly limitations". |
| Client-side usage allowed? | Yes. No credential is required for the quota this app uses. |
| Caching allowed? | Yes. The terms allow identifiers to be "freely reproduced, distributed, transmitted, used, modified, built upon, or otherwise exploited by anyone for any purpose". The app stores matched instruments locally so search keeps working offline. |
| Redistribution allowed? | Yes, explicitly, including to a user's own customers. |
| Attribution required? | No. Bloomberg dedicates the FIGI identifiers to the public domain. |
| Rate limit | 25 requests per 60 seconds without a key, reported in-band as `ratelimit-policy: 25;w=60`. The coordinator is configured from that number at one request every 2.4 s. A `429` carries `ratelimit-reset`, which the adapter converts into a typed `RateLimitFailure`. |
| Retention limit | None stated. |
| Commercial restrictions | None. Use is dedicated to the public domain. |
| API-key restrictions | A key raises the quota but is not required, so none is bundled (Vision.md §34, §80). |
| Data warning | Identity only. OpenFIGI returns no prices, and the adapter declares only `instrumentSearch`, asserted by a test. Bloomberg provides the data "as is" with no accuracy warranty and caps liability at USD 50, so a match is treated as a candidate for the user to confirm, never as a fact about a holding. |
| Reviewed | 2026-08-28 |

Primary sources:

- [OpenFIGI API overview](https://www.openfigi.com/api)
- [OpenFIGI terms of service](https://www.openfigi.com/docs/terms-of-service)

The rate limit and the response shapes in `test/fixtures/openfigi/` were taken
from live responses rather than from documentation alone, because the published
overview does not state the unauthenticated per-minute quota; the API reports it
in `ratelimit-policy`.

One ISIN maps to well over a hundred rows — Allianz returns 135 — because every
venue and share class is its own record. The adapter keeps equities on German
venues only, collapses them to one entry per ticker preferring Xetra, and leaves
US listings to SEC EDGAR so the two adapters complement rather than duplicate
each other.

OpenFIGI does not report a trading currency. The adapter admits only German
venues, which quote in EUR, so the currency is asserted from the venue rather
than guessed. Extending it to another venue must revisit that.

## Frankfurter / ECB

| Question | Review |
| --- | --- |
| Provider | Frankfurter v2 public API, explicitly filtered to European Central Bank (`providers=ECB`) reference rates |
| Endpoint used | `api.frankfurter.dev/v2/rates` with bounded date, base, quote and provider parameters |
| Free usage allowed? | Yes. Frankfurter states that the public API is free for commercial use; underlying ECB data may be used freely under the ECB conditions below. |
| Client-side usage allowed? | Yes. The public API requires no API key and enables cross-origin requests. |
| Caching allowed? | Frankfurter recommends caching for higher-volume use. The app stores daily rows locally and refreshes them on a 12-hour policy. |
| Redistribution allowed? | ECB information may be distributed or reproduced accurately when the ECB is cited as source. Modified calculations must be labelled as modified. |
| Attribution required? | Yes for the underlying data. User-facing FX provenance says “Frankfurter · source: ECB”; derived conversions remain labelled as calculations. |
| Rate limit | No published quota or monthly/daily cap. Frankfurter says abuse prevention rate limits apply. The app uses the shared bounded coordinator and requests only required pairs/dates. |
| Retention limit | None stated in the reviewed Frankfurter or ECB sources. |
| Commercial restrictions | Frankfurter says commercial use is allowed. If ECB information is included in something sold, buyers must be told that the information is available free from the ECB website. |
| API-key restrictions | No key is required. |
| Data warning | Daily reference rates are informational, normally published around 16:00 CET on working days, and are not transaction rates. The ECB strongly discourages transaction use. |
| Reviewed | 2026-08-22 |

Primary sources:

- [Frankfurter v2 documentation and FAQ](https://frankfurter.dev/)
- [Frankfurter v2 OpenAPI contract](https://api.frankfurter.dev/v2/openapi.json)
- [Frankfurter MIT software license](https://github.com/lineofflight/frankfurter/blob/main/LICENSE)
- [ECB reference-rate description](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html)
- [ECB disclaimer and reuse conditions](https://www.ecb.europa.eu/services/using-our-site/disclaimer/html/index.en.html)

The v2 API blends multiple institutions by default. DividendenDackel always
sends `providers=ECB`; silently switching to the blend would change both the
meaning and licensing provenance of persisted rates. Range endpoints are
inclusive, while the app's `DateRange` is half-open, so the adapter requests
the calendar day immediately before `range.end` as its final date.
