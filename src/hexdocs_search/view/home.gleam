import gleam/bool
import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import hexdocs_search/data/model.{type Model}
import hexdocs_search/data/model/autocomplete
import hexdocs_search/data/msg
import hexdocs_search/services/hexdocs
import hexdocs_search/utils
import hexdocs_search/view/home/footer
import lustre/attribute.{class, id}
import lustre/element
import lustre/element/html
import lustre/event

pub fn home(model: Model) {
  let go_back = event.on_click(msg.UserClickedGoBack)
  let toggle_mode = event.on_click(msg.UserToggledDarkMode)
  html.div(
    [
      class("flex flex-col"),
      class("min-h-screen max-w-8xl"),
      class("mx-auto"),
      class("bg-white dark:bg-gray-900 dark:text-gray-50"),
      class("transition-colors duration-200"),
      class("px-4 lg:px-0"),
    ],
    [
      html.main([class("flex-grow")], [
        html.section([class("sm:py-8 ly:py-10")], [
          html.div([id("nav"), class("flex justify-between items-center")], [
            html.a(
              [
                attribute.href("#"),
                class("text-sm text-gray-600 dark:text-gray-100 mt-10"),
              ],
              [html.text("← Go back to Hex")],
            ),
            html.button(
              [toggle_mode, class("p-3 text-gray-700 dark:text-gray-100 mt-10")],
              [html.i([class("theme-icon text-xl")], [])],
            ),
          ]),
          html.div([class("flex flex-col justify-around mt-14 lg:mt-40")], [
            html.div(
              [id("logo"), class("flex items-center justify-start gap-6")],
              [
                html.img([
                  attribute.src("/priv/images/hexdocs-logo.svg"),
                  attribute.alt("HexDocs Logo"),
                  class("w-auto h-14 lg:w-auto lg:h-24"),
                ]),
                html.h1(
                  [
                    class(
                      "text-gray-700 dark:text-gray-50 text-5xl lg:text-7xl font-calibri",
                    ),
                  ],
                  [
                    html.span([class("font-semibold")], [html.text("hex")]),
                    html.span([class("font-light")], [html.text("docs")]),
                  ],
                ),
              ],
            ),
            html.form(
              [
                event.on_submit(msg.UserSubmittedSearch),
                id("search"),
                class(
                  "flex flex-col lg:flex-row items-center gap-4 mt-10 lg:mt-20",
                ),
              ],
              [
                html.div([class("relative max-w-lg w-full")], [
                  html.input([
                    attribute.value(model.displayed),
                    event.on_input(msg.UserEditedSearch),
                    event.on("click", utils.stop_propagation),
                    event.on_focus(msg.UserFocusedSearch),
                    event.on("keydown", on_arrow_up_down),
                    attribute.autofocus(True),
                    attribute.type_("text"),
                    class("search-input w-full bg-white dark:bg-gray-800"),
                    class(
                      "rounded-lg border border-gray-200 dark:border-gray-700",
                    ),
                    class(
                      "font-inter placeholder:text-gray-400 dark:placeholder:text-gray-400 text-gray-700 dark:text-gray-100",
                    ),
                    class("px-10 py-3"),
                    class(
                      "focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent",
                    ),
                    attribute.placeholder("Search for packages..."),
                  ]),
                  html.i(
                    [
                      class(
                        "ri-search-2-line absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 text-lg",
                      ),
                    ],
                    [],
                  ),
                  autocomplete(model),
                ]),
                html.button(
                  [
                    class(
                      "px-6 py-3 bg-blue-600 dark:bg-blue-600 text-gray-50 font-inter rounded-lg hover:bg-blue-700 transition duration-200 whitespace-nowrap w-full sm:w-auto",
                    ),
                  ],
                  [html.text("Search Packages")],
                ),
              ],
            ),
            html.div([id("how-to"), class("mt-10 lg:mt-32")], [
              html.div([], [
                html.h6(
                  [
                    class(
                      "text-gray-700 dark:text-gray-100 text-xl font-semibold font-inter leading-loose",
                    ),
                  ],
                  [html.text("To search specific packages")],
                ),
                html.span(
                  [class("text-gray-600 dark:text-gray-200 font-inter")],
                  [html.text("Type ")],
                ),
                html.span(
                  [class("bg-black px-0.5 text-gray-50 font-mono rounded")],
                  [html.text("#")],
                ),
                html.span(
                  [class("text-gray-600 dark:text-gray-200 font-inter")],
                  [
                    html.text(" to scope your search to one or more packages."),
                    html.br([]),
                    html.text("Use "),
                  ],
                ),
                html.span(
                  [class("bg-black px-0.5 text-gray-50 font-mono rounded")],
                  [html.text("#<package>:<version>")],
                ),
                html.span(
                  [class("text-gray-600 dark:text-gray-200 font-inter")],
                  [html.text(" to pick a specific version.")],
                ),
              ]),
              html.div([attribute.class("font-inter mt-10")], [
                html.h6(
                  [
                    attribute.class(
                      "text-gray-700 dark:text-gray-100 text-xl font-semibold leading-loose",
                    ),
                  ],
                  [
                    html.text(
                      "To access a package documentation
                                    ",
                    ),
                  ],
                ),
                html.span(
                  [attribute.class("text-gray-600 dark:text-gray-200")],
                  [html.text("Visit ")],
                ),
                html.span(
                  [
                    attribute.class(
                      "text-blue-600 dark:text-blue-600 font-semibold",
                    ),
                  ],
                  [html.text("hexdocs.pm/")],
                ),
                html.span(
                  [attribute.class("text-gray-600 dark:text-gray-200")],
                  [html.text("<package>")],
                ),
                html.span(
                  [attribute.class("text-gray-600 dark:text-gray-200")],
                  [html.text(" or ")],
                ),
                html.span(
                  [
                    attribute.class(
                      "text-blue-600 dark:text-blue-600 font-semibold",
                    ),
                  ],
                  [html.text("hexdocs.pm/")],
                ),
                html.span(
                  [attribute.class("text-gray-600 dark:text-gray-200")],
                  [html.text("<package>/<version>")],
                ),
              ]),
            ]),
          ]),
        ]),
      ]),
      footer.footer(),
      package_versions(model),
    ],
  )
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
  let no_autocomplete = option.is_none(model.autocomplete)
  use <- bool.lazy_guard(when: !model.search_focused, return: element.none)
  use <- bool.lazy_guard(when: no_search, return: element.none)
  use <- bool.lazy_guard(when: no_autocomplete, return: element.none)
  html.div(
    [
      class(
        "absolute top-14 w-full bg-white shadow-md rounded-lg overflow-hidden",
      ),
    ],
    [
      case model.autocomplete {
        None -> element.none()
        Some(autocomplete) -> {
          let items = autocomplete.all(autocomplete)
          let is_empty = list.is_empty(items)
          use <- bool.lazy_guard(when: is_empty, return: empty_autocomplete)
          html.div([], {
            use package <- list.map(items)
            let selected = case autocomplete.selected(autocomplete, package) {
              True -> class("bg-stone-100")
              False -> attribute.none()
            }
            let on_click = on_select_package(package)
            html.div(
              [
                class("py-2 px-4 text-md hover:bg-stone-200 cursor-pointer"),
                selected,
                on_click,
              ],
              [html.text(package)],
            )
          })
        }
      },
    ],
  )
}

fn empty_autocomplete() {
  html.text("No packages found")
}

fn on_select_package(package: String) {
  use event <- event.on("click")
  event.stop_propagation(event)
  Ok(msg.UserClickedAutocompletePackage(package))
}

fn package_versions(model: Model) {
  case model.package_versions {
    None -> element.none()
    Some(package) -> {
      html.div([], [
        html.text("Package versions"),
        html.div([], {
          let versions = list.map(package.releases, fn(r) { r.version })
          use version <- list.map(versions)
          html.div([], [html.text(version)])
        }),
      ])
    }
  }
}
