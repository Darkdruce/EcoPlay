use crate::models::submission::MaterialType;

/// USD price per kg for each material type.
pub fn price_per_kg(material: &MaterialType) -> f64 {
    match material {
        MaterialType::Plastic => 0.15,
        MaterialType::Metal => 0.45,
        MaterialType::Glass => 0.08,
        MaterialType::Paper => 0.06,
        MaterialType::Electronics => 1.20,
    }
}

#[derive(Debug, PartialEq)]
pub struct RewardSplit {
    pub total_value: f64,
    pub collector_amount: f64,
    pub agent_amount: f64,
    pub platform_amount: f64,
}

/// Calculate reward split given material, weight, and split percentages.
/// Percentages are fractions (e.g. 0.60, 0.30, 0.10).
pub fn calculate(
    material: &MaterialType,
    weight_kg: f64,
    collector_pct: f64,
    agent_pct: f64,
    platform_pct: f64,
) -> RewardSplit {
    let total_value = round7(price_per_kg(material) * weight_kg);
    RewardSplit {
        total_value,
        collector_amount: round7(total_value * collector_pct),
        agent_amount: round7(total_value * agent_pct),
        platform_amount: round7(total_value * platform_pct),
    }
}

fn round7(v: f64) -> f64 {
    (v * 1_000_000_0.0).round() / 1_000_000_0.0
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::models::submission::MaterialType;

    #[test]
    fn test_price_per_kg() {
        assert_eq!(price_per_kg(&MaterialType::Plastic), 0.15);
        assert_eq!(price_per_kg(&MaterialType::Metal), 0.45);
        assert_eq!(price_per_kg(&MaterialType::Glass), 0.08);
        assert_eq!(price_per_kg(&MaterialType::Paper), 0.06);
        assert_eq!(price_per_kg(&MaterialType::Electronics), 1.20);
    }

    #[test]
    fn test_calculate_metal_10kg() {
        // 10kg metal = $4.50 total
        // collector 60% = $2.70, agent 30% = $1.35, platform 10% = $0.45
        let split = calculate(&MaterialType::Metal, 10.0, 0.60, 0.30, 0.10);
        assert_eq!(split.total_value, 4.5);
        assert_eq!(split.collector_amount, 2.7);
        assert_eq!(split.agent_amount, 1.35);
        assert_eq!(split.platform_amount, 0.45);
    }

    #[test]
    fn test_calculate_electronics_1kg() {
        let split = calculate(&MaterialType::Electronics, 1.0, 0.60, 0.30, 0.10);
        assert_eq!(split.total_value, 1.20);
        assert_eq!(split.collector_amount, 0.72);
        assert_eq!(split.agent_amount, 0.36);
        assert_eq!(split.platform_amount, 0.12);
    }

    #[test]
    fn test_split_sums_to_total() {
        for material in [
            MaterialType::Plastic,
            MaterialType::Metal,
            MaterialType::Glass,
            MaterialType::Paper,
            MaterialType::Electronics,
        ] {
            let split = calculate(&material, 5.0, 0.60, 0.30, 0.10);
            let sum = round7(split.collector_amount + split.agent_amount + split.platform_amount);
            assert_eq!(sum, split.total_value, "Split does not sum to total for {material:?}");
        }
    }

    #[test]
    fn test_zero_weight() {
        let split = calculate(&MaterialType::Metal, 0.0, 0.60, 0.30, 0.10);
        assert_eq!(split.total_value, 0.0);
        assert_eq!(split.collector_amount, 0.0);
        assert_eq!(split.agent_amount, 0.0);
        assert_eq!(split.platform_amount, 0.0);
    }
}
