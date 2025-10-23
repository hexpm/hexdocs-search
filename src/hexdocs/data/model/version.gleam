import gleam/option.{type Option, None, Some}
import gleam/regexp

const input_regexp = "^#(\\w+)(:([0-9]+\\.[\\w+.-]+))?"

/// Status of a package version resolution.
pub type Status {
  Loading
  NotFound
  Found(String)
}

/// Represents a package filter with its name, version, and resolution status.
pub type Package {
  Package(name: String, version: String, status: Status)
}

pub fn input_match_package(
  word: String,
) -> Result(#(String, Option(String)), Nil) {
  let regexp = version_search()
  case regexp.scan(regexp, word) {
    [regexp.Match(content: _, submatches:)] -> {
      case submatches {
        [Some(package), _, Some(version), ..] -> Ok(#(package, Some(version)))
        [Some(package)] -> Ok(#(package, None))
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

pub fn to_string(package: Package) {
  let package_name = "#" <> package.name
  package_name <> ":" <> package.version
}

fn version_search() {
  let options = regexp.Options(case_insensitive: False, multi_line: False)
  let assert Ok(regexp) = regexp.compile(input_regexp, with: options)
  regexp
}
