import gleam/list
import hexdocs_search/data/model.{type Model}
import hexdocs_search/data/msg
import hexdocs_search/view/home.{home}
import hexdocs_search/view/settings.{settings}
import lustre/attribute.{class, id}
import lustre/element/html
import lustre/event

pub fn view(model: Model) {
  case model.route {
    model.Home -> home(model)
    model.Search -> search(model)
    model.NotFound -> html.div([], [])
  }
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
