import gleam/bool
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/string
import gleam/uri
import hexdocs_search/data/model/autocomplete.{type Autocomplete}
import hexdocs_search/services/hex
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
    package_versions: Option(hex.Package),
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
  Model(..model, search: package, displayed: package, autocomplete: None)
}

pub fn set_packages_filter_input(model: Model, packages_filter_input: String) {
  Model(..model, packages_filter_input:)
}

pub fn set_search_results(
  model: Model,
  search_result: #(Int, List(hexdocs.TypeSense)),
) {
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
  let set_packages = fn(p) { Model(..model, autocomplete: p) }
  let no_search = string.is_empty(model.search)
  use <- bool.lazy_guard(when: no_search, return: fn() { set_packages(None) })
  let autocomplete = autocomplete.init(model.packages, model.search)
  set_packages(Some(autocomplete))
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
  |> option.map(fn(displayed) { Model(..model, displayed:) })
  |> option.unwrap(Model(..model, displayed: model.search))
}
