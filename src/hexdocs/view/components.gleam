import hexdocs/data/model.{type Model}
import hexdocs/data/msg
import lustre/attribute.{class}
import lustre/element
import lustre/element/html
import lustre/event

pub fn input_classes() {
  [
    class("search-input w-full bg-white dark:bg-gray-800"),
    class("rounded-lg border border-gray-200 dark:border-gray-700"),
    class(
      "placeholder:text-gray-400 dark:placeholder:text-gray-400 text-gray-700 dark:text-gray-100",
    ),
    class(
      "focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent",
    ),
  ]
}

pub fn dark_mode_toggle(model: Model) -> element.Element(msg.Msg) {
  html.button([class("p-2"), event.on_click(msg.UserToggledDarkMode)], [
    html.i(
      [
        class("theme-icon text-xl text-slate-700 dark:text-slate-300"),
        class(case model.dark_mode.mode {
          msg.Dark -> "ri-sun-line"
          msg.Light -> "ri-moon-line"
        }),
      ],
      [],
    ),
  ])
}
