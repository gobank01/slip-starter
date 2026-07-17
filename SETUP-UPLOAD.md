# ตั้งค่าหน้า /upload (ครั้งเดียว ~3 นาที)

หน้า `/upload` ให้ทีมถ่ายสลิปจากมือถือเข้า Drive ได้เลย โดยใช้ Google Apps Script เป็นตัวรับไฟล์ (ฟรี ไม่ต้องมี server) — ขั้นตอนนี้ต้องล็อกอิน Google เอง Claude ทำแทนไม่ได้:

1. เปิด https://script.google.com → **New project**
2. ลบโค้ดเดิม แล้ววางโค้ดจากไฟล์ `apps-script/Code.gs` ทั้งไฟล์
3. แก้บรรทัด `FOLDER_ID` เป็น id โฟลเดอร์สลิปของคุณ (ตัวท้าย URL โฟลเดอร์ Drive หลัง `/folders/`)
4. กด **Deploy → New deployment → Web app**
   - Execute as: **Me**
   - Who has access: **Anyone**
   - กด Deploy แล้ว **อนุญาตสิทธิ์** (Authorize) ตามที่ถาม
5. copy **Web app URL** (ลงท้าย `/exec`) มา

จากนั้นเปิด Claude Code ในโฟลเดอร์นี้ แล้วพิมพ์:

```
ตั้งค่า upload URL: <วาง URL ตรงนี้>
```

Claude จะใส่ URL ลง `upload.html` แล้ว deploy ให้เอง เสร็จแล้วแชร์ลิงก์ `https://<โปรเจคของคุณ>.vercel.app/upload` ให้ทีมได้เลย

> หมายเหตุ: ใครมี URL /upload ก็อัปไฟล์เข้าโฟลเดอร์ได้ — แชร์เฉพาะคนในทีม
