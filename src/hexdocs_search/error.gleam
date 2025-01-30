import gleam
import gleam/fetch

pub type Result(a) =
  gleam.Result(a, HexdocsSearchError)

pub type HexdocsSearchError {
  FetchError(fetch.FetchError)
}
