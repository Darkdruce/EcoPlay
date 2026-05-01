use serde::{Deserialize, Serialize};
use uuid::Uuid;
use chrono::{DateTime, Utc};

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct Agent {
    pub id: Uuid,
    pub email: String,
    #[serde(skip_serializing)]
    pub password_hash: String,
    pub full_name: String,
    pub location_name: String,
    pub stellar_public_key: Option<String>,
    pub is_verified: bool,
    pub total_commission: f64,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}
