# Protective-device catalogue — source register

This register records official manufacturer documentation discovered for the
ElectroDesign protective-device catalogue. It is a source inventory, not a
populated electrical database. No entry below is automatically approved as
input to a calculation.

## Verification policy

Before a product record can be used by a calculation, verify the exact
manufacturer reference, pole configuration, rated voltage, applicable product
standard, rating definition (for example Icn versus Icu), settings, and
document revision. Time/current curves, I²t, I2 and selectivity data must be
transcribed from the exact relevant document and operating conditions.

A generic family page or catalogue overview is not sufficient evidence for
device-specific protection calculations. Do not infer missing values from a
product family, a similar model, a marketplace title, or another voltage.

## Sources located

| Manufacturer | Product / document | Official source | What the source supports | Status |
|---|---|---|---|---|
| Schneider Electric | Acti9 iC60N A9F75201 | https://www.se.com/fr/fr/product/A9F75201/acti9-ic60n-disjoncteur-2p-1a-courbe-d-400vca-6000a-50ka/ | Official product identity page; page title identifies 2P, 1 A, D curve and 400 V AC. The 6000 A / 50 kA wording needs exact standard/rating interpretation from the technical datasheet before use. | Candidate; not calculation-approved |
| ABB | S200 M UC, catalogue no. 2CDS272061R0024 (S202MUC-C2) | https://empower.abb.com/ecatalog/ec/EN_NA/p/2CDS272061R0024 | Official product page lists 2 A, 2 poles, C curve, standards and voltage-dependent breaking ratings. Confirm the exact ratings and document revision against the linked ABB technical publication before calculation use. | Candidate; not calculation-approved |
| Siemens | 5SY / 5SP miniature circuit breakers, configuration manual L1V30914799-04, 03/2025 | https://cache.industry.siemens.com/dl/files/792/45302792/att_1328163/v1/MAN_L1V30914799-04_en_en-US.pdf | Official manual with family-level technical information. A precise article number and matching table/curve are still required for individual catalogue records. | Family source; not product record |
| SOMEF | Official catalogue library | https://www.somef.tn/fr/content/6-catalogue | Official catalogue portal, including product universes and a coffrets/disjoncteurs brochure listing. A detailed breaker datasheet/article reference has not yet been confirmed. | Manufacturer source located; breaker data pending |

## Still to source

- Legrand: official product page and technical document for an exact protective-device reference.
- Hager: official product page and technical document for an exact protective-device reference.
- SOMEF: exact breaker article reference plus official electrical ratings and technical documentation.
- For every brand: manufacturer time/current curves, total clearing curves, let-through energy (I²t), conventional operating current (I2), and pairwise selectivity tables where published.

## Next ingestion step

Create product records only after opening the exact official document, recording
its revision/publication date, retrieval date, language, and page/table
references. Keep unsupported fields null. Do not create synthetic manufacturer
ratings. Synthetic curves may appear only in unit tests.
