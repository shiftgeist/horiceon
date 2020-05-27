const { gmail } = require('googleapis').google;
const googleauth = require('./googleauth');

// gmail
function listLabels(auth) {
  const gmail = gmail({version: 'v1', auth});
  gmail.users.labels.get({
    userId: 'me',
    id: 'INBOX'
  }, (err, res) => {
    if (err) return console.log('The API returned an error: ' + err)
    const count = res.data.messagesUnread
    console.log(count)
  })
}

// exec
googleauth(listLabels);
