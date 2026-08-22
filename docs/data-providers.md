# Data-provider policy and licensing review

Every adapter must have an entry here before it is merged. This is an
engineering record, not legal advice. Terms can change; release readiness must
recheck the linked primary sources and update the review date.

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

Licensing and endpoint behavior will be reviewed immediately before the F8b
adapter is implemented.
