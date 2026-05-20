use std::collections::HashMap;

use crate::io::{Input, Solution};

const TRILLION: i64 = 1_000_000_000_000;

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i64 {
    resolve(input, 1)
}

fn part_two(input: &Input) -> i64 {
    binary_search(input)
}

fn resolve(input: &Input, fuel_demand: i64) -> i64 {
    let mut resolver = ReactionResolver::from(input);
    resolver.scale(fuel_demand);
    *resolver.resolve()
}

fn binary_search(input: &Input) -> i64 {
    let mut lower = TRILLION / part_one(input);
    let mut upper = 2 * lower;
    while lower <= upper {
        let mid = lower + (upper - lower) / 2;
        let req = resolve(input, mid);
        if req < TRILLION {
            lower = mid + 1;
        } else if req > TRILLION {
            upper = mid - 1;
        } else {
            return mid;
        }
    }
    upper
}

struct ReactionResolver {
    extra: HashMap<String, i64>,
    reactions: HashMap<String, Reaction>,
    requirements: HashMap<String, i64>,
}

impl ReactionResolver {
    fn resolve(&mut self) -> &i64 {
        while self.requirements.len() > 1 {
            self.update();
        }
        self.requirements.get("ORE").unwrap()
    }

    fn scale(&mut self, multiplier: i64) {
        for req in self.requirements.values_mut() {
            *req *= multiplier;
        }
    }

    fn update(&mut self) {
        let prev = self.requirements.iter().collect::<Vec<_>>();
        let mut curr = HashMap::new();
        for (id, demand) in prev {
            if id == "ORE" {
                curr.entry(id.to_string())
                    .and_modify(|r| *r += demand)
                    .or_insert(*demand);
            } else {
                let reaction = self.reaction(id);
                let supply = self.extra(id);
                let (ingredients, extra) = reaction.ingredients(demand, supply);
                self.extra.insert(id.clone(), extra);
                for chemical in ingredients {
                    curr.entry(chemical.id)
                        .and_modify(|r| *r += chemical.quantity)
                        .or_insert(chemical.quantity);
                }
            }
        }
        self.requirements = curr;
    }

    fn extra(&self, id: &str) -> &i64 {
        self.extra.get(id).unwrap_or(&0)
    }

    fn reaction(&self, id: &str) -> &Reaction {
        match self.reactions.get(id) {
            Some(reaction) => reaction,
            None => panic!("no reaction for chemical = {}", id),
        }
    }
}

impl From<&Input> for ReactionResolver {
    fn from(input: &Input) -> Self {
        let mut reactions = HashMap::new();
        for line in input.data.lines() {
            let reaction = Reaction::new(line);
            reactions.insert(reaction.id(), reaction);
        }
        let mut requirements = HashMap::new();
        if let Some(reaction) = reactions.get("FUEL") {
            for chemical in &reaction.ingredients {
                requirements.insert(chemical.id.clone(), chemical.quantity);
            }
        }
        let extra = HashMap::new();
        Self {
            extra,
            reactions,
            requirements,
        }
    }
}

#[derive(Debug, Clone)]
struct Reaction {
    ingredients: Vec<Chemical>,
    output: Chemical,
}

impl Reaction {
    fn new(line: &str) -> Self {
        let parts = line.split(" => ").collect::<Vec<&str>>();
        let ingredients = parts[0].split(", ").map(Chemical::new).collect::<Vec<_>>();
        let output = Chemical::new(parts[1]);
        Self {
            ingredients,
            output,
        }
    }

    fn id(&self) -> String {
        self.output.id.clone()
    }

    fn quantity(&self) -> i64 {
        self.output.quantity
    }

    fn ingredients(&self, demand: &i64, supply: &i64) -> (Vec<Chemical>, i64) {
        let required = demand - supply;
        let quantity = self.quantity();
        let quo = required.div_euclid(quantity);
        let rem = required.rem_euclid(quantity);
        let (multiplier, extra) = if rem == 0 {
            (quo, rem)
        } else {
            (quo + 1, quantity - rem)
        };
        let chemicals = self
            .ingredients
            .iter()
            .map(|chemical| chemical.scale(multiplier))
            .collect::<Vec<_>>();
        (chemicals, extra)
    }
}

#[derive(Debug, Clone, Eq, PartialEq, Hash)]
struct Chemical {
    id: String,
    quantity: i64,
}

impl Chemical {
    fn new(s: &str) -> Self {
        let parts = s.split(" ").collect::<Vec<&str>>();
        let id = parts[1].to_string();
        let quantity = parts[0].parse::<i64>().unwrap();
        Self { id, quantity }
    }

    fn scale(&self, multiplier: i64) -> Self {
        Self {
            id: self.id.clone(),
            quantity: self.quantity * multiplier,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input1() -> Input {
        Input::from(
            "10 ORE => 10 A\n\
            1 ORE => 1 B\n\
            7 A, 1 B => 1 C\n\
            7 A, 1 C => 1 D\n\
            7 A, 1 D => 1 E\n\
            7 A, 1 E => 1 FUEL",
        )
    }

    fn input2() -> Input {
        Input::from(
            "9 ORE => 2 A\n\
            8 ORE => 3 B\n\
            7 ORE => 5 C\n\
            3 A, 4 B => 1 AB\n\
            5 B, 7 C => 1 BC\n\
            4 C, 1 A => 1 CA\n\
            2 AB, 3 BC, 4 CA => 1 FUEL",
        )
    }

    fn input3() -> Input {
        Input::from(
            "157 ORE => 5 NZVS\n\
            165 ORE => 6 DCFZ\n\
            44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL\n\
            12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ\n\
            179 ORE => 7 PSHF\n\
            177 ORE => 5 HKGWZ\n\
            7 DCFZ, 7 PSHF => 2 XJWVT\n\
            165 ORE => 2 GPVTF\n\
            3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT",
        )
    }

    fn input4() -> Input {
        Input::from(
            "2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG\n\
            17 NVRVD, 3 JNWZP => 8 VPVL\n\
            53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL\n\
            22 VJHF, 37 MNCFX => 5 FWMGM\n\
            139 ORE => 4 NVRVD\n\
            144 ORE => 7 JNWZP\n\
            5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC\n\
            5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV\n\
            145 ORE => 6 MNCFX\n\
            1 NVRVD => 8 CXFTF\n\
            1 VJHF, 6 MNCFX => 4 RFSQX\n\
            176 ORE => 6 VJHF",
        )
    }

    fn input5() -> Input {
        Input::from(
            "171 ORE => 8 CNZTR\n\
            7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL\n\
            114 ORE => 4 BHXH\n\
            14 VRPVC => 6 BMBT\n\
            6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL\n\
            6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT\n\
            15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW\n\
            13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW\n\
            5 BMBT => 4 WPTQ\n\
            189 ORE => 9 KTJDG\n\
            1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP\n\
            12 VRPVC, 27 CNZTR => 2 XDBXC\n\
            15 KTJDG, 12 BHXH => 5 XCVML\n\
            3 BHXH, 2 VRPVC => 7 MZWV\n\
            121 ORE => 7 VRPVC\n\
            7 XCVML => 6 RJRHP\n\
            5 BHXH, 4 VRPVC => 5 LTCX",
        )
    }

    #[test]
    fn test_part_one_1() {
        assert_eq!(part_one(&input1()), 31);
    }

    #[test]
    fn test_part_one_2() {
        assert_eq!(part_one(&input2()), 165);
    }

    #[test]
    fn test_part_one_3() {
        assert_eq!(part_one(&input3()), 13312);
    }

    #[test]
    fn test_part_one_4() {
        assert_eq!(part_one(&input4()), 180697);
    }

    #[test]
    fn test_part_one_5() {
        assert_eq!(part_one(&input5()), 2210736);
    }

    #[test]
    fn test_part_two_3() {
        assert_eq!(part_two(&input3()), 82892753);
    }

    #[test]
    fn test_part_two_4() {
        assert_eq!(part_two(&input4()), 5586022);
    }

    #[test]
    fn test_part_two_5() {
        assert_eq!(part_two(&input5()), 460664);
    }

    #[test]
    fn test_resolve() {
        let fuel = 82892753;
        let req = resolve(&input3(), fuel);
        assert!(req < TRILLION);
        let req = resolve(&input3(), fuel + 1);
        assert!(req > TRILLION);
    }
}
