import gleam/bool
import gleam/hexpm
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/result
import gleam/string
import gleam/uri
import hexdocs_search/data/model/autocomplete.{type Autocomplete}
import hexdocs_search/services/hexdocs
import lustre/effect

pub type Model {
  Model(
    packages: List(String),
    search: String,
    search_input: String,
    displayed: String,
    search_focused: Bool,
    autocomplete: Option(Autocomplete),
    package_versions: Option(hexpm.Package),
    dom_click_unsubscriber: Option(fn() -> Nil),
    search_result: Option(#(Int, List(hexdocs.TypeSense))),
    route: Route,
    packages_filter: List(String),
    packages_filter_input: String,
  )
}

pub type Route {
  Home
  Search
  NotFound
}

pub fn new() -> Model {
  Model(
    packages: [],
    search: "",
    search_input: "",
    displayed: "",
    search_focused: False,
    autocomplete: None,
    package_versions: None,
    dom_click_unsubscriber: None,
    search_result: None,
    route: Home,
    packages_filter: [],
    packages_filter_input: "",
  )
}

pub fn add_packages(model: Model, packages: List(String)) {
  Model(..model, packages:)
}

pub fn set_packages_filter(model: Model, packages_filter: List(String)) {
  Model(..model, packages_filter:)
}

pub fn update_search(model: Model, search: String) {
  Model(..model, search:, displayed: search)
  |> autocomplete_packages
}

pub fn focus_search(model: Model) {
  Model(..model, search_focused: True)
  |> autocomplete_packages
}

pub fn select_package(model: Model, package: String) {
  let content = replace_last_word(model.displayed, package)
  Model(..model, search: content, displayed: content, autocomplete: None)
}

pub fn set_packages_filter_input(model: Model, packages_filter_input: String) {
  Model(..model, packages_filter_input:)
}

pub fn set_search_results(
  model: Model,
  search_result: #(Int, List(hexdocs.TypeSense)),
) -> Model {
  let search_result = Some(search_result)
  Model(..model, search_result:)
}

pub fn update_route(model: Model, location: uri.Uri) {
  Model(..model, route: {
    case uri.path_segments(location.path) {
      [] -> Home
      ["search"] -> Search
      _ -> NotFound
    }
  })
}

pub fn blur_search(model: Model) {
  Model(
    ..model,
    search_focused: False,
    autocomplete: None,
    search: model.displayed,
    dom_click_unsubscriber: None,
  )
  |> pair.new({
    use _ <- effect.from()
    let none = fn() { Nil }
    let unsubscriber = option.unwrap(model.dom_click_unsubscriber, none)
    unsubscriber()
  })
}

pub fn autocomplete_packages(model: Model) {
  case should_trigger_autocomplete(model.search) |> echo {
    Error(_) -> Model(..model, autocomplete: None)
    Ok(search) -> {
      let autocomplete = autocomplete.init(model.packages, search)
      Model(..model, autocomplete: Some(autocomplete))
    }
  }
}

pub fn select_next_package(model: Model) -> Model {
  let autocomplete = option.map(model.autocomplete, autocomplete.next)
  Model(..model, autocomplete:)
  |> update_displayed
}

pub fn select_previous_package(model: Model) -> Model {
  let autocomplete = option.map(model.autocomplete, autocomplete.previous)
  Model(..model, autocomplete:)
  |> update_displayed
}

fn update_displayed(model: Model) {
  model.autocomplete
  |> option.then(autocomplete.current)
  |> option.map(replace_last_word(model.displayed, _))
  |> option.map(fn(displayed) { Model(..model, displayed:) })
  |> option.unwrap(Model(..model, displayed: model.search))
}

fn replace_last_word(content, word) {
  let parts = string.split(content, on: " ")
  let length = list.length(parts)
  parts
  |> list.take(length - 1)
  |> list.append(["#" <> word])
  |> string.join(with: " ")
}

fn should_trigger_autocomplete(search: String) {
  let no_search = string.is_empty(search) || string.ends_with(search, " ")
  use <- bool.guard(when: no_search, return: Error(Nil))
  search
  |> string.split(on: " ")
  |> list.last
  |> result.then(fn(search) {
    let length = string.length(search)
    case string.starts_with(search, "#") {
      True -> Ok(string.slice(from: search, at_index: 1, length:))
      False -> Error(Nil)
    }
  })
}
