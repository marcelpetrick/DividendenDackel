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
