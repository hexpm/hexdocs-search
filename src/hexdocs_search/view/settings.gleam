import lustre/attribute.{attribute}
import lustre/element
import lustre/element/html

pub fn settings(_model) {
  element.fragment([
    html.div(
      [
        attribute.class(
          "fixed top-[22px] right-4 z-50 flex-col items-end gap-4 hidden 2xl:flex",
        ),
      ],
      [
        html.div([attribute.class("flex gap-2")], [
          html.img([
            attribute.class("w-auto h-10"),
            attribute.alt("HexDocs Logo"),
            attribute.src("./images/hexdocs-logo.svg"),
          ]),
          html.div([attribute.class("flex items-center")], [
            html.span(
              [
                attribute.class(
                  "text-slate-950 dark:text-slate-50 text-lg font-bold font-calibri",
                ),
              ],
              [html.text("hex")],
            ),
            html.span(
              [
                attribute.class(
                  "text-slate-950 dark:text-slate-50 text-lg font-calibri",
                ),
              ],
              [html.text("docs")],
            ),
          ]),
        ]),
      ],
    ),
    html.div([attribute.class("flex flex-col md:flex-row")], [
      html.div(
        [
          attribute.class(
            "md:hidden flex items-center justify-between p-4 bg-slate-100 dark:bg-slate-800",
          ),
        ],
        [
          html.button(
            [attribute.class("p-2"), attribute("onclick", "toggleSidebar()")],
            [
              html.i(
                [
                  attribute.class(
                    "ri-menu-line text-xl text-slate-700 dark:text-slate-300",
                  ),
                ],
                [],
              ),
            ],
          ),
          html.div([attribute.class("flex items-center gap-2")], [
            html.img([
              attribute.class("w-auto h-8"),
              attribute.alt("HexDocs Logo"),
              attribute.src("./images/hexdocs-logo.svg"),
            ]),
            html.div([attribute.class("flex items-center")], [
              html.span(
                [
                  attribute.class(
                    "text-slate-950 dark:text-slate-50 text-base font-bold font-calibri",
                  ),
                ],
                [html.text("hex")],
              ),
              html.span(
                [
                  attribute.class(
                    "text-slate-950 dark:text-slate-50 text-base font-calibri",
                  ),
                ],
                [html.text("docs")],
              ),
            ]),
          ]),
          html.button(
            [attribute.class("p-2"), attribute("onclick", "toggleDarkMode()")],
            [
              html.i(
                [
                  attribute.class(
                    "theme-icon text-xl text-slate-700 dark:text-slate-300",
                  ),
                ],
                [],
              ),
            ],
          ),
        ],
      ),
      html.div(
        [
          attribute.class(
            "w-80 h-screen bg-slate-100 dark:bg-slate-800 fixed md:static z-40 -translate-x-full md:translate-x-0 transition-transform duration-300 ease-in-out",
          ),
          attribute.id("sidebar"),
        ],
        [
          html.div([attribute.class("p-5")], [
            html.div(
              [attribute.class("flex justify-between items-center mt-2")],
              [
                html.h2(
                  [
                    attribute.class(
                      "text-slate-950 dark:text-slate-50 text-lg font-medium leading-7",
                    ),
                  ],
                  [
                    html.text(
                      "Selected Packages
            ",
                    ),
                  ],
                ),
                html.button(
                  [
                    attribute.class("md:hidden p-2"),
                    attribute("onclick", "toggleSidebar()"),
                  ],
                  [
                    html.i(
                      [
                        attribute.class(
                          "ri-close-line text-xl text-slate-700 dark:text-slate-300",
                        ),
                      ],
                      [],
                    ),
                  ],
                ),
              ],
            ),
            html.div([attribute.class("mt-4 flex gap-2")], [
              html.div(
                [
                  attribute.class(
                    "flex-grow bg-slate-100 dark:bg-slate-700 rounded-lg border border-slate-300 dark:border-slate-600 relative",
                  ),
                ],
                [
                  html.input([
                    attribute.class(
                      "search-input w-full h-10 bg-transparent px-10 text-slate-800 dark:text-slate-200 text-sm focus:outline-none focus:ring-1 focus:ring-blue-500",
                    ),
                    attribute.placeholder("Package Name"),
                    attribute.type_("text"),
                  ]),
                  html.i(
                    [
                      attribute.class(
                        "ri-search-2-line absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-500 dark:text-slate-400 text-lg",
                      ),
                    ],
                    [],
                  ),
                ],
              ),
              html.div(
                [
                  attribute.class(
                    "w-20 bg-slate-100 dark:bg-slate-700 rounded-lg border border-slate-300 dark:border-slate-600 relative",
                  ),
                ],
                [
                  html.input([
                    attribute.class(
                      "search-input w-full h-10 bg-transparent px-2 text-slate-800 dark:text-slate-200 text-sm focus:outline-none focus:ring-1 focus:ring-blue-500",
                    ),
                    attribute.placeholder("ver"),
                    attribute.type_("text"),
                  ]),
                ],
              ),
            ]),
            html.div([attribute.class("mt-4 flex gap-2")], [
              html.button(
                [
                  attribute.class(
                    "flex-grow bg-blue-600 hover:bg-blue-700 text-slate-100 rounded-lg h-10 flex items-center justify-center transition duration-200",
                  ),
                ],
                [
                  html.span([attribute.class("text-sm font-medium")], [
                    html.text("+ Add Package"),
                  ]),
                ],
              ),
              html.button(
                [
                  attribute.class(
                    "w-10 h-10 bg-slate-100 dark:bg-slate-700 rounded-lg border border-slate-300 dark:border-slate-600 flex items-center justify-center",
                  ),
                ],
                [
                  html.i(
                    [
                      attribute.class(
                        "ri-share-forward-line text-slate-500 dark:text-slate-400 text-lg",
                      ),
                    ],
                    [],
                  ),
                ],
              ),
            ]),
            html.hr([
              attribute.class("mt-6 border-slate-200 dark:border-slate-700"),
            ]),
            html.div(
              [attribute.class("flex justify-between items-center mt-4")],
              [
                html.div(
                  [
                    attribute.class(
                      "inline-flex flex-col justify-start items-start",
                    ),
                  ],
                  [
                    html.div(
                      [
                        attribute.class(
                          "self-stretch justify-start text-gray-950 dark:text-slate-50 text-lg font-semibold leading-none",
                        ),
                      ],
                      [
                        html.text(
                          "ecto
              ",
                        ),
                      ],
                    ),
                    html.div(
                      [
                        attribute.class(
                          "self-stretch justify-start text-slate-700 dark:text-slate-400 text-sm font-normal leading-none",
                        ),
                      ],
                      [
                        html.text(
                          "v1.7.0
              ",
                        ),
                      ],
                    ),
                  ],
                ),
                html.div([attribute.class("w-5 h-5 relative overflow-hidden")], [
                  html.i(
                    [
                      attribute.class(
                        "ri-delete-bin-5-fill text-slate-400 dark:text-slate-500",
                      ),
                    ],
                    [],
                  ),
                ]),
              ],
            ),
          ]),
        ],
      ),
      html.div([attribute.class("flex-1 md:ml-0 mt-0 md:mt-0")], [
        html.div([attribute.class("p-5 flex flex-col items-center")], [
          html.div(
            [attribute.class("w-full max-w-[800px] flex items-center gap-3")],
            [
              html.div([attribute.class("relative flex-1")], [
                html.input([
                  attribute.placeholder("Search for packages..."),
                  attribute.class(
                    "search-input w-full h-10 bg-indigo-50 dark:bg-slate-800 rounded-lg border border-blue-500 dark:border-blue-600 pl-10 pr-4 text-slate-950 dark:text-slate-50 focus:outline-none focus:ring-1 focus:ring-blue-500",
                  ),
                  attribute.type_("text"),
                ]),
                html.i(
                  [
                    attribute.class(
                      "ri-search-2-line absolute left-4 top-1/2 transform -translate-y-1/2 text-slate-950 dark:text-slate-400",
                    ),
                  ],
                  [],
                ),
              ]),
              html.i(
                [
                  attribute.class(
                    "ri-settings-4-line text-xl text-slate-700 dark:text-slate-300",
                  ),
                ],
                [],
              ),
              html.button(
                [
                  attribute.class("p-2 hidden md:flex"),
                  attribute("onclick", "toggleDarkMode()"),
                ],
                [
                  html.i(
                    [
                      attribute.class(
                        "theme-icon text-xl text-slate-700 dark:text-slate-300",
                      ),
                    ],
                    [],
                  ),
                ],
              ),
            ],
          ),
        ]),
        html.div([attribute.class("px-5 flex flex-col items-center")], [
          html.div([attribute.class("space-y-6 w-full max-w-[800px]")], [
            html.div(
              [
                attribute.class(
                  "w-full bg-slate-100 dark:bg-slate-800 rounded-2xl p-4",
                ),
              ],
              [
                html.div(
                  [
                    attribute.class(
                      "text-slate-700 dark:text-slate-300 text-sm",
                    ),
                  ],
                  [
                    html.text(
                      "phoenix v1.7.0
              ",
                    ),
                  ],
                ),
                html.h3(
                  [
                    attribute.class(
                      "text-slate-950 dark:text-slate-50 text-xl font-semibold leading-loose mt-1",
                    ),
                  ],
                  [
                    html.text(
                      "Phoenix.Channel - Channels Documentation
              ",
                    ),
                  ],
                ),
                html.div(
                  [
                    attribute.class(
                      "mt-2 inline-flex px-3 py-0.5 bg-slate-300 dark:bg-slate-700 rounded-full",
                    ),
                  ],
                  [
                    html.span(
                      [
                        attribute.class(
                          "text-blue-600 dark:text-blue-400 text-sm",
                        ),
                      ],
                      [html.text("hexdocs.pm/phoenix/Phoenix.Channel.html")],
                    ),
                  ],
                ),
                html.p(
                  [
                    attribute.class(
                      "mt-4 text-slate-800 dark:text-slate-300 leading-normal line-clamp-2 overflow-hidden",
                    ),
                  ],
                  [
                    html.text(
                      "Channels are a really good abstraction
                ",
                    ),
                    html.span(
                      [
                        attribute.class(
                          "bg-slate-950 text-slate-100 px-1 rounded",
                        ),
                      ],
                      [html.text("for")],
                    ),
                    html.text(
                      "real-time communication. They are bi-directional and persistent
                connections between the browser and server...
              ",
                    ),
                  ],
                ),
                html.div([attribute.class("mt-4 flex flex-wrap gap-3")], [
                  html.button(
                    [
                      attribute.class(
                        "h-10 px-4 py-2.5 bg-slate-100 dark:bg-slate-700 rounded-lg border border-slate-300 dark:border-slate-600 flex items-center justify-center",
                      ),
                    ],
                    [
                      html.span(
                        [
                          attribute.class(
                            "text-slate-800 dark:text-slate-200 text-sm font-semibold",
                          ),
                        ],
                        [html.text("Show Preview")],
                      ),
                      html.i(
                        [
                          attribute.class(
                            "ri-arrow-down-s-line ml-2 text-slate-500 dark:text-slate-400",
                          ),
                        ],
                        [],
                      ),
                    ],
                  ),
                  html.button(
                    [
                      attribute.class(
                        "h-10 px-4 py-2.5 bg-slate-100 dark:bg-slate-700 rounded-lg border border-slate-300 dark:border-slate-600 flex items-center justify-center",
                      ),
                    ],
                    [
                      html.span(
                        [
                          attribute.class(
                            "text-slate-800 dark:text-slate-200 text-sm font-semibold",
                          ),
                        ],
                        [html.text("Go to Page")],
                      ),
                      html.i(
                        [
                          attribute.class(
                            "ri-external-link-line ml-2 text-slate-500 dark:text-slate-400",
                          ),
                        ],
                        [],
                      ),
                    ],
                  ),
                ]),
              ],
            ),
            html.div(
              [
                attribute.class(
                  "w-full bg-slate-100 dark:bg-slate-800 rounded-2xl p-4",
                ),
              ],
              [
                html.div(
                  [
                    attribute.class(
                      "text-slate-700 dark:text-slate-300 text-sm",
                    ),
                  ],
                  [
                    html.text(
                      "ecto v3.10.0
              ",
                    ),
                  ],
                ),
                html.h3(
                  [
                    attribute.class(
                      "text-slate-950 dark:text-slate-50 text-xl font-semibold leading-loose mt-1",
                    ),
                  ],
                  [
                    html.text(
                      "Ecto.Query - Database Queries
              ",
                    ),
                  ],
                ),
                html.div(
                  [
                    attribute.class(
                      "mt-2 inline-flex px-3 py-0.5 bg-slate-300 dark:bg-slate-700 rounded-full",
                    ),
                  ],
                  [
                    html.span(
                      [
                        attribute.class(
                          "text-blue-600 dark:text-blue-400 text-sm",
                        ),
                      ],
                      [html.text("hexdocs.pm/ecto/Ecto.Query.html")],
                    ),
                  ],
                ),
                html.p(
                  [
                    attribute.class(
                      "mt-4 text-slate-800 dark:text-slate-300 leading-normal line-clamp-2 overflow-hidden",
                    ),
                  ],
                  [
                    html.text(
                      "This module is the main entry point
                ",
                    ),
                    html.span(
                      [
                        attribute.class(
                          "bg-slate-950 text-slate-100 px-1 rounded",
                        ),
                      ],
                      [html.text("for")],
                    ),
                    html.text(
                      "writing queries in Ecto. Queries are used to retrieve and
                manipulate data from a repository...
              ",
                    ),
                  ],
                ),
                html.div([attribute.class("mt-4 flex flex-wrap gap-3")], [
                  html.button(
                    [
                      attribute.class(
                        "h-10 px-4 py-2.5 bg-slate-100 dark:bg-slate-700 rounded-lg border border-slate-300 dark:border-slate-600 flex items-center justify-center",
                      ),
                    ],
                    [
                      html.span(
                        [
                          attribute.class(
                            "text-slate-800 dark:text-slate-200 text-sm font-semibold",
                          ),
                        ],
                        [html.text("Show Preview")],
                      ),
                      html.i(
                        [
                          attribute.class(
                            "ri-arrow-down-s-line ml-2 text-slate-500 dark:text-slate-400",
                          ),
                        ],
                        [],
                      ),
                    ],
                  ),
                  html.button(
                    [
                      attribute.class(
                        "h-10 px-4 py-2.5 bg-slate-100 dark:bg-slate-700 rounded-lg border border-slate-300 dark:border-slate-600 flex items-center justify-center",
                      ),
                    ],
                    [
                      html.span(
                        [
                          attribute.class(
                            "text-slate-800 dark:text-slate-200 text-sm font-semibold",
                          ),
                        ],
                        [html.text("Go to Page")],
                      ),
                      html.i(
                        [
                          attribute.class(
                            "ri-external-link-line ml-2 text-slate-500 dark:text-slate-400",
                          ),
                        ],
                        [],
                      ),
                    ],
                  ),
                ]),
              ],
            ),
          ]),
        ]),
      ]),
    ]),
  ])
}
