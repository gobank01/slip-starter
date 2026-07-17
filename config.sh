# ตั้งค่าระบบสลิป — เปิด Claude Code แล้วพิมพ์ "ติดตั้งระบบสลิป" ให้ Claude กรอกให้
DRIVE_FOLDER_ID=""                        # id โฟลเดอร์สลิปใน Google Drive (ตัวท้าย URL หลัง /folders/)
UPLOAD_FOLDER_ID=""                       # id โฟลเดอร์รับไฟล์จากหน้า /upload (เว้นว่างถ้าใช้โฟลเดอร์เดียวกัน)
DRIVE_SHEET_PATH="Slip/สลิปรายจ่าย.csv"    # ที่เก็บ Google Sheet ใน My Drive ("" = ไม่อัป Sheet)
VERCEL_PROJECT="my-slip-dashboard"        # ชื่อ project บน Vercel (ตัวเล็ก a-z 0-9 -)
VERCEL_SCOPE_ARG=""                       # ถ้ามี team เช่น "--scope your-team"
