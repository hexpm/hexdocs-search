import gleam/bool
import gleam/dynamic/decode
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import hexdocs_search/data/model.{type Model}
import hexdocs_search/data/model/autocomplete
import hexdocs_search/data/msg
import hexdocs_search/utils
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event

pub fn view(model: Model) {
  html.div([], [
    html.text("Hexdocs"),
    html.input([
      attribute.value(model.displayed),
      event.on_input(msg.UserEditedSearch),
      event.on("click", utils.stop_propagation),
      event.on_focus(msg.UserFocusedSearch),
      event.on("keydown", on_arrow_up_down),
    ]),
    autocomplete(model),
    package_versions(model),
  ])
}

fn on_arrow_up_down(event: decode.Dynamic) {
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
          let on_click =
            event.on("click", fn(event) {
              event.stop_propagation(event)
              Ok(msg.UserSelectedAutocompletePackage(package))
            })
          html.div([selected, on_click], [html.text(package)])
        }
      }
    }),
  ])
}

fn package_versions(model: Model) {
  case model.package_versions {
    None -> element.none()
    Some(package) -> {
      html.div([], [
        html.text("Package versions"),
        html.div([], {
          use version <- list.map(package.versions)
          html.div([], [html.text(version)])
        }),
      ])
    }
  }
}

fn empty_autocomplete() {
  html.div([], [
    html.text("Autocomplete"),
    html.div([], [html.text("No packages found!")]),
  ])
}
