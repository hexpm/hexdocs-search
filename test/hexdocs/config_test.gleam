import gleam/string
import gleeunit/should
import hexdocs/config

pub fn search_url_returns_non_empty_string_test() {
  let url = config.search_url()
  url
  |> should.not_equal("")

  // Should start with http:// or https://
  { string.starts_with(url, "http://") || string.starts_with(url, "https://") }
  |> should.be_true()
}

pub fn hexdocs_url_returns_non_empty_string_test() {
  let url = config.hexdocs_url()
  url
  |> should.not_equal("")

  // Should start with http:// or https://
  { string.starts_with(url, "http://") || string.starts_with(url, "https://") }
  |> should.be_true()
}

pub fn hexpm_url_returns_non_empty_string_test() {
  let url = config.hexpm_url()
  url
  |> should.not_equal("")

  // Should start with http:// or https://
  { string.starts_with(url, "http://") || string.starts_with(url, "https://") }
  |> should.be_true()
}
