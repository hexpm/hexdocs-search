import hexdocs_search/data/model
import hexdocs_search/data/msg
import hexdocs_search/effects
import lustre/effect
import modem

pub fn init(_) {
  let modem = modem.init(msg.DocumentChangedLocation)
  let packages = effects.packages()
  let assert Ok(initial_uri) = modem.initial_uri()
  let #(defined, dark_mode) = read_dark_mode()
  let defined = case defined {
    "user" -> msg.User
    "system" -> msg.System
    _ -> panic as "Unrecognized settings"
  }
  let dark_mode = defined(to_dark_mode(dark_mode))
  let model = model.new(dark_mode)
  let #(model, route) = model.update_route(model, initial_uri)
  let watch = watch_theme()
  #(model, effect.batch([packages, modem, route, watch]))
}

fn watch_theme() {
  use dispatch <- effect.from
  use color_mode <- watch_is_dark
  color_mode
  |> to_dark_mode
  |> msg.DocumentChangedTheme
  |> dispatch
}

@external(javascript, "./setup.ffi.mjs", "readDarkMode")
fn read_dark_mode() -> #(String, String)

@external(javascript, "./setup.ffi.mjs", "watchIsDark")
fn watch_is_dark(callback: fn(String) -> Nil) -> Nil

fn to_dark_mode(value: String) -> msg.ColorMode {
  case value {
    "dark" -> msg.Dark
    "light" -> msg.Light
    _ -> panic as "Unrecognized color mode"
  }
}
