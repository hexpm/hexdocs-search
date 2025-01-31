import gleam/bool
import gleam/dynamic/decode
import gleam/http/response.{type Response}
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
import gleam/string
import grille_pain
import grille_pain/lustre/toast
import hexdocs_search/data/model.{type Model, Model}
import hexdocs_search/data/model/autocomplete
import hexdocs_search/data/msg.{type Msg}
import hexdocs_search/effects
import hexdocs_search/error
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event

const flags = Nil

pub fn main() {
  let assert Ok(_) = grille_pain.simple()
  let init = fn(_) { #(model.new(), effects.get_packages()) }
  lustre.application(init, update, view)
  |> lustre.start("#app", flags)
}

fn update(model: Model, msg: Msg) {
  case msg {
    msg.ApiReturnedPackages(response:) -> api_returned_packages(model, response)
    msg.UserBlurredSearch -> #(model.blur_search(model), effect.none())
    msg.UserEditedSearch(search:) ->
      model.update_search(model, search)
      |> pair.new(effect.none())
    msg.UserFocusedSearch -> #(model.focus_search(model), effect.none())
    msg.UserNextAutocompletePackageSelected ->
      model.select_next_package(model)
      |> pair.new(effect.none())
    msg.UserPreviousAutocompletePackageSelected ->
      model.select_previous_package(model)
      |> pair.new(effect.none())
  }
}

fn api_returned_packages(model: Model, response: error.Result(Response(String))) {
  case response {
    Ok(response.Response(status: 200, body:, ..)) -> {
      body
      |> string.split(on: "\n")
      |> model.add_packages(model, _)
      |> pair.new(effect.none())
    }
    _ -> #(model, toast.error("Server error. Retry later."))
  }
}

fn view(model: Model) {
  html.div([], [
    html.text("Hexdocs"),
    html.input([
      attribute.value(model.displayed),
      event.on_input(msg.UserEditedSearch),
      event.on_focus(msg.UserFocusedSearch),
      event.on_blur(msg.UserBlurredSearch),
      event.on("keydown", fn(event) {
        let key_decoder = decode.at(["key"], decode.string)
        let key = decode.run(event, key_decoder) |> result.replace_error([])
        use key <- result.try(key)
        case list.contains(["ArrowDown", "ArrowUp"], key) {
          True -> event.prevent_default(event)
          False -> Nil
        }
        case key {
          "ArrowDown" -> Ok(msg.UserNextAutocompletePackageSelected)
          "ArrowUp" -> Ok(msg.UserPreviousAutocompletePackageSelected)
          _ -> Error([])
        }
      }),
    ]),
    autocomplete(model),
  ])
}

fn autocomplete(model: Model) {
  let no_search = string.is_empty(model.search)
  let no_completion = option.is_none(model.autocomplete)
  use <- bool.lazy_guard(when: !model.search_focused, return: element.none)
  use <- bool.lazy_guard(when: no_search, return: element.none)
  use <- bool.lazy_guard(when: no_completion, return: empty_autocomplete)
  html.div([], [
    html.text("Autocomplete"),
    html.div([attribute.style([#("border", "1px solid grey")])], {
      case model.autocomplete {
        None -> [element.none()]
        Some(autocomplete) -> {
          use package <- list.map(autocomplete.all(autocomplete))
          let selected = case autocomplete.selected(autocomplete, package) {
            True -> attribute.style([#("background", "red")])
            False -> attribute.none()
          }
          html.div([selected], [html.text(package)])
        }
      }
    }),
  ])
}

fn empty_autocomplete() {
  html.div([], [
    html.text("Autocomplete"),
    html.div([], [html.text("No packages found!")]),
  ])
}
