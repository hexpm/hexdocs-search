import gleam/bool
import gleam/dynamic/decode
import gleam/fetch
import gleam/http/request
import gleam/int
import gleam/javascript/promise
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string
import gleam/uri
import hexdocs/config
import hexdocs/endpoints
import hexdocs/loss

pub type Document {
  Document(
    doc: String,
    id: String,
    package: String,
    proglang: String,
    ref: String,
    title: String,
    type_: String,
  )
}

pub fn packages() {
  let endpoint = endpoints.packages()
  let assert Ok(request) = request.from_uri(endpoint)
  fetch.send(request)
  |> promise.try_await(fetch.read_text_body)
  |> promise.map(result.map_error(_, loss.FetchError))
}

pub fn typesense_search(
  query: String,
  packages: List(#(String, String)),
  page: Int,
) {
  let query = new_search_query_params(query, packages, page)
  let endpoint = uri.Uri(..endpoints.search(), query: Some(query))
  let assert Ok(request) = request.from_uri(endpoint)
  fetch.send(request)
  |> promise.try_await(fetch.read_json_body)
  |> promise.map(result.map_error(_, loss.FetchError))
}

pub fn typesense_decoder() {
  use found <- decode.field("found", decode.int)
  use hits <- decode.field("hits", {
    decode.list({
      use document <- decode.field("document", {
        use doc <- decode.field("doc", decode.string)
        use id <- decode.field("id", decode.string)
        use package <- decode.field("package", decode.string)
        use proglang <- decode.field("proglang", decode.string)
        use ref <- decode.field("ref", decode.string)
        use title <- decode.field("title", decode.string)
        use type_ <- decode.field("type", decode.string)
        Document(doc:, id:, package:, proglang:, ref:, title:, type_:)
        |> decode.success
      })
      decode.success(document)
    })
  })
  decode.success(#(found, hits))
}

fn new_search_query_params(
  query: String,
  packages: List(#(String, String)),
  page: Int,
) {
  list.new()
  |> list.key_set("q", query)
  |> list.key_set("query_by", "title,doc,type")
  |> list.key_set("query_by_weights", "3,1,1")
  |> list.key_set("page", int.to_string(page))
  |> list.key_set("per_page", int.to_string(config.per_page()))
  |> list.key_set("highlight_fields", "none")
  |> add_filter_by_packages_param(packages)
  |> uri.query_to_string
}

fn add_filter_by_packages_param(
  query: List(#(String, String)),
  packages: List(#(String, String)),
) -> List(#(String, String)) {
  use <- bool.guard(when: list.is_empty(packages), return: query)
  packages
  |> list.map(fn(p) { p.0 <> "-" <> p.1 })
  |> list.map(string.append("package:=", _))
  |> string.join("||")
  |> list.key_set(query, "filter_by", _)
}

pub fn snippet(doc: String, search_input: String) -> String {
  // Extract first paragraph
  let first_paragraph = case string.split(doc, on: "\r\n\r\n") {
    [single] ->
      case string.split(single, on: "\n\n") {
        [first, ..] -> first
        [] -> doc
      }
    [first, ..] -> first
    [] -> doc
  }

  // Truncate to reasonable length (around 200 characters)
  let truncated = case string.length(first_paragraph) > 200 {
    True -> string.slice(first_paragraph, 0, 200) <> "..."
    False -> first_paragraph
  }

  // Highlight search terms
  case string.trim(search_input) {
    "" -> truncated
    search_term ->
      string.replace(
        truncated,
        search_term,
        "<strong>" <> search_term <> "</strong>",
      )
  }
}
