#!/usr/bin/env python3
"""data.json -> slips.csv + data.js (สำหรับ index.html)"""
import csv, json, pathlib, sys

root = pathlib.Path(__file__).parent
rows = json.loads((root / "data.json").read_text())
rows.sort(key=lambda r: (r["date"], r["time"]))

refs = [r["ref"] for r in rows if r.get("ref")]
dupes = {x for x in refs if refs.count(x) > 1}
if dupes:
    sys.exit(f"❌ มีสลิปซ้ำ (เลขที่รายการเดียวกันหลายรายการ): {dupes} — ลบตัวซ้ำใน data.json ก่อน")

FIELDS = ["date", "time", "doc_type", "amount_thb", "fee_thb", "category", "memo",
          "recipient_name", "recipient_bank", "sender_name", "sender_bank", "ref", "file"]
with open(root / "slips.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=FIELDS, extrasaction="ignore")
    w.writeheader()
    w.writerows(rows)

(root / "data.js").write_text("window.SLIPS = " + json.dumps(rows, ensure_ascii=False, indent=1) + ";\n")
print(f"built slips.csv + data.js ({len(rows)} รายการ, รวม {sum(r['amount_thb'] for r in rows):,.2f} บาท)")
