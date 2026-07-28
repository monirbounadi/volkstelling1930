# Data notes

## Unit of observation

Each row of `data/administrative_units.csv` is a lowest-level administrative
unit (`adm3`) in the 1930 census reconstruction. The file has 691 units:

- 431 in Java and Madura;
- 119 in Sumatra; and
- 141 in Borneo, Celebes, the Lesser Sunda Islands, and the Moluccas.

These are the units for which a census population record was matched to the
historical administrative geography. They are not modern Indonesian
administrative units.

## Geographic hierarchy

`adm0`–`adm3` standardize the historical hierarchy across regions, whose
colonial administrative terms differed. The original source fields (`islands`,
`province`, `residency`, `government`, `regency`, `division`, `district`, and
`subdivision`) are retained for auditability.

| Field | Historical level | Typical source term |
|---|---|---|
| `adm0` | Broad census region | Island or island group |
| `adm1` | First level | Province, residency, or government |
| `adm2` | Second level | Regency or division |
| `adm3` | Lowest level | District or subdivision |

For example, Java and Madura records commonly follow province–regency–district
hierarchies. In other regions, the equivalent levels may be recorded as
residency or government, division, and subdivision. These are historical
administrative designations, not a uniform modern Indonesian hierarchy.

| Census region | First level | Second level | Lowest level |
|---|---|---|---|
| Java and Madura | `province` | `regency` | `district` |
| Sumatra | `residency` or `government` | `division` | `subdivision` |
| Borneo, Celebes, Lesser Sunda Islands, and Moluccas | `residency` or `government` | `division` | `subdivision` |

## Population categories

`nativemen`, `nativewomen`, and `nativetotal` reproduce the source census's
historical population category. The labels `European`, `Chinese`, and `Other`
are likewise retained in the field names (`eur*`, `chinese*`, and `other*`) to
make the transcription auditable. They describe colonial administrative
classifications, not present-day identities or analytically neutral groups.

The `total` fields are the corresponding all-category totals. A small number
of source-cell corrections and historical-name normalizations were made in the
original construction workflow.

## Source totals and estimates

`total` preserves the all-category total printed in the census table. The
source is not arithmetically additive in three rows, and the release preserves
those source values rather than imputing a correction.

- For Hollandia and Zuid-Nieuw-Guinee, the census footnote states that Native
  totals include persons in areas for which only a rough estimate was possible.
  Their Native and all-category totals therefore need not equal the sums of the
  reported male and female counts.
- For Palembang, the printed all-category total (109,187) agrees with the four
  population-category totals but not with the printed male and female totals
  (which sum to 110,987). This is an inconsistency in the source table.

Do not impose arithmetic equality across sex-specific, category-specific, and
all-category totals for these three rows.

## Spatial data and matching

The WGS 84 shapefile in `data/spatial/` is the project-created historical
administrative boundary layer. `AREA_2` and `CODE_2` together form the stable
join identifier; `NAME_2` is retained as an auditable historical label. The
name field has a small number of historical spelling/encoding variants, so the
supplied R script intentionally joins on the two identifiers rather than
on the label.

The source spatial layer contains multipart geometry and administrative
enclaves. Its DBF represents historical spellings and character encodings;
use the complete shapefile set (`.shp`, `.shx`, `.dbf`, and `.prj`) together.
Do not treat a modern name match as an equivalent historical boundary match.

## Boundary source

The atlas map sheets were georeferenced in QGIS, then their historical
administrative boundaries were manually digitized (on-screen traced). The
source maps are in *Grote Atlas van Nederlands Oost-Indië* (2003), pages 70,
211–212, 343, 372, and 373. The GADM 4.0 Indonesia level-0 shapefile,
downloaded on 30 March 2022, was used as base geometry. The source-image copies
in the project carry National Archives of the Netherlands identifiers beginning
`NL-HaNA_GANOI`.

The resulting spatial files remain subject to the GADM licence and are not
covered by the repository's CC0 dedication.

No unmodified GADM base file is included. Its official archived download page
is linked in `data/spatial/GADM_BASE.md`.
