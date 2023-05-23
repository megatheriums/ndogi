const express = require('express');

const query = require('./lib/query');
const setup = require('./lib/setup');

const app = express();

app.use(express.urlencoded({
  extended: false,
}));

app.get('/', (req, res) => {
  res.send('Hello, World!');
});

app.get('/create-link', async (req, res) => {
  const {
    short,
    target,
  } = req.query;

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
  res.send();
});

app.get('/delete-link', async (req, res) => {
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
  res.send();
});

app.get('/*', async (req, res) => {
  const path = req.path.replace(/^\//, '');
  const results = await query('SELECT target FROM links WHERE short = ? LIMIT 1', [path]);
  console.log(results);
  if (results.length === 1) {
    console.log(`Redirecting to: ${results[0].target}`);
    res.setHeader('Location', results[0].target);
    res.status(301).send();
    return;
  }
  console.debug(`Couldn't find link for "${path}"`);
  res.status(404).send();
});

(async () => {
  await setup();

  app.listen(3000, () => {
    console.log('Server started.');
  });
})();
