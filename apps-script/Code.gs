// Google Apps Script — endpoint รับสลิปจากหน้า /upload แล้วเซฟลงโฟลเดอร์ Drive
// วิธีติดตั้งอยู่ใน SETUP-UPLOAD.md (copy-paste 3 นาที ครั้งเดียวจบ)
const FOLDER_ID = 'ใส่_FOLDER_ID_ของคุณตรงนี้';

function doPost(e) {
  try {
    const data = JSON.parse(e.postData.contents);
    if (!data.b64 || !data.name) throw new Error('missing file');
    const blob = Utilities.newBlob(Utilities.base64Decode(data.b64), data.mime || 'image/jpeg', data.name);
    DriveApp.getFolderById(FOLDER_ID).createFile(blob);
    return ContentService.createTextOutput(JSON.stringify({ ok: true }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (err) {
    return ContentService.createTextOutput(JSON.stringify({ ok: false, error: String(err) }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
