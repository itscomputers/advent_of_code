use crate::solution::Solution;

pub fn solve(part: &str, input: &String) -> Solution {
    let reports = get_reports(&input);
    Solution::build(part, &reports, &part_one, &part_two)
}

fn part_one(reports: &Vec<Vec<isize>>) -> usize {
    reports.iter().filter(is_safe).count()
}

fn part_two(reports: &Vec<Vec<isize>>) -> usize {
    reports.iter().filter(is_almost_safe).count()
}

fn get_reports(input: &String) -> Vec<Vec<isize>> {
    input
        .lines()
        .map(|line| {
            line.split_ascii_whitespace()
                .map(|s| s.parse::<isize>().unwrap())
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>()
}

fn get_diff(report: &Vec<isize>) -> Vec<isize> {
    let negative = report[1] - report[0] < 0;
    report
        .windows(2)
        .map(move |vals| {
            if negative {
                vals[0] - vals[1]
            } else {
                vals[1] - vals[0]
            }
        })
        .collect::<Vec<_>>()
}

fn is_safe(report: &&Vec<isize>) -> bool {
    get_diff(report).iter().all(|d| 0 < *d && *d < 4)
}

fn is_almost_safe(report: &&Vec<isize>) -> bool {
    (0..report.len()).any(|idx| is_safe(&&[&report[..idx], &report[idx + 1..]].concat()))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> String {
        String::from(
            "\
            7 6 4 2 1
            1 2 7 8 9
            9 7 6 2 1
            1 3 2 4 5
            8 6 4 4 1
            1 3 6 7 9",
        )
    }

    fn reports() -> Vec<Vec<isize>> {
        get_reports(&input())
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&reports()), 2);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&reports()), 4);
    }
}
