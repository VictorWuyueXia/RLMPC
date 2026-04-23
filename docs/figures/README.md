# Figures for README and applications

| File | Source |
|------|--------|
| `LPV.png` | Project artifact (LPV-related result) |
| `report_p01.png` … `report_p10.png` | Rasterized pages from `../report/VXia_FinalReport.pdf` (subset of pages exported for quick visual summary) |

To re-export report pages (requires PyMuPDF), from the repository root:

```bash
python3 -m pip install pymupdf
python3 scripts/export_report_figures.py
```
