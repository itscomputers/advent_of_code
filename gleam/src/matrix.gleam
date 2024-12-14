import gleam/option.{type Option, None, Some}

import point.{type Point, Point}

pub type Matrix {
  Matrix(a: Int, b: Int, c: Int, d: Int)
}

pub fn from_rows(row1: Point, row2: Point) -> Matrix {
  Matrix(row1.x, row1.y, row2.x, row2.y)
}

pub fn from_cols(col1: Point, col2: Point) -> Matrix {
  Matrix(col1.x, col2.x, col1.y, col2.y)
}

pub fn determinant(matrix: Matrix) -> Int {
  matrix.a * matrix.d - matrix.b * matrix.c
}

pub fn inverse(matrix: Matrix) -> #(Int, Matrix) {
  #(determinant(matrix), Matrix(matrix.d, -matrix.b, -matrix.c, matrix.a))
}

pub fn multiply(matrix: Matrix, point: Point) -> Point {
  Point(
    Point(matrix.a, matrix.b) |> point.dot(point),
    Point(matrix.c, matrix.d) |> point.dot(point),
  )
}

pub fn solution(matrix: Matrix, target: Point) -> Option(Point) {
  case determinant(matrix) {
    0 -> None
    _ -> {
      let #(det, inv) = matrix |> inverse
      let scaled_sol = inv |> multiply(target)
      case scaled_sol.x % det, scaled_sol.y % det {
        0, 0 -> Point(scaled_sol.x / det, scaled_sol.y / det) |> Some
        _, _ -> None
      }
    }
  }
}
