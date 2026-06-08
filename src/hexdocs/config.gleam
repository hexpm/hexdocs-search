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

/// Documentation URL for a package at a specific version. When the version is
/// empty the version segment is omitted, linking to the latest documentation.
pub fn hexdocs_package_version_url(package: String, version: String) -> String {
  case version {
    "" -> hexdocs_package_url(package)
    _ -> hexdocs_package_url(package) <> "/" <> version
  }
}

pub fn hexpm_url() -> String {
  "https://hex.pm"
}

pub fn per_page() -> Int {
  25
}
