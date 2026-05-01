import { getConfig } from '../index';

describe('getConfig', () => {
  it('returns config with valid env', () => {
    const config = getConfig({
      NEXT_PUBLIC_API_URL: 'http://localhost:3001',
      NEXT_PUBLIC_STELLAR_NETWORK: 'testnet',
    });
    expect(config.apiUrl).toBe('http://localhost:3001');
    expect(config.stellarNetwork).toBe('testnet');
  });

  it('defaults stellarNetwork to testnet when not set', () => {
    const config = getConfig({ NEXT_PUBLIC_API_URL: 'http://localhost:3001' });
    expect(config.stellarNetwork).toBe('testnet');
  });

  it('throws when NEXT_PUBLIC_API_URL is missing', () => {
    expect(() => getConfig({})).toThrow('Missing NEXT_PUBLIC_API_URL');
  });

  it('throws on invalid stellar network value', () => {
    expect(() =>
      getConfig({ NEXT_PUBLIC_API_URL: 'http://localhost:3001', NEXT_PUBLIC_STELLAR_NETWORK: 'devnet' })
    ).toThrow('Invalid NEXT_PUBLIC_STELLAR_NETWORK');
  });

  it('accepts mainnet', () => {
    const config = getConfig({
      NEXT_PUBLIC_API_URL: 'https://api.ecoplay.io',
      NEXT_PUBLIC_STELLAR_NETWORK: 'mainnet',
    });
    expect(config.stellarNetwork).toBe('mainnet');
  });
});
