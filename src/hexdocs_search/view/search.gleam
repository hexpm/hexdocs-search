import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option}
import hexdocs_search/data/model.{type Model}
import hexdocs_search/data/msg
import hexdocs_search/services/hexdocs
import lustre/attribute.{attribute, class}
import lustre/element
import lustre/element/html
import lustre/event

pub fn search(model: Model) {
  element.fragment([
    html.div(
      [
        class(
          "fixed top-[22px] right-4 z-50 flex-col items-end gap-4 hidden 2xl:flex",
        ),
      ],
      [hexdocs_logo()],
    ),
    html.div([class("flex flex-col md:flex-row")], [
      html.div(
        [
          class(
            "md:hidden flex items-center justify-between p-4 bg-slate-100 dark:bg-slate-800",
          ),
        ],
        [
          html.button([class("p-2"), attribute("onclick", "toggleSidebar()")], [
            html.i(
              [class("ri-menu-line text-xl text-slate-700 dark:text-slate-300")],
              [],
            ),
          ]),
          hexdocs_logo(),
          html.button([class("p-2"), attribute("onclick", "toggleDarkMode()")], [
            html.i(
              [class("theme-icon text-xl text-slate-700 dark:text-slate-300")],
              [],
            ),
          ]),
        ],
      ),
      html.div(
        [
          class(
            "w-80 h-screen bg-slate-100 dark:bg-slate-800 fixed md:static z-40 -translate-x-full md:translate-x-0 transition-transform duration-300 ease-in-out",
          ),
          attribute.id("sidebar"),
        ],
        [
          html.div([class("p-5")], [
            html.div([class("flex justify-between items-center mt-2")], [
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
                  attribute("onclick", "toggleSidebar()"),
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
            html.form([event.on_submit(msg.UserSubmittedPackagesFilter)], [
              html.div([class("mt-4 flex gap-2")], [
                html.div(
                  [
                    class(
                      "flex-grow bg-slate-100 dark:bg-slate-700 rounded-lg border border-slate-300 dark:border-slate-600 relative",
                    ),
                  ],
                  [
                    html.input([
                      class(
                        "search-input w-full h-10 bg-transparent px-10 text-slate-800 dark:text-slate-200 text-sm focus:outline-none focus:ring-1 focus:ring-blue-500",
                      ),
                      attribute.placeholder("Package Name"),
                      attribute.type_("text"),
                      attribute.value(model.packages_filter_input),
                      event.on_input(msg.UserEditedPackagesFilterInput),
                    ]),
                    html.i(
                      [
                        class(
                          "ri-search-2-line absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-500 dark:text-slate-400 text-lg",
                        ),
                      ],
                      [],
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
                    html.input([
                      class(
                        "search-input w-full h-10 bg-transparent px-2 text-slate-800 dark:text-slate-200 text-sm focus:outline-none focus:ring-1 focus:ring-blue-500",
                      ),
                      attribute.placeholder("ver"),
                      attribute.type_("text"),
                      attribute.value(model.packages_filter_version_input),
                      event.on_input(msg.UserEditedPackagesFilterVersion),
                    ]),
                  ],
                ),
              ]),
              html.div([class("mt-4 flex gap-2")], [
                html.button(
                  [
                    attribute.type_("submit"),
                    class(
                      "flex-grow bg-blue-600 hover:bg-blue-700 text-slate-100 rounded-lg h-10 flex items-center justify-center transition duration-200",
                    ),
                  ],
                  [
                    html.span([class("text-sm font-medium")], [
                      html.text("+ Add Package"),
                    ]),
                  ],
                ),
                html.button(
                  [
                    class(
                      "w-10 h-10 bg-slate-100 dark:bg-slate-700 rounded-lg border border-slate-300 dark:border-slate-600 flex items-center justify-center",
                    ),
                  ],
                  [
                    html.i(
                      [
                        class(
                          "ri-share-forward-line text-slate-500 dark:text-slate-400 text-lg",
                        ),
                      ],
                      [],
                    ),
                  ],
                ),
              ]),
            ]),
            html.hr([class("mt-6 border-slate-200 dark:border-slate-700")]),
            element.fragment({
              list.map(model.packages_filter, fn(filter) {
                html.div([class("flex justify-between items-center mt-4")], [
                  html.div(
                    [class("inline-flex flex-col justify-start items-start")],
                    [
                      html.div(
                        [
                          class(
                            "self-stretch justify-start text-gray-950 dark:text-slate-50 text-lg font-semibold leading-none",
                          ),
                        ],
                        [html.text(filter.0)],
                      ),
                      html.div(
                        [
                          class(
                            "self-stretch justify-start text-slate-700 dark:text-slate-400 text-sm font-normal leading-none",
                          ),
                        ],
                        [html.text(filter.1 |> option.unwrap("latest"))],
                      ),
                    ],
                  ),
                  trash_button(filter),
                ])
              })
            }),
          ]),
        ],
      ),
      html.div([class("flex-1 md:ml-0 mt-0 md:mt-0")], [
        html.div([class("p-5 flex flex-col items-center")], [
          html.div([class("w-full max-w-[800px] flex items-center gap-3")], [
            html.div([class("relative flex-1")], [
              html.input([
                attribute.value(model.search_input),
                event.on_input(msg.UserEditedSearchInput),
                event.on("keydown", fn(event) {
                  case decode.run(event, decode.at(["key"], decode.string)) {
                    Error(_) -> Error([])
                    Ok("Enter") -> Ok(msg.UserSubmittedSearchInput)
                    Ok(_) -> Error([])
                  }
                }),
                attribute.placeholder("Search for packages..."),
                class(
                  "search-input w-full h-10 bg-indigo-50 dark:bg-slate-800 rounded-lg border border-blue-500 dark:border-blue-600 pl-10 pr-4 text-slate-950 dark:text-slate-50 focus:outline-none focus:ring-1 focus:ring-blue-500",
                ),
                attribute.type_("text"),
              ]),
              html.i(
                [
                  class(
                    "ri-search-2-line absolute left-4 top-1/2 transform -translate-y-1/2 text-slate-950 dark:text-slate-400",
                  ),
                ],
                [],
              ),
            ]),
            html.i(
              [
                class(
                  "ri-settings-4-line text-xl text-slate-700 dark:text-slate-300",
                ),
              ],
              [],
            ),
            html.button(
              [
                class("p-2 hidden md:flex"),
                attribute("onclick", "toggleDarkMode()"),
              ],
              [
                html.i(
                  [
                    class(
                      "theme-icon text-xl text-slate-700 dark:text-slate-300",
                    ),
                  ],
                  [],
                ),
              ],
            ),
          ]),
        ]),
        html.div([class("px-5 flex flex-col items-center")], [
          html.div([class("space-y-6 w-full max-w-[800px]")], {
            let results = option.unwrap(model.search_result, #(0, []))
            use result <- list.map(results.1)
            result_card(result)
          }),
        ]),
      ]),
    ]),
  ])
}

fn hexdocs_logo() {
  html.a([class("flex items-center gap-2"), attribute.href("/")], [
    html.img([
      class("w-auto h-10"),
      attribute.alt("HexDocs Logo"),
      attribute.src("/priv/images/hexdocs-logo.svg"),
    ]),
    html.div([class("flex items-center")], [
      html.span(
        [
          class(
            "text-slate-950 dark:text-slate-50 text-lg font-bold font-calibri",
          ),
        ],
        [html.text("hex")],
      ),
      html.span(
        [class("text-slate-950 dark:text-slate-50 text-lg font-calibri")],
        [html.text("docs")],
      ),
    ]),
  ])
}

fn trash_button(filter: #(String, Option(String))) {
  html.div(
    [
      class("w-5 h-5 relative overflow-hidden cursor-pointer"),
      event.on_click(msg.UserDeletedPackagesFilter(filter)),
    ],
    [
      html.i(
        [class("ri-delete-bin-5-fill text-slate-400 dark:text-slate-500")],
        [],
      ),
    ],
  )
}

fn result_card(result: hexdocs.TypeSense) {
  html.div([class("w-full bg-slate-100 dark:bg-slate-800 rounded-2xl p-4")], [
    html.div([class("text-slate-700 dark:text-slate-300 text-sm")], [
      html.text(result.document.package),
    ]),
    html.h3(
      [
        class(
          "text-slate-950 dark:text-slate-50 text-xl font-semibold leading-loose mt-1",
        ),
      ],
      [html.text(result.document.title)],
    ),
    html.div(
      [
        class(
          "mt-2 inline-flex px-3 py-0.5 bg-slate-300 dark:bg-slate-700 rounded-full",
        ),
      ],
      [
        html.span([class("text-blue-600 dark:text-blue-400 text-sm")], [
          html.text(result.document.ref),
        ]),
      ],
    ),
    case result.highlight {
      hexdocs.Highlights(doc: option.Some(doc), ..) -> {
        html.p(
          [
            class(
              "mt-4 text-slate-800 dark:text-slate-300 leading-normal line-clamp-2 overflow-hidden",
            ),
            attribute.attribute("dangerous-unescaped-html", doc.snippet),
          ],
          [
            // html.text("Channels are a really good abstraction"),
          // html.span(
          //   [class("bg-slate-950 text-slate-100 px-1 rounded")],
          //   [html.text("for")],
          // ),
          // html.text(
          //   "real-time communication. They are bi-directional and persistent connections between the browser and server...",
          // ),
          ],
        )
      }
      _ -> element.none()
    },
    html.div([class("mt-4 flex flex-wrap gap-3")], [
      html.button(
        [
          class(
            "h-10 px-4 py-2.5 bg-slate-100 dark:bg-slate-700 rounded-lg border border-slate-300 dark:border-slate-600 flex items-center justify-center",
          ),
        ],
        [
          html.span(
            [class("text-slate-800 dark:text-slate-200 text-sm font-semibold")],
            [html.text("Show Preview")],
          ),
          html.i(
            [
              class(
                "ri-arrow-down-s-line ml-2 text-slate-500 dark:text-slate-400",
              ),
            ],
            [],
          ),
        ],
      ),
      html.button(
        [
          class(
            "h-10 px-4 py-2.5 bg-slate-100 dark:bg-slate-700 rounded-lg border border-slate-300 dark:border-slate-600 flex items-center justify-center",
          ),
        ],
        [
          html.span(
            [class("text-slate-800 dark:text-slate-200 text-sm font-semibold")],
            [html.text("Go to Page")],
          ),
          html.i(
            [
              class(
                "ri-external-link-line ml-2 text-slate-500 dark:text-slate-400",
              ),
            ],
            [],
          ),
        ],
      ),
    ]),
  ])
}
