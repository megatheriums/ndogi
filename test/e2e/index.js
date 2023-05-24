import {
  describe,
  expect,
  test,
} from '@jest/globals';
import fetch from 'node-fetch';

const config = {
  url: process.env.NDOGI_URL || 'localhost:3000',
};

describe('Main page', () => {
  test('Contains "Hello, World!"', async () => {
    const response = await fetch(`http://${config.url}`);
    expect(response.status).toBe(200);
    const data = await response.text();
    expect(data.toString('utf-8')).toContain('Hello, World!');
  });
});
