import gleam/fetch
import gleam/http/request
import gleam/http/response
import gleam/javascript/promise
import gleam/result
import hexdocs_search/endpoints
import hexdocs_search/environment
import hexdocs_search/error

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

pub fn get_packages() {
  case environment.read() {
    environment.Development -> packages_mock()
    environment.Staging | environment.Production -> {
      let endpoint = endpoints.packages()
      let assert Ok(request) = request.from_uri(endpoint)
      let response =
        fetch.send(request) |> promise.try_await(fetch.read_text_body)
      use response <- promise.await(response)
      response
      |> result.map_error(error.FetchError)
      |> promise.resolve
    }
  }
}
