import gleam/http/response.{type Response}
import gleam/option.{Some}
import gleam/pair
import gleam/string
import grille_pain
import grille_pain/lustre/toast
import hexdocs_search/data/model.{type Model, Model}
import hexdocs_search/data/msg.{type Msg}
import hexdocs_search/effects
import hexdocs_search/error
import hexdocs_search/services/hex
import hexdocs_search/view
import lustre
import lustre/effect

pub fn main() {
  let flags = Nil
  let assert Ok(_) = grille_pain.simple()
  let init = fn(_) { #(model.new(), effects.packages()) }
  lustre.application(init, update, view.view)
  |> lustre.start("#app", flags)
}

fn update(model: Model, msg: Msg) {
  case msg {
    msg.ApiReturnedPackageVersions(response) -> {
      api_returned_package_versions(model, response)
    }

    msg.ApiReturnedPackages(response) -> {
      api_returned_packages(model, response)
    }

    msg.DocumentRegisteredEventListener(unsubscriber:) -> {
      let dom_click_unsubscriber = Some(unsubscriber)
      Model(..model, dom_click_unsubscriber:)
      |> pair.new(effect.none())
    }

    msg.UserBlurredSearch -> {
      model.blur_search(model)
    }

    msg.UserEditedSearch(search:) -> {
      model.update_search(model, search)
      |> pair.new(effect.none())
    }

    msg.UserFocusedSearch -> {
      model.focus_search(model)
      |> pair.new(effects.subscribe_blurred_search())
    }

    msg.UserNextAutocompletePackageSelected -> {
      model.select_next_package(model)
      |> pair.new(effect.none())
    }

    msg.UserPreviousAutocompletePackageSelected -> {
      model.select_previous_package(model)
      |> pair.new(effect.none())
    }

    msg.UserSelectedAutocompletePackage(package:) -> {
      model.select_package(model, package)
      |> model.blur_search
      |> pair.map_second(fn(effects) {
        effect.batch([effects.package_versions(package), effects])
      })
    }
  }
}

fn api_returned_packages(model: Model, response: error.Result(Response(String))) {
  case response {
    Ok(response.Response(status: 200, body:, ..)) ->
      body
      |> string.split(on: "\n")
      |> model.add_packages(model, _)
      |> pair.new(effect.none())
    _ -> #(model, toast.error("Server error. Retry later."))
  }
}

fn api_returned_package_versions(
  model: Model,
  response: error.Result(Response(hex.Package)),
) {
  case response {
    Ok(response.Response(status: 200, body:, ..)) ->
      Model(..model, package_versions: Some(body))
      |> pair.new(effect.none())
    _ -> #(model, toast.error("Server error. Retry later."))
  }
}
