import gleam/dynamic/decode
import gleam/fetch
import gleam/hexpm
import gleam/http/request
import gleam/http/response
import gleam/javascript/promise
import gleam/result
import hexdocs/endpoints
import hexdocs/loss

pub fn package_versions(name: String) {
  let endpoint = endpoints.package(name)
  let assert Ok(request) = request.from_uri(endpoint)
  fetch.send(request)
  |> promise.try_await(fetch.read_json_body)
  |> promise.map(result.map_error(_, loss.FetchError))
  |> promise.map_try(fn(res) {
    decode.run(res.body, hexpm.package_decoder())
    |> result.map_error(loss.DecodeError)
    |> result.map(response.set_body(res, _))
  })
}
