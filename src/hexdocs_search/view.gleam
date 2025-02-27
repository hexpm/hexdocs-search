import gleam/bool
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import hexdocs_search/data/model.{type Model}
import hexdocs_search/data/model/autocomplete
import hexdocs_search/data/msg
import hexdocs_search/services/hexdocs
import hexdocs_search/utils
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event

pub fn view(model: Model) {
  html.main([attribute.class("main")], [
    case model.route {
      model.Home -> home(model)
      model.Search -> search(model)
      model.NotFound -> html.div([], [])
    },
  ])
}

fn home(model: Model) {
  let go_back = event.on_click(msg.UserClickedGoBack)
  html.div([attribute.class("home")], [
    html.button([attribute.class("go-back"), go_back], [
      html.text("Go back to Hex"),
    ]),
    html.div([attribute.class("title")], [
      html.span([attribute.class("bold")], [html.text("hex")]),
      html.text("docs"),
    ]),
    html.form(
      [attribute.class("search-form"), event.on_submit(msg.UserSubmittedSearch)],
      [
        html.input([
          attribute.class("search-input"),
          attribute.value(model.displayed),
          attribute.placeholder("Search for packages..."),
          event.on_input(msg.UserEditedSearch),
          event.on("click", utils.stop_propagation),
          event.on_focus(msg.UserFocusedSearch),
          event.on("keydown", on_arrow_up_down),
        ]),
        html.button([attribute.class("search-submit")], [
          html.text("Search Packages"),
        ]),
        autocomplete(model),
        package_versions(model),
      ],
    ),
    html.div([attribute.class("descriptions-text")], [
      html.div([attribute.class("descriptions-title")], [
        html.text("To search specific packages"),
      ]),
      html.div([], [
        html.text("Type '#' to scope your search to one or more packages."),
        html.br([]),
        html.text("Use '#<package:version>' to pick a specific version."),
      ]),
    ]),
    html.div([attribute.class("descriptions-text")], [
      html.div([attribute.class("descriptions-title")], [
        html.text("To access a package documentation"),
      ]),
      html.div([], [
        html.text("Visit hexdocs.pm/<package> or "),
        html.text("hexdocs.pm/<package>/<version>"),
      ]),
    ]),
  ])
}

fn search(model: Model) {
  html.div([attribute.style([#("display", "flex")])], [
    html.div([], [
      html.text("Select packages"),
      html.form([event.on_submit(msg.UserSubmittedPackagesFilter)], [
        html.input([
          attribute.value(model.packages_filter_input),
          event.on_input(msg.UserEditedPackagesFilter),
        ]),
      ]),
      search_filter_pills(model),
    ]),
    html.div([], [
      html.text("Search"),
      html.form([event.on_submit(msg.UserSubmittedSearchInput)], [
        html.input([
          attribute.value(model.search_input),
          event.on_input(msg.UserEditedSearchInput),
        ]),
      ]),
      case model.search_result {
        None -> element.none()
        Some(results) -> search_results(results)
      },
    ]),
  ])
}

fn search_filter_pills(model: Model) {
  html.div([], {
    use filter <- list.map(model.packages_filter)
    html.div([], [
      html.text(filter),
      html.button([event.on_click(msg.UserSuppressedPackagesFilter(filter))], [
        html.text("Remove"),
      ]),
    ])
  })
}

fn search_results(results: #(Int, List(hexdocs.TypeSense))) {
  html.div([], [
    html.text("Results"),
    html.div([], [html.text(int.to_string(results.0) <> " found")]),
    html.div([], {
      use type_sense <- list.map(results.1)
      html.div(
        [
          attribute.style([
            #("border-radius", "10px"),
            #("padding", "10px"),
            #("box-shadow", "0px 0px 0px 3px #eee"),
            #("display", "flex"),
            #("flex-direction", "column"),
            #("gap", "10px"),
          ]),
        ],
        [
          html.div([], [html.text("title: " <> type_sense.document.title)]),
          html.div([], [html.text("type: " <> type_sense.document.type_)]),
          html.div([], [html.text("package: " <> type_sense.document.package)]),
          html.div([], [html.text("proglang: " <> type_sense.document.proglang)]),
          html.div([], [html.text("doc: " <> type_sense.document.doc)]),
          snippet(type_sense.highlight.title),
          snippet(type_sense.highlight.doc),
        ],
      )
    }),
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
    "ArrowDown" -> Ok(msg.UserSelectedNextAutocompletePackage)
    "ArrowUp" -> Ok(msg.UserSelectedPreviousAutocompletePackage)
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
          let on_click = on_select_package(package)
          html.div([selected, on_click], [html.text(package)])
        }
      }
    }),
  ])
}

fn on_select_package(package: String) {
  use event <- event.on("click")
  event.stop_propagation(event)
  Ok(msg.UserSelectedAutocompletePackage(package))
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

fn snippet(snippet: option.Option(hexdocs.Highlight)) {
  case snippet {
    None -> element.none()
    Some(t) -> {
      let snippet = attribute.attribute("dangerous-unescaped-html", t.snippet)
      html.div([snippet], [])
    }
  }
}
