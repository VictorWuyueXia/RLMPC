#!/usr/bin/env python3
"""
Rasterize selected pages from the final report PDF into docs/figures/.
Run from repository root: python3 scripts/export_report_figures.py
"""
import os
import sys

import fitz


def main(repo_root):
    pdf_path = os.path.join(repo_root, "docs", "report", "VXia_FinalReport.pdf")
    out_dir = os.path.join(repo_root, "docs", "figures")
    os.makedirs(out_dir, exist_ok=True)
    doc = fitz.open(pdf_path)
    n = doc.page_count
    idxs = [0]
    if n > 1:
        idxs.append(1)
    for p in [max(2, n // 4), max(3, n // 2), max(4, (3 * n) // 4), n - 1]:
        if p not in idxs and p < n:
            idxs.append(p)
    idxs = sorted(set(i for i in idxs if 0 <= i < n))[:8]
    zoom = 2.0
    mat = fitz.Matrix(zoom, zoom)
    for i in idxs:
        page = doc.load_page(i)
        pix = page.get_pixmap(matrix=mat, alpha=False)
        out_path = os.path.join(out_dir, "report_p%02d.png" % (i + 1))
        pix.save(out_path)
    doc.close()
    print("Exported %d pages from %s (total pages=%d) to %s" % (len(idxs), pdf_path, n, out_dir))


if __name__ == "__main__":
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    main(root)
