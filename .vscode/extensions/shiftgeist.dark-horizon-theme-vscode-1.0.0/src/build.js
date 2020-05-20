const fs = require('fs');
const mustache = require('mustache');

const template = JSON.stringify(require(`${__dirname}/template.json`));
const themeName = 'dark-horizon';

const content = require(`${__dirname}/${themeName}.json`);
const theme = mustache.render(template, content);
fs.writeFileSync(`${__dirname}/../theme/${themeName}.json`, theme);
