// All shared TypeScript types used across apps and packages

export type UserRole = 'collector' | 'admin';

export type MaterialType = 'plastic' | 'metal' | 'glass' | 'paper' | 'electronics';

export type SubmissionStatus = 'pending' | 'verified' | 'paid' | 'rejected';

export type TransactionType = 'collector_reward' | 'agent_commission' | 'platform_fee';

export interface User {
  id: string;
  email: string;
  fullName: string;
  role: UserRole;
  stellarPublicKey: string | null;
  totalEarned: number;
  totalWeightKg: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Agent {
  id: string;
  email: string;
  fullName: string;
  locationName: string;
  stellarPublicKey: string | null;
  isVerified: boolean;
  totalCommission: number;
  createdAt: string;
  updatedAt: string;
}

export interface Submission {
  id: string;
  collectorId: string;
  agentId: string;
  materialType: MaterialType;
  weightKg: number;
  pricePerKg: number;
  totalValue: number;
  status: SubmissionStatus;
  proofImageUrl: string | null;
  paymentTxHash: string | null;
  createdAt: string;
}

export interface Transaction {
  id: string;
  submissionId: string;
  txType: TransactionType;
  recipientPublicKey: string;
  amount: number;
  asset: string;
  stellarTxHash: string | null;
  success: boolean;
  errorMessage: string | null;
  createdAt: string;
}

export interface LeaderboardEntry {
  rank: number;
  id: string;
  fullName: string;
  totalEarned: number;
  totalWeightKg: number;
}

export interface RewardSplit {
  totalValue: number;
  collectorAmount: number;
  agentAmount: number;
  platformAmount: number;
}

// Material base prices in USD/kg
export const MATERIAL_PRICES: Record<MaterialType, number> = {
  plastic: 0.15,
  metal: 0.45,
  glass: 0.08,
  paper: 0.06,
  electronics: 1.20,
};

// Default reward split percentages
export const DEFAULT_SPLITS = {
  collector: 0.60,
  agent: 0.30,
  platform: 0.10,
} as const;

// API response wrappers
export interface ApiResponse<T> {
  data: T;
}

export interface ApiError {
  error: string;
}

export interface AuthResponse {
  access_token: string;
}
