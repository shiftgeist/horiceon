// https://developers.google.com/gmail/api/quickstart/nodejs

const fs = require('fs')
const readline = require('readline')
const path = require('path')
const {google} = require('googleapis')

let creds
const CREDENTIAL_PATH = path.resolve(__dirname, '.env.json')

// Load client secrets from a local file.
fs.readFile(CREDENTIAL_PATH, (err, content) => {
  if (err) return saveError('Error loading client secret file:', err)
  creds = JSON.parse(content)

  // Authorize a client with credentials, then call the Gmail API.
  authorize(creds, listLabels)
});

function authorize({ token }, callback) {
  const {client_secret, client_id} = creds
  const oAuth2Client = new google.auth.OAuth2(client_id, client_secret, 'urn:ietf:wg:oauth:2.0:oob')

  if (!token) return getNewToken(oAuth2Client, callback)
  oAuth2Client.setCredentials(token)
  callback(oAuth2Client)
}

function getNewToken(oAuth2Client, callback) {
  const auth_url = oAuth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: 'https://www.googleapis.com/auth/gmail.readonly',
  });
  console.log('Authorize this app by visiting this url:', auth_url)
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });
  rl.question('Enter the code from that page here: ', (code) => {
    rl.close()
    oAuth2Client.getToken(code, (err, token) => {
      if (err) return saveError('Error retrieving access token', err)
      oAuth2Client.setCredentials(token)
      creds.token = token
      // Store the token to disk for later program executions
      fs.writeFile(CREDENTIAL_PATH, JSON.stringify(creds, null, 4), (err) => {
        if (err) return saveError(err)
        console.log('Token stored to', CREDENTIAL_PATH)
      })
      callback(oAuth2Client)
    });
  });
}

function listLabels(auth) {
  const gmail = google.gmail({version: 'v1', auth});
  gmail.users.labels.get({
    userId: 'me',
    id: 'INBOX'
  }, (err, res) => {
    if (err) return saveError('The API returned an error: ' + err)
    const count = res.data.messagesUnread
    console.log(count)
  });
}

function saveError(...err) {
  fs.writeFile(resolve(__dirname, 'error.log'), JSON.stringify({...err}, null, 4), (err) => {
    if (err) console.log('Error')
  })
}
