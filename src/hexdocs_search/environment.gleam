import envoy
import gleam/result
import gleam/string

pub type Environment {
  Development
  Staging
  Production
}

/// Read `GLEAM_ENV` environment variable to detect the global environment.
/// `GLEAM_ENV` should be `"production"`, `"staging"` or `"development"`. In case
/// `GLEAM_ENV` is missing, it fallback automatically on `Production` to avoid
/// potential leaking of critical data.
pub fn read() {
  let value = envoy.get("GLEAM_ENV") |> result.map(string.lowercase)
  case value {
    Ok("development") -> Development
    Ok("staging") -> Staging
    _ -> Production
  }
}
