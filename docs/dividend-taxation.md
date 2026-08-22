# Dividend taxation: gross and net

> **This is an estimate, not tax advice, and not a tax return.** Vision.md §50
> excludes tax filing from the product. The purpose here is to answer "roughly
> what actually lands in my account?" — a question a gross dividend figure
> cannot answer — while being explicit about every assumption made to get
> there.

## 1. Why gross alone is misleading

A €13.80 gross dividend from a German company and a $1.00 gross dividend from a
US company are taxed differently before either reaches the investor. Showing
only gross overstates income, and the error is not uniform across a portfolio:
it depends on where each company is domiciled. A dividend tracker that ignores
this reports a number the user will never receive.

So every dividend figure gets two forms:

```text
Brutto   €276.00
Netto    €203.20   (estimated)
```

with the deduction chain available on expansion (Vision.md §2.3).

## 2. The chain for an investor taxed in Germany

```text
gross dividend
  │
  ├─ (a) foreign withholding tax, deducted in the source country
  │        at the statutory rate, or the treaty rate if the investor
  │        has filed the right forms
  │
  ├─ (b) German taxation on the gross amount:
  │        Kapitalertragsteuer  25 %
  │        + Solidaritätszuschlag  5.5 % of the KESt
  │        + Kirchensteuer  8 % or 9 % of the KESt, if applicable
  │        less the Sparerpauschbetrag allowance
  │        less the creditable part of (a)
  │
  └─ = net dividend
```

### 2.1 Foreign withholding tax and the treaty cap

Germany's double-taxation treaties (Doppelbesteuerungsabkommen) generally cap
the source country's claim on portfolio dividends at **15 %**. That gives three
distinct quantities, which the UI must not conflate:

| Quantity | Meaning |
| --- | --- |
| **Withheld** | What the source country actually deducted |
| **Creditable** | The part offset against German tax — at most 15 % of gross |
| **Reclaimable** | Withheld − treaty cap; recoverable only by applying to the source country |

Switzerland is the clearest example: 35 % is withheld, 15 % is creditable
against German tax, and the remaining 20 % is reclaimable — but only if the
investor files for it. Money the user has to actively reclaim is *not* the same
as money already credited, and the app must show it as a separate, clearly
labelled line rather than silently assuming it comes back.

Where withholding exceeds 15 % and is not reclaimed, the practical outcome is
that the extra is simply lost.

### 2.2 German tax

Without church tax:

```text
KESt  = 0.25 × base
Soli  = 0.055 × KESt
total = 26.375 % of base
```

With church tax at rate `k` (0.08 in Bavaria and Baden-Württemberg, 0.09
elsewhere), church tax is deductible. For taxable income `e` after allowance
and creditable foreign tax `q`, §32d EStG gives:

```text
KESt  = (e − 4q) / (4 + k)
Soli  = 0.055 × KESt
KiSt  = k × KESt
total = 27.82 % (k = 0.08) or 27.99 % (k = 0.09)
```

The creditable foreign withholding tax is offset against the KESt, and the
surcharges are computed on the reduced KESt.

### 2.3 The Sparerpauschbetrag

**€1,000** per person, **€2,000** for a jointly assessed couple. It applies to
all investment income for the year, not per dividend, so the app has to track
consumption across the year and apply it in payment order. Until it is used up,
German tax on a dividend is zero — which is exactly the case where a naive
"gross × 0.73646" estimate is most wrong.

### 2.4 German domestic dividends

For a German company held at a German broker there is no foreign withholding
step: the bank withholds KESt, Soli and any church tax directly.

## 3. Proposed implementation

### 3.1 Tax profile (user settings, never inferred silently)

```text
country of tax residence     default DE
church tax rate              none | 8 % | 9 %
assessment                   single | joint
Sparerpauschbetrag           1000 / 2000, editable
allowance already used       editable, so mid-year setup is honest
treaty forms filed           per source country, default yes
```

Defaults must be visible and changeable. A user in Austria or Switzerland gets
a clearly stated "not modelled for your residence" rather than German numbers
presented as theirs.

### 3.2 Withholding table

A versioned data file, `assets/tax/withholding_rates.json`, keyed by ISO country
code:

```json
{
  "asOf": "2026-01-01",
  "source": "Bundeszentralamt für Steuern, anrechenbare ausländische Quellensteuer",
  "rates": {
    "US": {"statutory": "30", "treatyWithForms": "15", "creditableCap": "15"},
    "CH": {"statutory": "35", "treatyWithForms": "35", "creditableCap": "15"},
    "GB": {"statutory": "0",  "treatyWithForms": "0",  "creditableCap": "0"},
    "NL": {"statutory": "15", "treatyWithForms": "15", "creditableCap": "15"}
  }
}
```

Each rate is editable per country and per instrument, because brokers differ and
treaty status depends on paperwork the app cannot see. The file carries an
`asOf` date and its source, and the UI shows both — a stale tax table that looks
authoritative is worse than one that admits its age.

### 3.3 Calculation output

The engine returns a breakdown, never a bare number:

```text
DividendTaxBreakdown
  gross
  withheldAtSource        + the rate and country used
  creditableWithholding
  reclaimableWithholding  + "recoverable only on application to <country>"
  allowanceApplied
  kapitalertragsteuer
  solidaritaetszuschlag
  kirchensteuer
  net
  assumptions[]           human-readable, e.g. "treaty forms assumed filed"
  confidence
```

Every line is explainable, which is the same rule scores follow (Vision.md §15,
§85). Aggregations — monthly forecast, annual income, portfolio yield — carry
gross and net side by side and never mix the two into one figure.

## 4. Limits, stated plainly

- Models an investor taxed in **Germany**. Other residences are out of scope
  until modelled, and are labelled as such rather than approximated.
- Ignores **Teilfreistellung** for funds and ETFs, **Vorabpauschale**, loss
  pots (Verlustverrechnungstöpfe) and the Günstigerprüfung. Applies to
  individual shares first.
- Assumes the broker applies the Sparerpauschbetrag via a Freistellungsauftrag;
  reality depends on how the user distributed it across banks.
- Treaty status depends on forms filed with the broker or source country, which
  the app cannot verify — hence the per-country toggle.
- Rates change. The table is versioned and dated, and every net figure is
  labelled an estimate.

## 5. Sources

- [Bundeszentralamt für Steuern — anrechenbare ausländische Quellensteuer, Stand 01.01.2024](https://www.bzst.de/SharedDocs/Downloads/DE/EU_OECD/anrechenbare_ausl_quellensteuer_2024.pdf)
- [§ 32d EStG — 25% tariff, foreign-tax credit and church-tax formula](https://www.gesetze-im-internet.de/estg/__32d.html)
- [BMF Datensammlung zur Steuerpolitik 2026 — €1,000/€2,000 Sparer-Pauschbetrag](https://www.bundesfinanzministerium.de/Content/DE/Downloads/Broschueren_Bestellservice/datensammlung-zur-steuerpolitik-2026.pdf)
- [Finanztip — Quellensteuer auf Dividenden](https://www.finanztip.de/indexfonds-etf/quellensteuer/)
- [Finanztip — Abgeltungsteuer](https://www.finanztip.de/abgeltungsteuer/)
- [Raisin — Quellensteuer: Höhe, Anrechnung und Rückerstattung](https://www.raisin.com/de-de/steuer/quellensteuer/)
- [Raisin — Abgeltungsteuer](https://www.raisin.com/de-de/steuer/abgeltungsteuer/)

Verify the table against the BZSt publication before every release; that check
belongs in the release checklist alongside the provider licensing review.
