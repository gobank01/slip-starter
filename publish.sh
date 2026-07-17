#!/bin/zsh
# build + อัป Google Sheet + push GitHub + deploy Vercel — ขั้นไหนยังไม่ได้ตั้งค่าจะข้ามให้เอง
set -e
cd "$(dirname "$0")"
source ./config.sh
source ~/.zshrc >/dev/null 2>&1 || true

python3 build.py

if [ -n "$DRIVE_SHEET_PATH" ]; then
  rclone copyto slips.csv "gdrive:$DRIVE_SHEET_PATH" \
    --drive-import-formats csv --drive-export-formats csv
  echo "✓ Google Sheet อัปเดตแล้ว (My Drive/$DRIVE_SHEET_PATH)"
fi

if git remote get-url origin >/dev/null 2>&1; then
  git add -A
  git diff --cached --quiet || git commit -m "update slips data $(date +%Y-%m-%d)"
  git push origin main
  echo "✓ push GitHub แล้ว"
else
  echo "· ยังไม่ได้เชื่อม GitHub — ข้าม push (ให้ Claude ช่วยตั้งได้: พิมพ์ 'เชื่อม github')"
fi

if [ -n "$VERCEL_TOKEN" ]; then
  [ -f .vercel/project.json ] || npx vercel@latest link --yes --project "$VERCEL_PROJECT" --token "$VERCEL_TOKEN" ${=VERCEL_SCOPE_ARG}
  npx vercel@latest deploy --prod --yes --token "$VERCEL_TOKEN" ${=VERCEL_SCOPE_ARG}
  echo "✓ deploy Vercel แล้ว"
else
  echo "· ไม่มี VERCEL_TOKEN — ข้าม deploy (เปิดไฟล์ index.html ดูในเครื่องได้เลย)"
fi
