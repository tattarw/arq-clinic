# arq. Waitlist → Google Sheets Setup

## 2-minute setup:

### Step 1: Create a Google Sheet
1. Go to https://sheets.new
2. Name it "arq. Waitlist"
3. In Row 1, add these headers: **Name | Email | Phone | Page | Timestamp**

### Step 2: Add the Script
1. In the Google Sheet, go to **Extensions → Apps Script**
2. Delete everything in the editor and paste this code:

```javascript
function doPost(e) {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  var data = JSON.parse(e.postData.contents);
  sheet.appendRow([
    data.name || '',
    data.email || '',
    data.phone || '',
    data.page || '',
    data.ts || new Date().toISOString()
  ]);
  return ContentService
    .createTextOutput(JSON.stringify({status: 'ok'}))
    .setMimeType(ContentService.MimeType.JSON);
}
```

3. Click **Deploy → New deployment**
4. Type = **Web app**
5. Execute as = **Me**
6. Who has access = **Anyone**
7. Click **Deploy** and **Authorize access**
8. Copy the Web app URL (looks like `https://script.google.com/macros/s/AKfyc.../exec`)

### Step 3: Tell me the URL
Paste the URL here and I'll wire it into all pages automatically.
