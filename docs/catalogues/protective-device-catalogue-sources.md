# Protective-device catalogue — source register

This register records official manufacturer documentation discovered for the
ElectroDesign protective-device catalogue. It distinguishes source discovery
from product data that has been transcribed and reviewed. A transcribed record
is not, by itself, approval for a protection calculation.

## Verification policy

Before a product record can be used by a calculation, verify the exact
manufacturer reference, pole configuration, rated voltage, applicable product
standard, rating definition (for example Icn versus Icu), settings, and
document revision. Time/current curves, I²t, I2 and selectivity data must be
transcribed from the exact relevant document and operating conditions.

A generic family page or catalogue overview is not sufficient evidence for
device-specific protection calculations. Do not infer missing values from a
product family, a similar model, a marketplace title, or another voltage.

## Product data transcribed

### ABB — S202MUC-C2

- Catalogue/order reference: `2CDS272061R0024`
- Family/type: S 200 M UC / S202M-C2UC
- Category: miniature circuit breaker (MCB)
- Poles: 2
- Rated current: 2 A
- Tripping characteristic: C
- IEC rated short-circuit capacity: Icn 10 kA at 400 V AC (IEC/EN 60898-2)
- Additional family technical data: Uimp 4 kV; rated insulation voltage Ui is
  stated as 253 V AC phase-to-ground / 440 V AC phase-to-phase.
- Standards listed: IEC/EN 60898-2, IEC/EN 60947-2, UL 1077, CSA 22.2 No. 235.
- Official technical document: [ABB System pro M compact — S 200 M UC,
  1SXU400144L0201](https://library.e.abb.com/public/aeeea37834b7488ebd6796ebe35044d7/1SXU400144L0201_SystemProMCompactMCBS200MUC0915.pdf)
- Product-specific ordering evidence: page 9, row for S202M-C2UC /
  2CDS272061R0024.
- Family technical ratings: page 1 (technical data).
- Retrieved: 2026-11-11; document identifier/revision shown: 1SXU400144L0201.
- Limitations: no product-specific time/current curve points, I2, I²t, or
  pairwise selectivity limit transcribed. Do not use this record for those
  calculations until exact applicable data is added.

The machine-readable transcription is stored in
`docs/catalogues/data/abb-s202muc-c2.json`. It is a reviewed documentation
record, not yet wired into the Flutter application's runtime catalogue.

## Sources located; product data pending

| Manufacturer | Product / document | Official source | What the source supports | Status |
|---|---|---|---|---|
| Schneider Electric | Acti9 iC60N A9F75201 | https://www.se.com/ch/fr/product/A9F75201/disjoncteur-acti9-ic60n-2p-1-a-courbe-d-6000-a-iec-608981-50-ka-iec-609472/ | Official product page identifies 2P, 1 A, D curve and distinguishes 6 kA under IEC 60898-1 from 50 kA under IEC 60947-2. Exact datasheet conditions and technical curves still need transcription. | Candidate; not calculation-approved |
| Siemens | 5SY / 5SP miniature circuit breakers, configuration manual L1V30914799-04, 03/2025 | https://cache.industry.siemens.com/dl/files/792/45302792/att_1328163/v1/MAN_L1V30914799-04_en_en-US.pdf | Official manual with family-level technical information. A precise article number and matching table/curve are still required for individual catalogue records. | Family source; not product record |
| SOMEF | Official product category and catalogue library | https://www.somef.tn/fr/222-coffret-et-disjoncteur | Official category identifies SOMEF as a manufacturer and shows modular DIN-rail and enclosure product groups. The available brochure located so far documents enclosures, not exact breaker electrical ratings. | Manufacturer source located; breaker data pending |

## Still to source

- Legrand: official product page and technical document for an exact protective-device reference.
- Hager: official product page and technical document for an exact protective-device reference.
- SOMEF: exact breaker article reference plus official electrical ratings and technical documentation.
- Schneider: exact datasheet for A9F75201, including the relevant voltage/rating tables,
  time/current curves and let-through data.
- For every brand: manufacturer time/current curves, total clearing curves,
  let-through energy (I²t), conventional operating current (I2), and pairwise
  selectivity tables where published.

## Next ingestion step

Create product records only after opening the exact official document, recording
its revision/publication date, retrieval date, language, and page/table
references. Keep unsupported fields null. Do not create synthetic manufacturer
ratings. Synthetic curves may appear only in unit tests.
