export interface AppConfig {
  apiUrl: string;
  stellarNetwork: 'testnet' | 'mainnet';
}

/**
 * Reads and validates frontend env vars.
 * Throws if required vars are missing.
 */
export function getConfig(env: Record<string, string | undefined> = process.env): AppConfig {
  const apiUrl = env['NEXT_PUBLIC_API_URL'];
  if (!apiUrl) throw new Error('Missing NEXT_PUBLIC_API_URL');

  const network = env['NEXT_PUBLIC_STELLAR_NETWORK'] ?? 'testnet';
  if (network !== 'testnet' && network !== 'mainnet') {
    throw new Error(`Invalid NEXT_PUBLIC_STELLAR_NETWORK: "${network}"`);
  }

  return { apiUrl, stellarNetwork: network };
}
