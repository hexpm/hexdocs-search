import gleam/http/response
import gleam/pair
import gleam/result
import gleam/string
import grille_pain
import grille_pain/lustre/toast
import gsv
import hexdocs_search/data/model.{type Model}
import hexdocs_search/data/msg.{type Msg}
import hexdocs_search/effects
import hexdocs_search/error
import lustre
import lustre/effect
import lustre/element/html

const flags = Nil

pub fn main() {
  let assert Ok(_) = grille_pain.simple()
  let init = fn(_) { #(model.new(), effects.get_packages()) }
  lustre.application(init, update, view)
  |> lustre.start("#app", flags)
}

fn update(model: Model, msg: Msg) {
  case msg {
    msg.ApiReturnedPackages(response) -> api_returned_packages(model, response)
  }
}

fn api_returned_packages(
  model: Model,
  response: error.Result(response.Response(String)),
) {
  case response {
    Ok(response.Response(status: 200, body:, ..)) -> {
      gsv.to_dicts(body)
      |> result.map(model.add_packages(model, _))
      |> result.map(pair.new(_, effect.none()))
      |> result.lazy_unwrap(fn() {
        #(model, toast.error("Malformed response from HexDocs"))
      })
    }
    _ -> #(model, toast.error("Server error. Retry later."))
  }
}

fn view(model: Model) {
  html.div([], [
    html.text("muf ?"),
    string.inspect(model.packages)
      |> html.text,
  ])
}
