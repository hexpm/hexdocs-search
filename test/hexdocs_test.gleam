import gleeunit
import gleeunit/should
import hexdocs/config

pub fn main() {
  gleeunit.main()
}

pub fn hexdocs_package_version_url_with_version_test() {
  config.hexdocs_package_version_url("phoenix", "1.7.0")
  |> should.equal("https://phoenix.hexdocs.pm/1.7.0")
}

pub fn hexdocs_package_version_url_without_version_test() {
  config.hexdocs_package_version_url("mix", "")
  |> should.equal("https://mix.hexdocs.pm")
}

pub fn hexdocs_package_version_url_replaces_underscores_test() {
  config.hexdocs_package_version_url("ex_unit", "")
  |> should.equal("https://ex-unit.hexdocs.pm")
}
