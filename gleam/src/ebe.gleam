import gleam/int

pub fn mod(number: Int, modulus: Int) -> Int {
  let rem = number % modulus
  case rem < 0 {
    True -> rem + int.absolute_value(modulus)
    False -> rem
  }
}
