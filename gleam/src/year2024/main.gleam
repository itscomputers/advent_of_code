import args.{type Part}
import util
import year2024/day01
import year2024/day02
import year2024/day03
import year2024/day04
import year2024/day05
import year2024/day06
import year2024/day07

pub fn get_func(day: String) -> fn(String, Part) -> String {
  case day {
    "01" -> day01.main
    "02" -> day02.main
    "03" -> day03.main
    "04" -> day04.main
    "05" -> day05.main
    "06" -> day06.main
    "07" -> day07.main
    _ -> {
      util.debug("2024 " <> day, "unimplemented")
      fn(_, _) { "" }
    }
  }
}
