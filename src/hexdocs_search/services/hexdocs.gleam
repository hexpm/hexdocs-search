import gleam/fetch
import gleam/http/request
import gleam/javascript/promise
import gleam/result
import hexdocs_search/endpoints
import hexdocs_search/error

pub fn get_packages() {
  let endpoint = endpoints.packages()
  let assert Ok(request) = request.from_uri(endpoint)
  let response = fetch.send(request) |> promise.try_await(fetch.read_text_body)
  use response <- promise.await(response)
  response
  |> result.map_error(error.FetchError)
  |> promise.resolve
}
