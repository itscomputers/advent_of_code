import args.{type Part}
import util
import year2023/day01
import year2023/day02
import year2023/day22
import year2023/day23
import year2023/day24
import year2023/day25

pub fn get_func(day: String) -> fn(String, Part) -> String {
  case day {
    "01" -> day01.main
    "02" -> day02.main
    "22" -> day22.main
    "23" -> day23.main
    "24" -> day24.main
    "25" -> day25.main
    _ -> {
      util.debug("2023 " <> day, "unimplemented")
      fn(_, _) { "" }
    }
  }
}
