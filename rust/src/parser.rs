pub fn int_vec(string: &str, separator: &str) -> Vec<isize> {
    string
        .trim()
        .split(separator)
        .map(|x| x.parse::<isize>().unwrap())
        .collect::<Vec<_>>()
}
