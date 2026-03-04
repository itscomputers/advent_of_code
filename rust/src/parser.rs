use std::str::FromStr;

pub fn int_vec<I>(s: &str, separator: &str) -> Vec<I>
where
    I: FromStr,
    <I as FromStr>::Err: std::fmt::Debug,
{
    if separator.is_empty() {
        s.trim()
            .chars()
            .map(|ch| ch.to_string().parse::<I>().unwrap())
            .collect::<Vec<I>>()
    } else {
        s.trim()
            .split(separator)
            .map(|x| x.parse::<I>().unwrap())
            .collect::<Vec<I>>()
    }
}

pub fn match_indices(s: &str, target: char) -> Vec<usize> {
    s.char_indices()
        .filter(|(_, ch)| *ch == target)
        .map(|(index, _)| index)
        .collect::<Vec<_>>()
}
