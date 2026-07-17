// รับสลิปจากหน้า /upload -> เซฟเข้าโฟลเดอร์ Google Drive (ทำได้แค่สร้างไฟล์ในโฟลเดอร์เดียวเท่านั้น)
export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ ok: false, error: 'POST only' });
  const { G_CLIENT_ID, G_CLIENT_SECRET, G_REFRESH_TOKEN, G_FOLDER_ID } = process.env;
  if (!G_REFRESH_TOKEN || !G_FOLDER_ID)
    return res.status(500).json({ ok: false, error: 'ยังไม่ได้ตั้งค่า upload (รัน setup)' });

  const { name, mime, b64 } = req.body || {};
  if (!name || !b64) return res.status(400).json({ ok: false, error: 'missing file' });
  if (b64.length > 15_000_000) return res.status(413).json({ ok: false, error: 'ไฟล์ใหญ่เกินไป' });

  const tok = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_id: G_CLIENT_ID, client_secret: G_CLIENT_SECRET,
      refresh_token: G_REFRESH_TOKEN, grant_type: 'refresh_token',
    }),
  }).then(r => r.json());
  if (!tok.access_token) return res.status(500).json({ ok: false, error: 'auth failed' });

  const boundary = 'slipupload' + Date.now();
  const meta = JSON.stringify({ name, parents: [G_FOLDER_ID] });
  const body = Buffer.concat([
    Buffer.from(`--${boundary}\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n${meta}\r\n--${boundary}\r\nContent-Type: ${mime || 'image/jpeg'}\r\nContent-Transfer-Encoding: base64\r\n\r\n`),
    Buffer.from(b64),
    Buffer.from(`\r\n--${boundary}--`),
  ]);
  // client กลางของ rclone โดน rate-limit เป็นพักๆ — retry สั้นๆ พอ
  let up;
  for (let i = 0; i < 3; i++) {
    up = await fetch('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart', {
      method: 'POST',
      headers: { Authorization: `Bearer ${tok.access_token}`, 'Content-Type': `multipart/related; boundary=${boundary}` },
      body,
    }).then(r => r.json());
    if (!up.error || !/quota|rate/i.test(up.error.message)) break;
    await new Promise(r => setTimeout(r, 1500));
  }
  if (up.error) return res.status(500).json({ ok: false, error: up.error.message });
  return res.status(200).json({ ok: true, id: up.id });
}
