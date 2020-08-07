const { writeFileSync } = require('fs');
const { join } = require('path');
const mustache = require('mustache');

const template = JSON.stringify(require(`${__dirname}/template.json`));
const themeName = 'Horiceon-color-theme';

const content = require(`${__dirname}/settings.json`);
const theme = mustache.render(template, content);
writeFileSync(join(__dirname, '../themes/', themeName + '.json'), theme);
