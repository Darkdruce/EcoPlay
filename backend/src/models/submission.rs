use serde::{Deserialize, Serialize};
use uuid::Uuid;
use chrono::{DateTime, Utc};

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::Type, PartialEq)]
#[sqlx(type_name = "material_type", rename_all = "lowercase")]
#[serde(rename_all = "lowercase")]
pub enum MaterialType {
    Plastic,
    Metal,
    Glass,
    Paper,
    Electronics,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::Type, PartialEq)]
#[sqlx(type_name = "submission_status", rename_all = "lowercase")]
#[serde(rename_all = "lowercase")]
pub enum SubmissionStatus {
    Pending,
    Verified,
    Paid,
    Rejected,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct Submission {
    pub id: Uuid,
    pub collector_id: Uuid,
    pub agent_id: Uuid,
    pub material_type: MaterialType,
    pub weight_kg: f64,
    pub price_per_kg: f64,
    pub total_value: f64,
    pub status: SubmissionStatus,
    pub proof_image_url: Option<String>,
    pub payment_tx_hash: Option<String>,
    pub created_at: DateTime<Utc>,
}
