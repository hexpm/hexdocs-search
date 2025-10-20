import lustre/attribute.{class}

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
