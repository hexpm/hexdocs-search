import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/fetch
import gleam/http/request
import gleam/http/response
import gleam/javascript/promise
import gleam/result
import hexdocs_search/endpoints
import hexdocs_search/loss

pub type Package {
  Package(
    name: String,
    versions: List(String),
    retirements: Dict(String, String),
  )
}

pub fn package_versions(name: String) {
  let endpoint = endpoints.package(name)
  let assert Ok(request) = request.from_uri(endpoint)
  fetch.send(request)
  |> promise.try_await(fetch.read_json_body)
  |> promise.map(result.map_error(_, loss.FetchError))
  |> promise.try_await(fn(res) {
    decode.list(decode.at(["version"], decode.string))
    |> decode.at(["releases"], _)
    |> decode.run(res.body, _)
    |> result.then(fn(versions) {
      decode.dict(decode.string, decode.at(["messages"], decode.string))
      |> decode.at(["retirements"], _)
      |> decode.run(res.body, _)
      |> result.map(fn(retirements) {
        response.Response(..res, body: Package(name:, versions:, retirements:))
      })
    })
    |> result.map_error(loss.DecodeError)
    |> promise.resolve
  })
}
