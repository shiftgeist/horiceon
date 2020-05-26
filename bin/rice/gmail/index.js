// https://developers.google.com/gmail/api/quickstart/nodejs

const http = require('http')
const { google } = require('googleapis')
const opn = require('opn')
require('dotenv').config();

if (!(process.env.CLIENT_ID && process.env.CLIENT_SECRET)) {
  console.log('missing client')
}

// callback
const port = 3456;
let token = process.env.CLIENT_TOKEN;
const server = http.createServer((req, res) => {
  const body = 'You can close this page now.';
  res.writeHead(200, {
    'Content-Length': body.length,
    'Content-Type': 'text/plain'
  })
  res.end(body)
})

server.listen(port)

// oauth
function authorize(callback) {
  const oAuth2Client = new google.auth.OAuth2(process.env.CLIENT_ID, process.env.CLIENT_SECRET, `http://localhost:${port}`)

  if (!token) return getNewToken(oAuth2Client)
  oAuth2Client.setCredentials(token)
  callback(oAuth2Client)
}

function getNewToken(oAuth2Client) {
  const auth_url = oAuth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: 'https://www.googleapis.com/auth/gmail.readonly',
  });
  opn(auth_url)

  oAuth2Client.setCredentials(token)

  oAuth2Client.on('tokens', tokens => {
    if (tokens.refresh_token) {
      oauth2Client.setCredentials({
        refresh_token: rokens.refresh_token
      })
    }

    token = tokens.access_token
  })
}

// gmail
function listLabels(auth) {
  const gmail = google.gmail({version: 'v1', auth});
  gmail.users.labels.get({
    userId: 'me',
    id: 'INBOX'
  }, (err, res) => {
    if (err) return console.log('The API returned an error: ' + err)
    const count = res.data.messagesUnread
    console.log(count)
  })
  server.close();
}

// exec
authorize(listLabels)
