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
    headers: List(Header),
  )
}

pub type Header {
  Header(ref: String, title: String)
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
        Document(
          doc:,
          id:,
          package:,
          proglang:,
          ref:,
          title:,
          type_:,
          headers: [],
        )
        |> decode.success
      })
      decode.success(document)
    })
  })
  let grouped_results = group_headers(hits)
  let removed_count = list.length(hits) - list.length(grouped_results)
  let max_results = list.take(grouped_results, config.per_page())
  decode.success(#(found - removed_count, max_results))
}

fn group_headers(documents: List(Document)) -> List(Document) {
  // Convert to indexed tuples
  let indexed_docs = list.index_map(documents, fn(doc, index) { #(index, doc) })

  // First pass: separate parents and children with their indexes
  let #(parents, children) =
    list.partition(indexed_docs, fn(indexed_doc) {
      let #(_index, doc) = indexed_doc
      !list.any(indexed_docs, fn(other_indexed) {
        let #(_other_index, other) = other_indexed
        string.starts_with(doc.ref, other.ref <> "-")
        && doc.package == other.package
        && doc.id != other.id
      })
    })

  // Second pass: attach children to parents and compute min index
  let grouped_with_index =
    list.map(parents, fn(parent_indexed) {
      let #(parent_index, parent) = parent_indexed

      let matching_headers =
        list.filter_map(children, fn(child_indexed) {
          let #(_child_index, child) = child_indexed
          case
            string.starts_with(child.ref, parent.ref <> "-")
            && child.package == parent.package
          {
            True -> {
              let cleaned_title =
                string.replace(child.title, " - " <> parent.title, "")
              Ok(#(child_indexed, Header(ref: child.ref, title: cleaned_title)))
            }
            False -> Error(Nil)
          }
        })

      let child_indexes =
        list.map(matching_headers, fn(header_data) {
          let #(#(child_index, _child), _header) = header_data
          child_index
        })

      let min_index = list.fold(child_indexes, parent_index, int.min)
      let headers =
        list.map(matching_headers, fn(header_data) {
          let #(_child_indexed, header) = header_data
          header
        })

      #(min_index, Document(..parent, headers: headers))
    })

  // Sort by index and return documents
  grouped_with_index
  |> list.sort(fn(a, b) {
    let #(index_a, _doc_a) = a
    let #(index_b, _doc_b) = b
    int.compare(index_a, index_b)
  })
  |> list.map(fn(indexed_doc) {
    let #(_index, doc) = indexed_doc
    doc
  })
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
  // We multiply per 2 because we group results
  |> list.key_set("per_page", int.to_string(config.per_page() * 2))
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
  // Extract all paragraphs by splitting on both possible line endings
  let paragraphs =
    doc
    |> string.split(on: "\r\n\r\n")
    |> list.flat_map(string.split(_, on: "\n\n"))

  // Get first usable paragraph (skip if starts with "#")
  let first_paragraph = case paragraphs {
    [first, second, ..] ->
      case string.starts_with(string.trim(first), "#") {
        True -> second
        False -> first
      }
    [first] -> first
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
