#!/usr/bin/env node

const { writeFile, readFile } = require('fs');
const { homedir } = require('os');
const { resolve } = require('path');
const { get } = require('https')

const emojiList = resolve(homedir(), '.cache/emoji/list.txt');
const upstream = 'https://api.github.com/emojis';

async function main(data) {

    data || readFile(emojiList, (err, data) => {
        if (err) await getEmojiList();
    });

}

function getEmojiList() {
    return new Promise((resolve, reject) => {
        get({
            href: upstream,
            headers: {
                'User-Agent': 'https://github.com/shiftgeist/horiceon'
            }
        }, (res) => {
            res.on('data', (d) => {

                writeFile(emojiList, d, {}, err => {
                    if (err) throw err;
                    resolve(d);
                });

            });
        }).on('error', (err) => {
            reject(err);
        });
    })
}

main();

// check cache

// if cache doesn't exist
// send notification - download started
// prevent if no internet (ping)
// get emoji list from github
// convert to emoji/list.txt
// https://api.github.com/emojis

// pick emoji with bash exec and fzf
// EMOJI="$(echo -e "$(cat $CACHE/emoji/list.txt)" | fzf)"
// copy to clipboard if selected (xsel)
