import hexdocs_search/data/model
import hexdocs_search/data/msg
import hexdocs_search/effects
import lustre/effect
import modem

pub fn init(_) {
  let modem = modem.init(msg.DocumentChangedLocation)
  let packages = effects.packages()
  let assert Ok(initial_uri) = modem.initial_uri()
  let model = model.new()
  let #(model, route) = model.update_route(model, initial_uri)
  #(model, effect.batch([packages, modem, route]))
}
