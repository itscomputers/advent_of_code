import gleam/dict.{type Dict}
import gleam/function
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string
import gleam/string_tree

pub opaque type Graph(a) {
  Graph(lookup: Dict(a, Dict(a, Int)), incoming: Dict(a, Set(a)))
}

pub fn new() -> Graph(a) {
  Graph(dict.new(), dict.new())
}

pub fn vertices(graph: Graph(a)) -> List(a) {
  graph.lookup |> dict.keys
}

pub fn edges(graph: Graph(a)) -> List(#(a, a)) {
  graph.lookup
  |> dict.fold(from: [], with: fn(acc, vertex, neighbors) {
    neighbors
    |> dict.fold(from: acc, with: fn(acc, neighbor, _weight) {
      [#(vertex, neighbor), ..acc]
    })
  })
}

pub fn size(graph: Graph(a)) -> Int {
  graph.lookup |> dict.size
}

pub fn subgraph(graph: Graph(a), vertices: List(a)) -> Graph(a) {
  Graph(lookup: graph.lookup |> dict.take(vertices), incoming: dict.new())
  |> set_incoming
}

pub fn from_string(str: String, sep separator: String) -> Graph(String) {
  str
  |> string.split("\n")
  |> list.map(string.split(_, separator))
  |> list.map(fn(vertices) {
    case vertices {
      [source, target] -> #(source, target)
      _ -> #("", "")
    }
  })
  |> list.filter(fn(tuple) { tuple != #("", "") })
  |> from_list
}

pub fn from_list(edges: List(#(a, a))) -> Graph(a) {
  edges
  |> list.fold(from: new(), with: fn(graph, edge) {
    graph |> add(edge.0, edge.1)
  })
}

pub fn to_string(graph: Graph(a)) -> String {
  graph
  |> edges
  |> list.fold(from: string_tree.from_string("{\n"), with: fn(acc, edge) {
    acc
    |> string_tree.append("  ")
    |> string_tree.append(string.inspect(edge.0))
    |> string_tree.append(" -> ")
    |> string_tree.append(string.inspect(edge.1))
    |> string_tree.append("\n")
  })
  |> string_tree.append("}")
  |> string_tree.to_string
}

pub fn display(graph: Graph(a)) -> Graph(a) {
  graph |> to_string |> io.println
  graph
}

pub fn from_weighted_list(edges: List(#(a, a, Int))) -> Graph(a) {
  edges
  |> list.fold(from: new(), with: fn(graph, edge) {
    graph |> add_weighted(edge.0, edge.1, edge.2)
  })
}

pub fn add(graph: Graph(a), from source: a, to target: a) -> Graph(a) {
  graph |> add_weighted(source, target, 1)
}

pub fn add_weighted(
  graph: Graph(a),
  from source: a,
  to target: a,
  weight weight: Int,
) -> Graph(a) {
  let lookup =
    graph.lookup
    |> dict.insert(
      source,
      graph
        |> function.tap(get(_, target))
        |> get(source)
        |> dict.insert(target, weight),
    )
  let incoming =
    graph.incoming
    |> dict.insert(
      target,
      graph
        |> function.tap(get_incoming(_, source))
        |> get_incoming(target)
        |> set.insert(source),
    )
  Graph(lookup:, incoming:)
}

pub fn remove(graph: Graph(a), from source: a, to target: a) -> Graph(a) {
  case graph.lookup |> dict.get(source) {
    Ok(edges) -> {
      let edges = edges |> dict.delete(target)
      let lookup = graph.lookup |> dict.insert(source, edges)
      let incoming =
        graph.incoming
        |> dict.insert(
          target,
          graph
            |> get_incoming(target)
            |> set.delete(source),
        )
      Graph(lookup:, incoming:)
    }
    Error(_) -> graph
  }
}

pub fn replace(graph: Graph(a), vertex: a, with replacement: a) -> Graph(a) {
  let graph =
    graph
    |> neighbors(of: vertex)
    |> list.fold(from: graph, with: fn(acc, neighbor) {
      acc
      |> remove(vertex, neighbor)
      |> add(replacement, neighbor)
    })
  graph
  |> incoming(to: vertex)
  |> list.fold(from: graph, with: fn(acc, prev) {
    acc
    |> remove(prev, vertex)
    |> add(prev, replacement)
  })
}

pub fn neighbors(graph: Graph(a), of vertex: a) -> List(a) {
  graph |> get(vertex) |> dict.keys
}

pub fn incoming(graph: Graph(a), to vertex: a) -> List(a) {
  graph |> get_incoming(vertex) |> set.to_list
}

pub fn adjacent(graph: Graph(a), from source: a, to target: a) -> Bool {
  graph |> weight(source, target) != -1
}

pub fn weight(graph: Graph(a), from source: a, to target: a) -> Int {
  case graph |> get(source) |> dict.get(target) {
    Ok(weight) -> weight
    Error(_) -> -1
  }
}

fn get(graph: Graph(a), vertex: a) -> Dict(a, Int) {
  case graph.lookup |> dict.get(vertex) {
    Ok(dct) -> dct
    Error(_) -> dict.new()
  }
}

fn get_incoming(graph: Graph(a), vertex: a) -> Set(a) {
  case graph.incoming |> dict.get(vertex) {
    Ok(s) -> s
    Error(_) -> set.new()
  }
}

fn set_incoming(graph: Graph(a)) -> Graph(a) {
  let incoming =
    graph.lookup
    |> dict.fold(from: dict.new(), with: fn(acc, source, edges) {
      edges
      |> dict.fold(from: acc, with: fn(acc, target, _) {
        let incoming_edges =
          case acc |> dict.get(target) {
            Ok(incoming_edges) -> incoming_edges
            Error(_) -> set.new()
          }
          |> set.insert(source)
        acc |> dict.insert(target, incoming_edges)
      })
    })
  Graph(..graph, incoming:)
}
