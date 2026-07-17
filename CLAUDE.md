# Slip Starter — ระบบอ่านสลิปรายจ่ายอัตโนมัติ

ถ่ายสลิปเข้า Google Drive → Claude อ่านภาพ → ได้ CSV + Google Sheet + dashboard บนเว็บ
Source of truth: `data.json` · Dashboard: `index.html` (โหลด `data.js` ที่ generate จาก data.json)

## เมื่อ user พิมพ์ "ติดตั้งระบบสลิป" / "setup"

พาทำทีละขั้น (user เป็น non-coder — รันคำสั่งให้ อธิบายสั้นๆ):

1. เช็ค `command -v rclone` — ถ้าไม่มี: `brew install rclone`
2. เช็ค `rclone listremotes | grep gdrive` — ถ้าไม่มี: รัน `rclone config create gdrive drive` (จะเปิดเบราว์เซอร์ให้ล็อกอิน Google — บอก user ล่วงหน้า)
3. ถาม user: ลิงก์โฟลเดอร์ Google Drive ที่เก็บสลิป → ดึง id (ตัวท้าย URL หลัง `/folders/`) → ใส่ใน `config.sh` (DRIVE_FOLDER_ID)
4. ทดสอบ `./sync.sh` — ต้องเห็นรายชื่อไฟล์สลิป
5. ถามว่าจะเอา dashboard ขึ้นเว็บไหม → ถ้าเอา: ช่วยตั้ง GitHub repo (**private** — ข้อมูลการเงิน: `gh repo create <ชื่อ> --private --source . --push`) + Vercel (ต้องมี VERCEL_TOKEN ใน ~/.zshrc — พาสมัคร/สร้าง token ถ้ายังไม่มี แล้วตั้ง VERCEL_PROJECT ใน config.sh)
6. ถามว่าจะเปิดโหมดอัตโนมัติไหม (มีสลิปใหม่ใน Drive → ระบบอ่าน+อัปเดตเว็บเองทุก 10 นาที) → ถ้าเอา: สร้าง launchd plist ที่ `~/Library/LaunchAgents/com.slip.autoupdate.plist` รัน `auto-update.sh` ทุก 600 วิ (`StartInterval 600`, `RunAtLoad true`) แล้ว `launchctl load`
7. หน้า /upload (ทีมถ่ายสลิปจากมือถือเข้า Drive ตรงๆ): ให้ user ทำตาม `SETUP-UPLOAD.md` (ต้องล็อกอิน Google เอง) แล้วรอ user ส่ง URL มา

## เมื่อ user พิมพ์ "ตั้งค่า upload URL: <url>"

ใส่ URL ลงตัวแปร `UPLOAD_URL` ใน `upload.html` + ใส่ลิงก์โฟลเดอร์ Drive ใน `DRIVE_FOLDER_URL` แล้วรัน `./publish.sh`
ถ้า user อัปโหลดผ่าน /upload เข้า "อีกโฟลเดอร์" (คนละอันกับ DRIVE_FOLDER_ID) ให้ใส่ id นั้นใน `UPLOAD_FOLDER_ID` ใน config.sh ด้วย

## เมื่อ user พิมพ์ "process new slips"

1. หาไฟล์ภาพใน `slips/` ที่ยังไม่มีใน `data.json`
2. อ่านทีละภาพด้วย Read tool แล้ว append ลง `data.json` ตามกติกาข้างล่าง
3. รัน `./publish.sh`

## กติกาสกัดข้อมูล (ต้องตามนี้ทุกใบ)

- ปีบนสลิปธนาคารไทยเป็น พ.ศ. ตัวย่อ เช่น "17 ก.ค. 69" = 2569 → บันทึกเป็น ค.ศ. ISO `2026-07-17`
- `memo` = เฉพาะช่องบันทึกช่วยจำ/โน้ตที่พิมพ์บนสลิปเท่านั้น — เลขอ้างอิง/Biller ID ไม่ใช่ memo → `null`
- `category` = ใช้ memo กำกับ; **ถ้าไม่มี memo → `"ovh"`** (overhead/ค่าโสหุ้ย)
- field ต่อรายการ: `file, doc_type, date, time, amount_thb, fee_thb, sender_name, sender_bank, recipient_name, recipient_bank, memo, category, ref`
- ห้ามแก้รายการเก่าใน data.json เว้นแต่ user สั่ง
- ครั้งแรกที่ใช้จริง: ลบแถว demo (ref ขึ้นต้น `DEMO`) ออกก่อน

## ไฟล์ในระบบ

| ไฟล์ | หน้าที่ |
|---|---|
| `config.sh` | ค่าตั้งระบบ (folder id, ชื่อ vercel project) |
| `sync.sh` | ดึงสลิปใหม่จาก Drive ลง `slips/` |
| `build.py` | data.json → slips.csv + data.js (+กันสลิปซ้ำด้วย ref) |
| `publish.sh` | build + อัป Google Sheet + push GitHub + deploy Vercel (ข้ามขั้นที่ยังไม่ตั้งค่า) |
| `auto-update.sh` | โหมดอัตโนมัติ: เช็ค Drive → มีใหม่ → เรียก `claude -p` อ่าน → publish |
| `upload.html` (/upload) | หน้าอัปโหลดสลิปจากมือถือเข้า Drive (ผ่าน Apps Script — ดู SETUP-UPLOAD.md) |
