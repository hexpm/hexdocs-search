import gleam/http/response
import hexdocs_search/error

pub type Msg {
  ApiReturnedPackages(error.Result(response.Response(String)))
}
