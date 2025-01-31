import gleam/dynamic/decode
import gleam/fetch
import gleam/function
import gleam/http/request
import gleam/http/response
import gleam/int
import gleam/javascript/promise
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/uri
import hexdocs_search/endpoints
import hexdocs_search/environment
import hexdocs_search/error

pub type TypeSense {
  TypeSense(document: Document, highlight: Highlights)
}

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

pub type Highlights {
  Highlights(doc: Option(Highlight), title: Option(Highlight))
}

pub type Highlight {
  Highlight(matched_tokens: List(String), snippet: String)
}

fn packages_mock() {
  response.new(200)
  |> response.set_body({
    "jason
jose
joseph
telemetry
ranch
mime
ssl_verify_fun
parse_trans
certifi
mimerl
"
  })
  |> Ok
  |> promise.resolve
}

pub fn packages() {
  case environment.read() {
    environment.Development -> packages_mock()
    environment.Staging | environment.Production -> {
      let endpoint = endpoints.packages()
      let assert Ok(request) = request.from_uri(endpoint)
      fetch.send(request)
      |> promise.try_await(fetch.read_text_body)
      |> promise.map(result.map_error(_, error.FetchError))
    }
  }
}

pub fn typesense_search(query: String, packages: List(String), page: Int) {
  let query =
    []
    |> list.key_set("q", query)
    |> list.key_set("query_by", "title,doc")
    |> list.key_set("page", int.to_string(page))
    |> case packages {
      [] -> function.identity
      packages -> {
        let packages = "package:" <> string.join(packages, with: ",")
        list.key_set(_, "filter_by", packages)
      }
    }
    |> uri.query_to_string
  let endpoint = uri.Uri(..endpoints.search(), query: Some(query))
  let assert Ok(request) = request.from_uri(endpoint)
  fetch.send(request)
  |> promise.try_await(fetch.read_json_body)
  |> promise.map(result.map_error(_, error.FetchError))
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
      use highlight <- decode.field("highlight", {
        use doc <- decode.optional_field("doc", None, {
          use matched_tokens <- decode.field(
            "matched_tokens",
            decode.list(decode.string),
          )
          use snippet <- decode.field("snippet", decode.string)
          Some(Highlight(matched_tokens:, snippet:))
          |> decode.success
        })
        use title <- decode.optional_field("title", None, {
          use matched_tokens <- decode.field(
            "matched_tokens",
            decode.list(decode.string),
          )
          use snippet <- decode.field("snippet", decode.string)
          Some(Highlight(matched_tokens:, snippet:))
          |> decode.success
        })
        decode.success(Highlights(doc:, title:))
      })
      decode.success(TypeSense(document:, highlight:))
    })
  })
  decode.success(#(found, hits))
}
