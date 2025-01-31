import gleam/function
import gleam/io
import gleam/javascript/promise
import hexdocs_search/data/msg
import hexdocs_search/services/hexdocs
import lustre/effect

pub fn get_packages() {
  use dispatch <- effect.from()
  use _ <- function.tap(Nil)
  use response <- promise.map(hexdocs.get_packages())
  dispatch(msg.ApiReturnedPackages(response))
}
