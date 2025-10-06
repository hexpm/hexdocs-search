import browser/document
import gleam/function
import gleam/javascript/promise
import hexdocs_search/data/msg
import hexdocs_search/services/hex
import hexdocs_search/services/hexdocs
import lustre/effect

pub fn packages() {
  use dispatch <- effect.from()
  use _ <- function.tap(Nil)
  use response <- promise.map(hexdocs.packages())
  dispatch(msg.ApiReturnedPackages(response))
}

pub fn package_versions(package: String) {
  use dispatch <- effect.from()
  use _ <- function.tap(Nil)
  use response <- promise.map(hex.package_versions(package))
  dispatch(msg.ApiReturnedPackageVersions(package:, response:))
}

pub fn subscribe_blurred_search() {
  use dispatch <- effect.from()
  document.add_listener(fn() { dispatch(msg.UserBlurredSearch) })
  |> msg.DocumentRegisteredEventListener
  |> dispatch
}

pub fn typesense_search(query: String, packages: List(#(String, String))) {
  use dispatch <- effect.from()
  use _ <- function.tap(Nil)
  use response <- promise.map(hexdocs.typesense_search(query, packages, 1))
  dispatch(msg.ApiReturnedTypesenseSearch(response))
}
