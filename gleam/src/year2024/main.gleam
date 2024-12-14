import args.{type Part}
import util
import year2024/day01
import year2024/day02
import year2024/day03
import year2024/day04
import year2024/day05
import year2024/day06
import year2024/day07
import year2024/day08
import year2024/day09
import year2024/day10
import year2024/day11
import year2024/day12
import year2024/day13

pub fn get_func(day: String) -> fn(String, Part) -> String {
  case day {
    "01" -> day01.main
    "02" -> day02.main
    "03" -> day03.main
    "04" -> day04.main
    "05" -> day05.main
    "06" -> day06.main
    "07" -> day07.main
    "08" -> day08.main
    "09" -> day09.main
    "10" -> day10.main
    "11" -> day11.main
    "12" -> day12.main
    "13" -> day13.main
    _ -> {
      util.debug("2024 " <> day, "unimplemented")
      fn(_, _) { "" }
    }
  }
}
