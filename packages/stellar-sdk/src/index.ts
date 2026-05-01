export const NETWORKS = {
  testnet: {
    horizonUrl: 'https://horizon-testnet.stellar.org',
    passphrase: 'Test SDF Network ; September 2015',
  },
  mainnet: {
    horizonUrl: 'https://horizon.stellar.org',
    passphrase: 'Public Global Stellar Network ; September 2015',
  },
} as const;

export type StellarNetwork = keyof typeof NETWORKS;

/**
 * Validates a Stellar public key (G..., 56 chars, base32 charset).
 */
export function isValidPublicKey(key: string): boolean {
  return /^G[A-Z2-7]{55}$/.test(key);
}

/**
 * Formats a Stellar amount to 7 decimal places as required by the protocol.
 */
export function formatAmount(amount: number): string {
  return amount.toFixed(7);
}

/**
 * Truncates a public key for display: GABCD...WXYZ
 */
export function truncateKey(key: string): string {
  if (key.length < 10) return key;
  return `${key.slice(0, 5)}...${key.slice(-4)}`;
}
