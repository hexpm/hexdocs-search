import hexdocs_search/data/model.{type Model}
import hexdocs_search/data/model/route
import hexdocs_search/view/home.{home}
import hexdocs_search/view/search.{search}
import lustre/element/html

pub fn view(model: Model) {
  case model.route {
    route.Home -> home(model)
    route.Search(..) -> search(model)
    route.NotFound -> html.div([], [])
  }
}
