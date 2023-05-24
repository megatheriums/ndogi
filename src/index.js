import express from 'express';
import path from 'path';
import url from 'url';

import query from './lib/query.js';
import setup from './lib/setup.js';

const __dirname = path.dirname(url.fileURLToPath(import.meta.url));

const app = express();

app.use(express.urlencoded({
  extended: false,
}));
app.use(express.json({
  extended: false,
}));

app.use('/', express.static(path.join(__dirname, '..', 'data', 'public')));

app.post('/link', async (req, res) => {
  const {
    short,
    target,
  } = req.body;

  if (!short || !target) {
    res.status(400).send('Invalid parameter values for "short" and/or "target".');
    return;
  }
  const results = await query('SELECT 1 FROM links WHERE short = ? LIMIT 1', [short]);
  if (results.length > 0) {
    res.status(502).send(`Short "${short}" already in use.`);
    return;
  }

  await query('INSERT INTO links SET short = ?, target = ?', [
    short,
    target,
  ]);
  res.send(`Created short: <a href="/${short}" target="_blank">/${short}</a>`);
});

const deleteShort = async (req, res) => {
  const {
    short,
  } = req.query;

  if (!short) {
    res.status(400).send('Missing parameter "short".');
    return;
  }
  await query('DELETE FROM links WHERE short = ? LIMIT 1', [
    short,
  ]);
  res.send(`Successfully deleted link for "${short}".`);
};
app.delete('/link', deleteShort);
app.get('/link-delete', deleteShort);

app.get('/*', async (req, res) => {
  const requestPath = req.path.replace(/^\//, '');
  const results = await query('SELECT target FROM links WHERE short = ? LIMIT 1', [requestPath]);
  if (results.length === 1) {
    let {
      target,
    } = results[0];

    if (target.substr(0, 4) !== 'http') {
      target = `https://${target}`;
    }
    console.log(`Redirecting to: ${target}`);
    res.redirect(301, target);
  }
  console.debug(`Couldn't find link for "${requestPath}"`);
  res.status(404).send();
});

(async () => {
  await setup();

  app.listen(3000, () => {
    console.log('Server started on port 3000.');
  });
})();
