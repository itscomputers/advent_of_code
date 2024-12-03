import args.{type Part}
import util
import year2024/day01
import year2024/day02

pub fn get_func(day: String) -> fn(String, Part) -> String {
  case day {
    "01" -> day01.main
    "02" -> day02.main
    _ -> {
      util.debug("2024 " <> day, "unimplemented")
      fn(_, _) { "" }
    }
  }
}
