import gleam/uri.{type Uri}
import hexdocs/config

pub fn search() -> Uri {
  let assert Ok(uri) = uri.parse(config.search_url())
  uri
}

pub fn packages() -> Uri {
  let assert Ok(uri) =
    uri.parse(config.hexdocs_url() <> "/package_names.csv")
  uri
}

pub fn package(package: String) -> Uri {
  let assert Ok(uri) =
    uri.parse(config.hexpm_url() <> "/api/packages/" <> package)
  uri
}
