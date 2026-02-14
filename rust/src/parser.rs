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
