import gleam/bool
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleam/uri.{type Uri}
import modem

pub type Route {
  Home
  Search(q: String, packages: List(#(String, String)))
  NotFound
}

pub fn from_uri(location: Uri) -> Route {
  case uri.path_segments(location.path) {
    [] ->
      {
        use query <- result.try(option.to_result(location.query, Nil))
        use parsed_query <- result.try(uri.parse_query(query))
        use _ <- result.try(list.key_find(parsed_query, "q"))
        Ok(search_from_uri(location))
      }
      |> result.unwrap(Home)

    _ -> NotFound
  }
}

pub fn to_uri(route: Route) -> Uri {
  let assert Ok(uri) = case route {
    Home -> uri.parse("/")
    NotFound -> uri.parse("/")
    Search(q:, packages:) -> {
      use uri <- result.map(uri.parse("/"))
      let query = create_query([#("q", q)], packages)
      let query = uri.query_to_string(query)
      uri.Uri(..uri, query: Some(query))
    }
  }
  uri
}

pub fn push(route: Route) {
  let route = to_uri(route)
  modem.push(route.path, route.query, route.fragment)
}

pub fn replace(route: Route) {
  let route = to_uri(route)
  modem.replace(route.path, route.query, route.fragment)
}

fn create_query(
  query: List(#(String, String)),
  packages: List(#(String, String)),
) -> List(#(String, String)) {
  use <- bool.guard(when: list.is_empty(packages), return: query)
  let packages = list.map(packages, fn(p) { p.0 <> ":" <> p.1 })
  let packages = string.join(packages, with: ",")
  list.append(query, [#("packages", packages)])
}

fn search_from_uri(location: Uri) {
  case location.query {
    None -> Search(q: "", packages: [])
    Some(query) -> {
      case uri.parse_query(query) {
        Error(_) -> Search(q: "", packages: [])
        Ok(query) -> {
          let q = list.key_find(query, "q") |> result.unwrap("")
          Search(q:, packages: {
            list.key_find(query, "packages")
            |> result.unwrap("")
            |> string.split(on: ",")
            |> list.filter_map(fn(package) { string.split_once(package, ":") })
          })
        }
      }
    }
  }
}
