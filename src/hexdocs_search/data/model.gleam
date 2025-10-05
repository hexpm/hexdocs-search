import gleam/bool
import gleam/dict.{type Dict}
import gleam/hexpm
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/result
import gleam/string
import gleam/uri
import hexdocs_search/data/model/autocomplete.{type Autocomplete}
import hexdocs_search/data/model/route.{type Route}
import hexdocs_search/data/model/version
import hexdocs_search/effects
import hexdocs_search/services/hexdocs
import lustre/effect

pub type Model {
  Model(
    packages: List(String),
    search: String,
    search_input: String,
    displayed: String,
    search_focused: Bool,
    autocomplete: Option(#(Type, Autocomplete)),
    package_versions: Dict(String, hexpm.Package),
    dom_click_unsubscriber: Option(fn() -> Nil),
    search_result: Option(#(Int, List(hexdocs.TypeSense))),
    route: Route,
    packages_filter: List(#(String, Option(String))),
    packages_filter_input: String,
    packages_filter_version_input: String,
    opened_previews: Dict(String, Bool),
  )
}

/// Autocomplete can be used with Package or Version
pub type Type {
  Package
  Version
}

pub fn new() -> Model {
  Model(
    packages: [],
    search: "",
    search_input: "",
    displayed: "",
    search_focused: False,
    autocomplete: None,
    package_versions: dict.new(),
    dom_click_unsubscriber: None,
    search_result: None,
    route: route.Home,
    packages_filter: [],
    packages_filter_input: "",
    packages_filter_version_input: "",
    opened_previews: dict.new(),
  )
}

pub fn add_packages(model: Model, packages: List(String)) {
  Model(..model, packages:)
}

pub fn update_search(model: Model, search: String) {
  Model(..model, search:, displayed: search)
  |> autocomplete_packages
  |> autocomplete_versions
}

pub fn focus_search(model: Model) {
  Model(..model, search_focused: True)
  |> autocomplete_packages
  |> autocomplete_versions
}

pub fn update_route(model: Model, route: uri.Uri) {
  let route = route.from_uri(route)
  let model = Model(..model, route:)
  case route {
    route.Home | route.NotFound -> #(model, effect.none())
    route.Search(q:, packages:) -> {
      Model(..model, search_input: q, packages_filter: packages)
      |> pair.new(effects.typesense_search(q, packages))
    }
  }
}

pub fn select_autocomplete_option(model: Model, package: String) {
  case model.autocomplete {
    None -> model
    Some(#(type_, _autocomplete)) -> {
      let displayed = replace_last_word(model.displayed, package, type_)
      Model(..model, search: displayed, displayed:, autocomplete: None)
    }
  }
}

pub fn compute_typesense_input(model: Model) -> Model {
  let segments = string.split(model.displayed, on: " ")
  let packages_filter = list.filter_map(segments, version.match_package)
  Model(..model, packages_filter:, search_input: {
    segments
    |> list.filter(fn(s) { version.match_package(s) |> result.is_error })
    |> string.join(with: " ")
  })
}

pub fn set_search_results(
  model: Model,
  search_result: #(Int, List(hexdocs.TypeSense)),
) -> Model {
  let search_result = Some(search_result)
  Model(..model, search_result:)
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
  case should_trigger_autocomplete_packages(model.search) {
    Error(_) -> Model(..model, autocomplete: None)
    Ok(search) -> {
      let autocomplete = autocomplete.init(model.packages, search)
      let autocomplete = #(Package, autocomplete)
      Model(..model, autocomplete: Some(autocomplete))
    }
  }
}

pub fn autocomplete_versions(model: Model) {
  case should_trigger_autocomplete_versions(model.search) {
    Error(_) -> #(model, effect.none())
    Ok(#(package, version)) -> {
      case dict.get(model.package_versions, package) {
        Error(_) -> #(model, effects.package_versions(package))
        Ok(package) -> {
          let versions = list.map(package.releases, fn(r) { r.version })
          let autocomplete = autocomplete.init(versions, version)
          let autocomplete = #(Version, autocomplete)
          let model = Model(..model, autocomplete: Some(autocomplete))
          #(model, effect.none())
        }
      }
    }
  }
}

pub fn select_next_package(model: Model) -> Model {
  map_autocomplete(model, autocomplete.next)
}

pub fn select_previous_package(model: Model) -> Model {
  map_autocomplete(model, autocomplete.previous)
}

fn map_autocomplete(model: Model, mapper: fn(Autocomplete) -> Autocomplete) {
  case model.autocomplete {
    None -> model
    Some(#(type_, autocomplete)) -> {
      let autocomplete = mapper(autocomplete)
      let autocomplete = #(type_, autocomplete)
      let model = Model(..model, autocomplete: Some(autocomplete))
      update_displayed(model)
    }
  }
}

fn update_displayed(model: Model) {
  case model.autocomplete {
    None -> Model(..model, displayed: model.search)
    Some(#(type_, autocomplete)) -> {
      case autocomplete.current(autocomplete) {
        None -> Model(..model, displayed: model.search)
        Some(current) -> {
          let displayed = replace_last_word(model.displayed, current, type_)
          Model(..model, displayed:)
        }
      }
    }
  }
}

fn replace_last_word(content: String, word: String, type_: Type) {
  case type_ {
    Package -> {
      let parts = string.split(content, on: " ")
      let length = list.length(parts)
      parts
      |> list.take(length - 1)
      |> list.append(["#" <> word])
      |> string.join(with: " ")
    }
    Version -> {
      let parts = string.split(content, on: " ")
      let length = list.length(parts)
      let start = list.take(parts, length - 1)
      case list.last(parts) {
        Error(_) -> string.join(parts, with: " ")
        Ok(last_word) -> {
          let segments = string.split(last_word, on: ":")
          let length = list.length(segments)
          list.take(segments, length - 1)
          |> list.append([word])
          |> string.join(with: ":")
          |> list.wrap
          |> list.append(start, _)
          |> string.join(with: " ")
        }
      }
    }
  }
}

fn should_trigger_autocomplete_packages(search: String) {
  let no_search = string.is_empty(search) || string.ends_with(search, " ")
  use <- bool.guard(when: no_search, return: Error(Nil))
  search
  |> string.split(on: " ")
  |> list.last
  |> result.try(fn(search) {
    let length = string.length(search)
    case string.starts_with(search, "#") {
      True -> Ok(string.slice(from: search, at_index: 1, length:))
      False -> Error(Nil)
    }
  })
}

fn should_trigger_autocomplete_versions(search: String) {
  let no_search = string.is_empty(search) || string.ends_with(search, " ")
  use <- bool.guard(when: no_search, return: Error(Nil))
  search
  |> string.split(on: " ")
  |> list.last
  |> result.try(fn(search) {
    let length = string.length(search)
    case string.starts_with(search, "#") {
      False -> Error(Nil)
      True ->
        case string.split(search, on: ":") {
          [word, version] ->
            Ok(#(string.slice(from: word, at_index: 1, length:), version))
          _ -> Error(Nil)
        }
    }
  })
}
