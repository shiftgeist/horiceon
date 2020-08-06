const fs = require('fs');
const { google } = require('googleapis');
const http = require('http');
const url = require('url');
const opn = require('opn');
const { resolve } = require('path');

module.exports = (callback) => {
    // Load client secrets from a local file.
    fs.readFile(resolve(__dirname, 'credentials.json'), (err, content) => {
        if (err) return console.log('Error loading client secret file:', err);
        // Authorize a client with credentials, then call the Gmail API.
        authorize(JSON.parse(content), callback);
    });
}

// If modifying these scopes, delete token.json.
const SCOPES = ['https://www.googleapis.com/auth/gmail.readonly'];
// The file token.json stores the user's access and refresh tokens, and is
// created automatically when the authorization flow completes for the first
// time.
const TOKEN_PATH = resolve(__dirname, 'token.json');
// Url gets called to grab the code with an http node server.
const callbackURL = new URL('http://localhost:3456')

/**
 * Create an OAuth2 client with the given credentials, and then execute the
 * given callback function.
 * @param {Object} credentials The authorization client credentials.
 * @param {function} callback The callback to call with the authorized client.
 */
function authorize(credentials, callback) {
    const { client_secret, client_id } = credentials.installed;
    const oAuth2Client = new google.auth.OAuth2(client_id, client_secret, callbackURL.href);

    // Check if we have previously stored a token.
    fs.readFile(TOKEN_PATH, (err, token) => {
        if (err) return getNewToken(oAuth2Client, callback);
        oAuth2Client.setCredentials(JSON.parse(token));
        callback(oAuth2Client);
    });
}

/**
 * Get and store new token after prompting for user authorization, and then
 * execute the given callback with the authorized OAuth2 client.
 * @param {google.auth.OAuth2} oAuth2Client The OAuth2 client to get token for.
 * @param {getEventsCallback} callback The callback for the authorized client.
 */
function getNewToken(oAuth2Client, callback) {
    const authUrl = oAuth2Client.generateAuthUrl({
        access_type: 'offline',
        scope: SCOPES,
    });

    serverListen(oAuth2Client, callback,);
    opn(authUrl);
}

/**
 * Save code server (oauth callback url)
 * @param {google.auth.OAuth2} oAuth2Client The OAuth2 client to get token for.
 * @param {getEventsCallback} callback The callback for the authorized client.
 */
function serverListen(oAuth2Client, callback,) {
    const server = http.createServer((req, res) => {
        const search = new URLSearchParams('?' + req.url.split('?')[1]);
        const code = search.get('code');

        if (code) {
            oAuth2Client.getToken(code, (err, token) => {
                if (err) return console.error('Error retrieving access token', err);
                oAuth2Client.setCredentials(token);

                // Store the token to disk for later program executions
                fs.writeFile(TOKEN_PATH, JSON.stringify(token), (err) => {
                    if (err) return console.error(err);
                    // console.log('Token stored to', TOKEN_PATH);
                });
                callback(oAuth2Client);
            })

            const body = 'You can close this page now.';
            res.writeHead(200, {
                'Content-Length': body.length,
                'Content-Type': 'text/plain'
            });
            res.end(body);
        }
    });
    server.listen(callbackURL.port);

    server.on('connection', () => {
        server.close();
    });
}
