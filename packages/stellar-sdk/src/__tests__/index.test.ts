import { NETWORKS, isValidPublicKey, formatAmount, truncateKey } from '../index';

describe('NETWORKS', () => {
  it('testnet has correct horizon URL', () => {
    expect(NETWORKS.testnet.horizonUrl).toBe('https://horizon-testnet.stellar.org');
  });

  it('mainnet has correct horizon URL', () => {
    expect(NETWORKS.mainnet.horizonUrl).toBe('https://horizon.stellar.org');
  });

  it('passphrases are different', () => {
    expect(NETWORKS.testnet.passphrase).not.toBe(NETWORKS.mainnet.passphrase);
  });
});

describe('isValidPublicKey', () => {
  it('accepts a valid Stellar public key', () => {
    expect(isValidPublicKey('GDQP2KPQGKIHYJGXNUIYOMHARUARCA7DJT5FO2FFOOKY3B2WSQHG4W37')).toBe(true);
  });

  it('rejects a key that does not start with G', () => {
    expect(isValidPublicKey('SDQP2KPQGKIHYJGXNUIYOMHARUARCA7DJT5FO2FFOOKY3B2WSQHG4W37')).toBe(false);
  });

  it('rejects a key that is too short', () => {
    expect(isValidPublicKey('GABCD')).toBe(false);
  });

  it('rejects an empty string', () => {
    expect(isValidPublicKey('')).toBe(false);
  });

  it('rejects a key with invalid characters', () => {
    expect(isValidPublicKey('G' + '0'.repeat(55))).toBe(false);
  });
});

describe('formatAmount', () => {
  it('formats to 7 decimal places', () => {
    expect(formatAmount(2.7)).toBe('2.7000000');
  });

  it('rounds correctly', () => {
    expect(formatAmount(1.23456789)).toBe('1.2345679');
  });

  it('handles zero', () => {
    expect(formatAmount(0)).toBe('0.0000000');
  });
});

describe('truncateKey', () => {
  it('truncates a full key', () => {
    expect(truncateKey('GDQP2KPQGKIHYJGXNUIYOMHARUARCA7DJT5FO2FFOOKY3B2WSQHG4W37')).toBe('GDQP2...4W37');
  });

  it('returns short strings unchanged', () => {
    expect(truncateKey('GABCD')).toBe('GABCD');
  });
});
