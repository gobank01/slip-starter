#!/bin/zsh
# ดึงสลิปใหม่จาก Google Drive ลง slips/
cd "$(dirname "$0")"
source ./config.sh
if [ -z "$DRIVE_FOLDER_ID" ]; then
  echo "❌ ยังไม่ได้ตั้งค่า DRIVE_FOLDER_ID ใน config.sh"
  echo "   เปิด Claude Code ในโฟลเดอร์นี้ แล้วพิมพ์: ติดตั้งระบบสลิป"
  exit 1
fi
rclone copy gdrive: slips/ --drive-root-folder-id "$DRIVE_FOLDER_ID" -P
echo ""
echo "สลิปทั้งหมด: $(ls slips | grep -vc '^\.' ) ไฟล์"
echo "ยังไม่ประมวลผล (ไม่อยู่ใน data.json):"
for f in slips/*.(jpg|JPG|jpeg|JPEG|png|PNG)(N); do
  grep -q "$(basename "$f")" data.json 2>/dev/null || echo "  - $(basename "$f")"
done
echo ""
echo "ขั้นต่อไป: เปิด Claude Code ในโฟลเดอร์นี้ แล้วพิมพ์ \"process new slips\""
