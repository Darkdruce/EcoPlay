import {
  MATERIAL_PRICES,
  DEFAULT_SPLITS,
  MaterialType,
} from '../index';

describe('MATERIAL_PRICES', () => {
  const cases: [MaterialType, number][] = [
    ['plastic', 0.15],
    ['metal', 0.45],
    ['glass', 0.08],
    ['paper', 0.06],
    ['electronics', 1.20],
  ];

  test.each(cases)('%s = $%s/kg', (material, price) => {
    expect(MATERIAL_PRICES[material]).toBe(price);
  });
});

describe('DEFAULT_SPLITS', () => {
  it('sums to 1.0', () => {
    const total = DEFAULT_SPLITS.collector + DEFAULT_SPLITS.agent + DEFAULT_SPLITS.platform;
    expect(total).toBeCloseTo(1.0);
  });

  it('collector gets 60%', () => expect(DEFAULT_SPLITS.collector).toBe(0.60));
  it('agent gets 30%',     () => expect(DEFAULT_SPLITS.agent).toBe(0.30));
  it('platform gets 10%', () => expect(DEFAULT_SPLITS.platform).toBe(0.10));
});
