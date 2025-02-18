import gleam/pair
import hexdocs_search/data/model
import hexdocs_search/data/msg
import hexdocs_search/effects
import lustre/effect
import modem

pub fn init(_) {
  let modem = modem.init(msg.DocumentChangedLocation)
  let packages = effects.packages()
  let assert Ok(initial_uri) = modem.initial_uri()
  model.new()
  |> model.update_route(initial_uri)
  |> pair.new(effect.batch([packages, modem]))
}
