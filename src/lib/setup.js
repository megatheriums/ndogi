const fs = require('fs/promises');
const fsSync = require('fs');
const path = require('path');

const query = require('./query');

const setup = async () => {
  let currentVersion = -1;

  try {
    const rows = await query('SELECT value FROM options WHERE name = \'version\' LIMIT 1');

    if (rows.length > 0) {
      currentVersion = parseInt(rows[0].value, 10);
      console.debug(`Current database version: ${currentVersion}`);
    }
  } catch (err) {
    if ([
      'ER_BAD_FIELD_ERROR',
      'ER_NO_SUCH_TABLE',
    ].indexOf(err.code) < 0) {
      throw err;
    }

    console.debug('Table "options" not found. Running initial setup...');
  }

  while (true) {
    const nextVersion = currentVersion + 1;

    const setupFilename = path.join(__dirname, '..', '..', 'data', 'database', `${nextVersion}.sql`);
    if (!fsSync.existsSync(setupFilename)) {
      break;
    }

    // eslint-disable-next-line no-await-in-loop
    const queries = await fs.readFile(setupFilename, 'utf-8');
    // eslint-disable-next-line no-await-in-loop
    await query(queries);
    currentVersion = nextVersion;
  }

  await query('UPDATE options SET value = ? WHERE name = \'version\'', [
    currentVersion,
  ]);
};

module.exports = setup;
