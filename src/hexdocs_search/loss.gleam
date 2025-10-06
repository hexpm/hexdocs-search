import gleam/dynamic/decode
import gleam/fetch

pub type Loss(a) =
  Result(a, HexdocsSearchError)

pub type HexdocsSearchError {
  FetchError(fetch.FetchError)
  DecodeError(List(decode.DecodeError))
}
