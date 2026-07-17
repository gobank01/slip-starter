#!/bin/zsh
# เช็คสลิปใหม่จาก Drive — ถ้ามี ให้ Claude อ่านแล้ว publish อัตโนมัติ (ใช้กับ launchd/cron)
cd "$(dirname "$0")"
source ./config.sh
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$PATH"
[ -z "$DRIVE_FOLDER_ID" ] && exit 0

rclone copy gdrive: slips/ --drive-root-folder-id "$DRIVE_FOLDER_ID" -q
[ -n "$UPLOAD_FOLDER_ID" ] && rclone copy gdrive: slips/ --drive-root-folder-id "$UPLOAD_FOLDER_ID" -q

new=""
for f in slips/*.(jpg|JPG|jpeg|JPEG|png|PNG)(N); do
  grep -q "$(basename "$f")" data.json 2>/dev/null || new="$new $(basename "$f")"
done
[ -z "$new" ] && exit 0

echo "$(date '+%F %T') พบสลิปใหม่:$new" >> auto-update.log
claude -p "process new slips: อ่านสลิปใหม่ใน slips/ ที่ยังไม่อยู่ใน data.json ตามกติกาใน CLAUDE.md แล้ว append ลง data.json เสร็จแล้วรัน ./publish.sh" \
  --allowedTools "Read,Edit,Write,Bash" >> auto-update.log 2>&1
echo "$(date '+%F %T') อัปเดตเสร็จ (exit $?)" >> auto-update.log
