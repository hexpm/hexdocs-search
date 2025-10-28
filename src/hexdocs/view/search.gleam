import gleam/bool

import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

import hexdocs/config
import hexdocs/data/model.{type Model}
import hexdocs/data/model/autocomplete
import hexdocs/data/model/version
import hexdocs/data/msg

import hexdocs/services/hexdocs
import hexdocs/view/components
import lustre/attribute.{class}
import lustre/element
import lustre/element/html
import lustre/event

pub fn search(model: Model) {
  element.fragment([
    html.div(
      [
        class(
          "fixed top-[22px] right-4 z-50 flex-col items-end gap-4 hidden 2xl:flex dark:text-white",
        ),
      ],
      [hexdocs_logo()],
    ),
    html.div([class("bg-white dark:bg-gray-900 flex flex-col md:flex-row")], [
      html.div(
        [
          class(
            "md:hidden flex items-center justify-between p-4 bg-slate-100 dark:bg-slate-800",
          ),
        ],
        [
          html.button(
            [
              class("p-2"),
              event.on_click(msg.UserToggledSidebar),
            ],
            [
              html.i(
                [
                  class(
                    "ri-menu-line text-xl text-slate-700 dark:text-slate-300",
                  ),
                ],
                [],
              ),
            ],
          ),
          hexdocs_logo(),
        ],
      ),
      html.div(
        [
          class(
            "w-80 min-h-screen bg-slate-100 dark:bg-slate-800 fixed md:static z-40 -translate-x-full md:translate-x-0 transition-transform duration-300 ease-in-out top-0",
          ),
          class(case model.sidebar_opened {
            True -> "translate-x-0"
            False -> "-translate-x-full"
          }),
          event.on_click(msg.None) |> event.stop_propagation,
          attribute.id("sidebar"),
        ],
        [
          html.div([class("px-5 py-4.5 md:py-5.5")], [
            html.div([class("flex justify-between items-center")], [
              html.h2(
                [
                  class(
                    "text-slate-950 dark:text-slate-50 text-lg font-medium leading-7",
                  ),
                ],
                [html.text("Selected Packages")],
              ),
              html.button(
                [
                  class("md:hidden p-2"),
                  event.on_click(msg.UserToggledSidebar),
                ],
                [
                  html.i(
                    [
                      class(
                        "ri-close-line text-xl text-slate-700 dark:text-slate-300",
                      ),
                    ],
                    [],
                  ),
                ],
              ),
            ]),
            html.form(
              [event.on_submit(fn(_) { msg.UserSubmittedPackagesFilter })],
              [
                html.div(
                  [class("mt-4 flex gap-2 text-slate-700 dark:text-slate-300")],
                  [
                    html.div(
                      [
                        class(
                          "grow bg-slate-100 dark:bg-slate-700 rounded-lg border border-slate-300 dark:border-slate-600 relative",
                        ),
                      ],
                      [
                        html.input(
                          list.flatten([
                            [
                              attribute.id("search-package-input"),
                              attribute.autocapitalize("off"),
                              attribute.autocomplete("off"),
                              attribute.placeholder("Package Name"),
                              attribute.type_("text"),
                              attribute.value(
                                model.search_packages_filter_input_displayed,
                              ),
                              event.on_input(msg.UserEditedPackagesFilterInput),
                              event.on_focus(msg.UserFocusedPackagesFilterInput),
                              event.on_click(msg.None) |> event.stop_propagation,
                              event.advanced(
                                "keydown",
                                on_arrow_up_down(model.Package),
                              ),
                            ],
                            components.input_classes(),
                            [
                              class("h-10 px-2 text-sm"),
                            ],
                          ]),
                        ),
                        autocomplete(
                          model,
                          model.Package,
                          model.AutocompleteOnPackage,
                          "min-w-70",
                        ),
                      ],
                    ),
                    html.div(
                      [
                        class(
                          "w-20 bg-slate-100 dark:bg-slate-700 rounded-lg border border-slate-300 dark:border-slate-600 relative",
                        ),
                      ],
                      [
                        html.input(
                          list.flatten([
                            [
                              attribute.id("search-version-input"),
                              attribute.autocapitalize("off"),
                              attribute.autocomplete("off"),
                              attribute.placeholder("Version"),
                              attribute.type_("text"),
                              attribute.value(
                                model.search_packages_filter_version_input_displayed,
                              ),
                              attribute.disabled(
                                !list.contains(
                                  model.packages,
                                  model.search_packages_filter_input_displayed,
                                ),
                              ),
                              event.on_input(
                                msg.UserEditedPackagesFilterVersion,
                              ),
                              event.on_focus(
                                msg.UserFocusedPackagesFilterVersion,
                              ),
                              event.on_click(msg.None) |> event.stop_propagation,
                              event.advanced(
                                "keydown",
                                on_arrow_up_down(model.Version),
                              ),
                            ],
                            components.input_classes(),
                            [
                              class("h-10 px-2 text-sm"),
                              class("disabled:opacity-[0.7]"),
                            ],
                          ]),
                        ),
                        autocomplete(
                          model,
                          model.Version,
                          model.AutocompleteOnVersion,
                          "min-w-[120px]",
                        ),
                      ],
                    ),
                  ],
                ),
                html.div([class("mt-4 flex gap-2")], [
                  html.button(
                    [
                      attribute.type_("submit"),
                      class(
                        "grow bg-blue-600 cursor-pointer hover:bg-blue-700 text-slate-100 rounded-lg h-10 flex items-center justify-center transition duration-200",
                      ),
                    ],
                    [
                      html.span([class("text-sm font-medium")], [
                        html.text("+ Add Package"),
                      ]),
                    ],
                  ),
                ]),
              ],
            ),
            html.hr([class("mt-6 border-slate-200 dark:border-slate-700")]),
            case list.is_empty(model.search_packages_filters) {
              True -> {
                html.div([class("text-slate-700 dark:text-slate-300 pt-4")], [
                  html.text(
                    "No package selected, searching all packages and all versions.",
                  ),
                ])
              }
              False -> {
                element.fragment({
                  let sorted_filters =
                    list.sort(model.search_packages_filters, fn(a, b) {
                      string.compare(a.name, b.name)
                    })

                  use filter <- list.map(sorted_filters)
                  html.div([class("flex justify-between items-center mt-4")], [
                    html.div(
                      [
                        class(
                          "inline-flex flex-col justify-start items-start gap-1",
                        ),
                      ],
                      [
                        html.a(
                          [
                            class(
                              "self-stretch justify-start text-gray-950 dark:text-slate-50 text-md font-semibold leading-none",
                            ),
                            attribute.target("_blank"),
                            case filter.status {
                              version.Found(ver) ->
                                attribute.href(
                                  config.hexdocs_url()
                                  <> "/"
                                  <> filter.name
                                  <> "/"
                                  <> ver
                                  <> "/",
                                )
                              _ -> class("")
                            },
                          ],
                          [html.text(filter.name)],
                        ),
                        html.div(
                          [
                            class(
                              "self-stretch justify-start text-slate-700 dark:text-slate-400 text-sm font-normal leading-none",
                            ),
                          ],
                          case filter.status {
                            version.Loading -> [
                              html.text("latest (loading…)"),
                            ]

                            version.NotFound -> [
                              html.text("latest "),
                              html.span([class("text-red-700")], [
                                html.text("(not found)"),
                              ]),
                            ]
                            version.Found(ver) ->
                              case filter.version {
                                "latest" -> [
                                  html.text("latest (" <> ver <> ")"),
                                ]
                                _ -> [html.text(ver)]
                              }
                          },
                        ),
                      ],
                    ),
                    trash_button(filter),
                  ])
                })
              }
            },
          ]),
        ],
      ),
      html.div([class("px-5 my-4 flex-1")], [
        html.div([class("flex flex-col items-center")], [
          html.div([class("w-full max-w-[800px] flex items-center gap-3")], [
            html.div([class("relative flex-1")], [
              html.input(
                list.flatten([
                  [
                    attribute.autofocus(True),
                    attribute.value(model.search_input),
                    event.on_input(msg.UserEditedSearchInput),
                    event.on("keydown", {
                      use key <- decode.field("key", decode.string)
                      case key {
                        "Enter" -> decode.success(msg.UserSubmittedSearchInput)
                        _ -> decode.failure(msg.UserSubmittedSearchInput, "Key")
                      }
                    }),
                    attribute.placeholder("Search documentation..."),
                    attribute.type_("text"),
                  ],
                  components.input_classes(),
                  [class("h-10 pl-10 pr-4")],
                ]),
              ),
              html.i(
                [
                  class(
                    "ri-search-2-line absolute left-4 top-1/2 transform -translate-y-1/2 text-slate-950 dark:text-slate-400",
                  ),
                ],
                [],
              ),
            ]),
            components.dark_mode_toggle(model),
          ]),
        ]),
        html.div([class("flex flex-col mx-auto max-w-[800px]")], {
          let #(count, results) = option.unwrap(model.search_result, #(-1, []))

          case count == -1 {
            True -> []
            False -> {
              [
                html.div(
                  [
                    class("py-4 text-slate-700 dark:text-slate-300"),
                    class("flex flex-row justify-between"),
                  ],
                  [
                    html.div([], [
                      case count <= config.per_page() {
                        True -> "Found "
                        False ->
                          "Showing first "
                          <> int.to_string(config.per_page())
                          <> " out of "
                      }
                      |> string.append(int.to_string(count))
                      |> string.append(" results")
                      |> html.text(),
                    ]),
                    html.div([class("text-sm")], [
                      html.text("Search powered by "),
                      html.a(
                        [
                          class("text-blue-600 cursor-pointer"),
                          attribute.href("https://typesense.org"),
                        ],
                        [
                          html.text("Typesense"),
                        ],
                      ),
                    ]),
                  ],
                ),
                html.div([class("space-y-6")], {
                  list.map(results, result_card(model, _))
                }),
              ]
            }
          }
        }),
      ]),
    ]),
  ])
}

fn on_arrow_up_down(type_: model.Type) {
  use key <- decode.field("key", decode.string)
  let message = case key, type_ {
    "ArrowDown", _ -> Ok(msg.UserSelectedNextAutocompletePackage)
    "ArrowUp", _ -> Ok(msg.UserSelectedPreviousAutocompletePackage)
    "Enter", model.Package -> Ok(msg.UserSelectedPackageFilter)
    "Enter", model.Version -> Ok(msg.UserSelectedPackageFilterVersion)
    // Error case, giving anything to please the decode failure.
    _, _ -> Error(msg.None)
  }
  case message {
    Ok(msg) ->
      event.handler(msg, stop_propagation: False, prevent_default: True)
    Error(msg) ->
      event.handler(msg, stop_propagation: False, prevent_default: False)
  }
  |> decode.success
}

fn autocomplete(
  model: Model,
  type_: model.Type,
  opened: model.AutocompleteFocused,
  class_name: String,
) -> element.Element(msg.Msg) {
  let no_search = case type_ {
    model.Package -> string.is_empty(model.search_packages_filter_input)
    model.Version -> False
  }
  let no_autocomplete = option.is_none(model.autocomplete)
  use <- bool.lazy_guard(
    when: model.autocomplete_search_focused != opened,
    return: element.none,
  )
  use <- bool.lazy_guard(when: no_search, return: element.none)
  use <- bool.lazy_guard(when: no_autocomplete, return: element.none)
  html.div(
    [
      class(
        "absolute z-10 top-14 w-full bg-white dark:bg-gray-800 shadow-md rounded-lg overflow-hidden",
      ),
      class(class_name),
    ],
    [
      case model.autocomplete {
        None -> element.none()
        Some(#(_type_, autocomplete)) -> {
          let items = autocomplete.all(autocomplete)
          let is_empty = list.is_empty(items)
          use <- bool.lazy_guard(when: is_empty, return: empty_autocomplete)
          html.div([], {
            use package <- list.map(items)
            let is_selected = autocomplete.is_selected(autocomplete, package)
            let selected = case is_selected {
              True -> class("bg-stone-100 dark:bg-stone-600")
              False -> attribute.none()
            }
            let on_click = on_select_package(package)
            html.div(
              [
                class(
                  "py-2 px-4 text-md hover:bg-stone-200 dark:hover:bg-stone-800 cursor-pointer",
                ),
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
  html.div([attribute.class("py-2 px-4 text-md text-red-700")], [
    html.text("No packages found"),
  ])
}

fn on_select_package(package: String) {
  msg.UserClickedAutocompletePackage(package)
  |> event.on_click
  |> event.stop_propagation
}

fn hexdocs_logo() {
  html.a([class("flex items-center gap-2"), attribute.href("/")], [
    html.img([
      class("w-auto h-6"),
      attribute.alt("HexDocs Logo"),
      attribute.src("/images/hexdocs-logo.svg"),
    ]),
    html.div([class("flex items-center")], [
      html.span(
        [
          class("text-slate-950 dark:text-white text-lg font-bold"),
        ],
        [html.text("hex")],
      ),
      html.span(
        [
          class("text-slate-950 dark:text-white text-lg"),
        ],
        [html.text("docs")],
      ),
    ]),
  ])
}

fn trash_button(filter: version.Package) {
  let on_delete = event.on_click(msg.UserDeletedPackagesFilter(filter))
  html.div(
    [
      class("h-5 hover:brightness-90 relative overflow-hidden cursor-pointer"),
      on_delete,
    ],
    [
      sidebar_icon("ri-delete-bin-5-fill"),
    ],
  )
}

fn result_card(model: Model, document: hexdocs.Document) {
  let display_url =
    "/" <> string.replace(document.package, "-", "/") <> "/" <> document.ref
  let link_url = config.hexdocs_url() <> display_url

  html.div([class("w-full bg-slate-100 dark:bg-slate-800 rounded-2xl p-4")], [
    html.a(
      [
        attribute.href(link_url),
        class(
          "text-green-700 dark:text-green-400 text-sm hover:underline break-all",
        ),
      ],
      [html.text(display_url)],
    ),
    html.a(
      [
        attribute.href(link_url),
        class(
          "text-blue-700 dark:text-blue-300 text-xl font-normal leading-tight mt-1 hover:underline block",
        ),
      ],
      [html.text(document.title)],
    ),
    element.unsafe_raw_html(
      "",
      "p",
      [class("text-slate-800 dark:text-slate-300 leading-normal mt-2")],
      hexdocs.snippet(document.doc, model.search_input),
    ),
    case list.is_empty(document.headers) {
      True -> element.none()
      False ->
        html.div([class("mt-4 space-y-3")], [
          html.h4(
            [class("text-slate-600 dark:text-slate-400 text-sm font-medium")],
            [html.text("Related sections:")],
          ),
          html.ul([class("space-y-1")], {
            list.map(document.headers, fn(header: hexdocs.Header) {
              let header_display_url =
                "/"
                <> string.replace(document.package, "-", "/")
                <> "/"
                <> header.ref
              let header_link_url = config.hexdocs_url() <> header_display_url

              html.li(
                [
                  class(
                    "list-disc list-inside text-slate-400 dark:text-slate-500",
                  ),
                ],
                [
                  html.a(
                    [
                      attribute.href(header_link_url),
                      class(
                        "text-blue-600 dark:text-blue-400 text-sm hover:underline",
                      ),
                    ],
                    [html.text(header.title)],
                  ),
                ],
              )
            })
          }),
        ])
    },
  ])
}

fn sidebar_icon(icon: String) {
  let icon = class(icon)
  let default = class("text-slate-400 dark:text-slate-500")
  html.i([icon, default], [])
}
