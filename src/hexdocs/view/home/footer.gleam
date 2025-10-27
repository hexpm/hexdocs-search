import lustre/attribute as a
import lustre/element/html as h

pub fn footer() {
  h.footer([], [
    h.section([a.class("flex justify-end"), a.id("publishing-docs")], [hint()]),
    h.section(
      [
        a.class("w-full"),
        a.class("border-t"),
        a.class("border-gray-200"),
        a.class("dark:border-gray-700"),
        a.class("flex"),
        a.class("flex-col"),
        a.class("lg:flex-row"),
        a.class("gap-4"),
        a.class("justify-between"),
        a.class("text-sm"),
        a.class("py-4"),
        a.id("footer"),
      ],
      [
        h.div([], [
          h.span([a.class("text-gray-600 dark:text-gray-200")], [
            h.text("Is something wrong? Let us know by "),
          ]),
          h.a(
            [
              a.class("text-blue-600 dark:text-blue-600 font-medium"),
              a.href("https://github.com/hexpm/hexpm/issues"),
            ],
            [
              h.text("Opening an Issue"),
            ],
          ),
          h.span([a.class("text-gray-600 dark:text-gray-200")], [h.text(" or ")]),
          h.a(
            [
              a.class("text-blue-600 dark:text-blue-600 font-medium"),
              a.href("mailto:support@hex.pm"),
            ],
            [
              h.text("Emailing Support"),
            ],
          ),
        ]),
        h.div([a.class("text-gray-600 dark:text-gray-200")], [
          h.text("Search powered by "),
          h.a(
            [
              a.class("text-blue-600 cursor-pointer"),
              a.href("https://typesense.org"),
            ],
            [
              h.text("Typesense"),
            ],
          ),
        ]),
      ],
    ),
  ])
}

pub fn hint() {
  h.div([a.class("relative mx-6")], [
    h.div(
      [
        a.class("relative lg:absolute w-64 h-72 bottom-0 right-0 z-10"),
        a.class("p-3 mt-16 lg:mt-0"),
        a.class("bg-gray-50 dark:bg-gray-700"),
        a.class("rounded-tl-xl rounded-tr-xl"),
      ],
      [
        h.div(
          [
            a.class("w-14 h-14"),
            a.class("bg-gray-100 dark:bg-gray-800"),
            a.class("rounded-full"),
            a.class("flex items-center justify-center"),
          ],
          [
            h.i(
              [
                a.class("ri-contacts-book-upload-line"),
                a.class("text-gray-600 dark:text-gray-100"),
                a.class("text-xl"),
              ],
              [],
            ),
          ],
        ),
        h.div([a.class("px-4 text-sm mt-4")], [
          h.h6([a.class("text-gray-700 dark:text-gray-100 font-semibold")], [
            h.text("Publishing Documentation"),
          ]),
          h.p([a.class("leading-tight mt-2")], [
            h.span([a.class("text-gray-500 dark:text-gray-200")], [
              h.text(
                "Documentation is automatically published when you publish
                your package, you can find more information ",
              ),
            ]),
            h.a(
              [
                a.class("text-blue-600 font-medium"),
                a.href("https://hexdocs.pm/hex/Mix.Tasks.Hex.Publish.html"),
              ],
              [h.text("here")],
            ),
            h.span([a.class("text-gray-500 dark:text-gray-200")], [h.text(".")]),
          ]),
          h.p([a.class("leading-tight mt-4")], [
            h.span(
              [
                a.class("text-gray-500 dark:text-gray-200"),
              ],
              [
                h.text("Learn how to write documentation "),
              ],
            ),
            h.a(
              [
                a.class("text-blue-600 font-medium"),
                a.href("https://hexdocs.pm/elixir/writing-documentation.html"),
              ],
              [h.text("here")],
            ),
            h.span([a.class("text-gray-500 dark:text-gray-200")], [h.text(".")]),
          ]),
        ]),
      ],
    ),
    h.div(
      [
        a.class("absolute"),
        a.class("w-64 h-68"),
        a.class("bottom-4"),
        a.class("-right-3.5"),
        a.class("bg-gray-100"),
        a.class("dark:bg-gray-800"),
        a.class("rotate-6"),
        a.class("rounded-tl-xl"),
        a.class("rounded-tr-xl"),
        a.class("z-0"),
      ],
      [],
    ),
  ])
}
