use std::env;

#[derive(Debug, Clone)]
pub struct Config {
    pub database_url: String,
    pub jwt_secret: String,
    pub jwt_expires_in: String,
    pub stellar_network: String,
    pub stellar_horizon_url: String,
    pub stellar_platform_secret_key: String,
    pub stellar_platform_public_key: String,
    pub reward_collector_pct: f64,
    pub reward_agent_pct: f64,
    pub reward_platform_pct: f64,
    pub port: u16,
}

impl Config {
    pub fn from_env() -> anyhow::Result<Self> {
        dotenvy::dotenv().ok();
        Ok(Self {
            database_url: env::var("DATABASE_URL")?,
            jwt_secret: env::var("JWT_SECRET")?,
            jwt_expires_in: env::var("JWT_EXPIRES_IN").unwrap_or_else(|_| "7d".into()),
            stellar_network: env::var("STELLAR_NETWORK").unwrap_or_else(|_| "testnet".into()),
            stellar_horizon_url: env::var("STELLAR_HORIZON_URL")
                .unwrap_or_else(|_| "https://horizon-testnet.stellar.org".into()),
            stellar_platform_secret_key: env::var("STELLAR_PLATFORM_SECRET_KEY")
                .unwrap_or_default(),
            stellar_platform_public_key: env::var("STELLAR_PLATFORM_PUBLIC_KEY")
                .unwrap_or_default(),
            reward_collector_pct: env::var("REWARD_COLLECTOR_PCT")
                .unwrap_or_else(|_| "60".into())
                .parse::<f64>()? / 100.0,
            reward_agent_pct: env::var("REWARD_AGENT_PCT")
                .unwrap_or_else(|_| "30".into())
                .parse::<f64>()? / 100.0,
            reward_platform_pct: env::var("REWARD_PLATFORM_PCT")
                .unwrap_or_else(|_| "10".into())
                .parse::<f64>()? / 100.0,
            port: env::var("PORT")
                .unwrap_or_else(|_| "3001".into())
                .parse()?,
        })
    }
}
