import {
  describe,
  expect,
  test,
} from '@jest/globals';
import fetch from 'node-fetch';
import querystring from 'querystring';
import {
  uuid,
} from 'uuidv4';

const config = {
  url: `http://${process.env.NDOGI_URL || 'localhost:3000'}`,
};

console.log(config);

const short = `--random-test-link-${uuid()}`;
const target = 'https://github.com/megatheriums/ndogi';

describe('Main page', () => {
  test('Contains "Hello, World!"', async () => {
    const response = await fetch(config.url);
    expect(response.status).toBe(200);
    const data = await response.text();
    expect(data.toString('utf-8')).toContain('Hello, World!');
  });
});

describe('Link creation', () => {
  test.concurrent('Creating a short', async () => {
    const response = await fetch(`${config.url}/link`, {
      method: 'POST',
      body: JSON.stringify({
        short,
        target,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    });
    expect(response.status).toBe(200);
  });
  test.concurrent('Browsing an existing link', async () => {
    const response2 = await fetch(`${config.url}/${short}`, {
      redirect: 'manual',
    });
    expect(response2.status).toBe(301);
    expect(response2.headers.get('Location')).toBe(target);
  });
  test.concurrent('Deleting a short', async () => {
    const response = await fetch(`${config.url}/link?${querystring.stringify({
      short,
    })}`, {
      method: 'DELETE',
    });
    expect(response.status).toBe(200);
  });
  test.concurrent('Browsing a non-existent short', async () => {
    const response = await fetch(`${config.url}/${short}`);
    expect(response.status).toBe(404);
  });
  test.concurrent('Deleting a non-existent short', async () => {
    const response = await fetch(`${config.url}/link?${querystring.stringify({
      short,
    })}`, {
      method: 'DELETE',
    });
    expect(response.status).toBe(200);
  });
});
