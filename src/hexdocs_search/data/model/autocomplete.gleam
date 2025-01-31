import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

/// Zipper, providing a visualisation of an element of an autocompleted list.
/// Current value can be obtained using `current`, while the entire list can be
/// obtained through `all` for display purposes.
pub opaque type Autocomplete {
  Autocomplete(
    all_: List(String),
    previous: List(String),
    current_: Option(String),
    next: List(String),
  )
}

/// Initialise the current autocomplete, with no current selected element.
pub fn init(packages: List(String), search: String) -> Autocomplete {
  let packages = keep_first_ten_packages(packages, search)
  Autocomplete(all_: packages, previous: [], current_: None, next: packages)
}

pub fn all(autocomplete: Autocomplete) -> List(String) {
  autocomplete.all_
}

pub fn current(autocomplete: Autocomplete) -> Option(String) {
  autocomplete.current_
}

pub fn selected(autocomplete: Autocomplete, element: String) -> Bool {
  autocomplete.current_ == Some(element)
}

/// Select the next element. If there's no next element, nothing happens.
pub fn next(autocomplete: Autocomplete) -> Autocomplete {
  case autocomplete {
    Autocomplete(next: [], ..) -> autocomplete
    Autocomplete(next: [fst, ..next], current_: None, ..) ->
      Autocomplete(..autocomplete, current_: Some(fst), next:)
    Autocomplete(next: [fst, ..next], current_: Some(c), ..) -> {
      let previous = [c, ..autocomplete.previous]
      let current_ = Some(fst)
      Autocomplete(..autocomplete, previous:, current_:, next:)
    }
  }
}

/// Select the previous element. If there's no previous element, current element
/// is deselected. If there's no previous element & no current element, nothing
/// happens.
pub fn previous(autocomplete: Autocomplete) -> Autocomplete {
  case autocomplete {
    Autocomplete(previous: [], current_: None, ..) -> autocomplete
    Autocomplete(previous: [], current_: Some(c), next:, ..) ->
      Autocomplete(..autocomplete, next: [c, ..next], current_: None)
    Autocomplete(previous: [fst, ..previous], current_: Some(c), next:, ..) -> {
      let current_ = Some(fst)
      Autocomplete(..autocomplete, previous:, current_:, next: [c, ..next])
    }
    _ -> panic as "previous cannot be filled if current is None"
  }
}

fn keep_first_ten_packages(packages: List(String), search: String) {
  packages
  |> list.filter(string.starts_with(_, search))
  |> list.take(10)
}
