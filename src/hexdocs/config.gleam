import gleam/string

pub fn search_url() -> String {
  "https://search.hexdocs.pm"
}

pub fn hexdocs_url() -> String {
  "https://hexdocs.pm"
}

pub fn hexdocs_package_host(package: String) -> String {
  // Subdomains can't contain underscores, so package names use dashes.
  string.replace(package, "_", "-") <> ".hexdocs.pm"
}

pub fn hexdocs_package_url(package: String) -> String {
  "https://" <> hexdocs_package_host(package)
}

pub fn hexpm_url() -> String {
  "https://hex.pm"
}

pub fn per_page() -> Int {
  25
}
