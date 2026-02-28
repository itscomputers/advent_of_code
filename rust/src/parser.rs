pub fn int_vec(s: &str, separator: &str) -> Vec<i32> {
    if separator.is_empty() {
        s.trim()
            .chars()
            .map(|ch| ch.to_digit(10).unwrap() as i32)
            .collect::<Vec<i32>>()
    } else {
        s.trim()
            .split(separator)
            .map(|x| x.parse::<i32>().unwrap())
            .collect::<Vec<i32>>()
    }
}

pub fn i64_vec(s: &str, separator: &str) -> Vec<i64> {
    if separator.is_empty() {
        s.trim()
            .chars()
            .map(|ch| ch.to_digit(10).unwrap() as i64)
            .collect::<Vec<i64>>()
    } else {
        s.trim()
            .split(separator)
            .map(|x| x.parse::<i64>().unwrap())
            .collect::<Vec<i64>>()
    }
}

pub fn match_indices(s: &str, target: char) -> Vec<usize> {
    s.char_indices()
        .filter(|(_, ch)| *ch == target)
        .map(|(index, _)| index)
        .collect::<Vec<_>>()
}
