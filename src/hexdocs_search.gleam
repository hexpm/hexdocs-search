import gleam/dict
import gleam/dynamic/decode
import gleam/hexpm
import gleam/http/response.{type Response}
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
import gleam/string
import grille_pain
import grille_pain/lustre/toast
import hexdocs_search/data/model.{type Model, Model}
import hexdocs_search/data/model/route
import hexdocs_search/data/msg.{type Msg}
import hexdocs_search/effects
import hexdocs_search/loss.{type Loss}
import hexdocs_search/services/hexdocs
import hexdocs_search/setup
import hexdocs_search/view
import lustre
import lustre/effect.{type Effect}
import modem

pub fn main() {
  let flags = Nil
  let assert Ok(_) = grille_pain.simple()
  lustre.application(setup.init, update, view.view)
  |> lustre.start("#app", flags)
}

fn update(model: Model, msg: Msg) {
  case msg {
    msg.ApiReturnedPackageVersions(package, response) ->
      api_returned_package_versions(model, package, response)
    msg.ApiReturnedPackages(response) -> api_returned_packages(model, response)
    msg.ApiReturnedTypesenseSearch(response) ->
      api_returned_typesense_search(model, response)

    msg.DocumentChangedLocation(location:) ->
      model.update_route(model, location)
    msg.DocumentRegisteredEventListener(unsubscriber:) ->
      document_registered_event_listener(model, unsubscriber)

    msg.UserToggledDarkMode -> #(model, effect.none())
    msg.UserClickedGoBack -> user_clicked_go_back(model)

    msg.UserFocusedSearch -> user_focused_search(model)
    msg.UserBlurredSearch -> model.blur_search(model)

    msg.UserEditedSearch(search:) -> model.update_search(model, search)
    msg.UserClickedAutocompletePackage(package:) ->
      user_clicked_autocomplete_package(model, package)
    msg.UserSelectedNextAutocompletePackage ->
      user_selected_next_autocomplete_package(model)
    msg.UserSelectedPreviousAutocompletePackage ->
      user_selected_previous_autocomplete_package(model)
    msg.UserSubmittedSearch -> user_submitted_search(model)

    msg.UserDeletedPackagesFilter(filter) ->
      user_deleted_packages_filter(model, filter)
    msg.UserEditedSearchInput(search_input:) ->
      user_edited_search_input(model, search_input)
    msg.UserSubmittedPackagesFilter -> user_submitted_packages_filter(model)
    msg.UserSubmittedSearchInput -> user_submitted_search_input(model)
    msg.UserEditedPackagesFilterInput(content) ->
      user_edited_packages_filter_input(model, content)
    msg.UserEditedPackagesFilterVersion(content) ->
      user_edited_packages_filter_version(model, content)
    msg.UserToggledPreview(id) -> user_toggled_preview(model, id)

    msg.None -> #(model, effect.none())
  }
}

fn api_returned_package_versions(
  model: Model,
  package: String,
  response: Loss(Response(hexpm.Package)),
) -> #(Model, Effect(Msg)) {
  case response {
    Ok(response.Response(status: 200, body:, ..)) -> {
      let package_versions = dict.insert(model.package_versions, package, body)
      Model(..model, package_versions:)
      |> model.focus_search
    }
    _ -> #(model, toast.error("Server error. Retry later."))
  }
}

fn api_returned_packages(model: Model, response: Loss(Response(String))) {
  case response {
    Ok(response.Response(status: 200, body:, ..)) ->
      body
      |> string.split(on: "\n")
      |> model.add_packages(model, _)
      |> pair.new(effect.none())
    _ -> #(model, toast.error("Server error. Retry later."))
  }
}

fn api_returned_typesense_search(
  model: Model,
  response: Loss(Response(decode.Dynamic)),
) {
  response
  |> result.try(fn(response) {
    response.body
    |> decode.run(hexdocs.typesense_decoder())
    |> result.map_error(loss.DecodeError)
  })
  |> result.map(model.set_search_results(model, _))
  |> result.map(pair.new(_, effect.none()))
  |> result.unwrap(#(model, effect.none()))
}

fn document_registered_event_listener(model: Model, unsubscriber: fn() -> Nil) {
  let dom_click_unsubscriber = Some(unsubscriber)
  Model(..model, dom_click_unsubscriber:)
  |> pair.new(effect.none())
}

fn user_edited_search_input(model: Model, search_input: String) {
  Model(..model, search_input:)
  |> pair.new(effect.none())
}

fn user_edited_packages_filter_input(model: Model, content: String) {
  Model(..model, packages_filter_input: content)
  |> pair.new(effect.none())
}

fn user_edited_packages_filter_version(model: Model, content: String) {
  Model(..model, packages_filter_version_input: content)
  |> pair.new(effect.none())
}

fn user_submitted_search(model: Model) {
  let model = model.compute_typesense_input(model)
  #(model, {
    route.push(route.Search(
      q: model.search_input,
      packages: model.packages_filter,
    ))
  })
}

fn user_submitted_search_input(model: Model) {
  #(model, {
    route.push(route.Search(
      q: model.search_input,
      packages: model.packages_filter,
    ))
  })
}

fn user_focused_search(model: Model) {
  let #(model, effect) = model.focus_search(model)
  let effects = effect.batch([effect, effects.subscribe_blurred_search()])
  #(model, effects)
}

fn user_selected_next_autocomplete_package(model: Model) {
  model
  |> model.select_next_package
  |> pair.new(effect.none())
}

fn user_selected_previous_autocomplete_package(model: Model) {
  model
  |> model.select_previous_package
  |> pair.new(effect.none())
}

fn user_clicked_autocomplete_package(model: Model, package: String) {
  model
  |> model.select_autocomplete_option(package)
  |> model.blur_search
  |> pair.map_second(fn(effects) {
    effect.batch([effects.package_versions(package), effects])
  })
}

fn user_deleted_packages_filter(model: Model, filter) {
  let filters = list.filter(model.packages_filter, fn(f) { f != filter })
  let model = Model(..model, packages_filter: filters)
  #(model, {
    route.push(route.Search(
      q: model.search_input,
      packages: model.packages_filter,
    ))
  })
}

fn user_clicked_go_back(model: Model) {
  #(model, modem.back(1))
}

fn user_submitted_packages_filter(model: Model) {
  let packages_filter =
    #(model.packages_filter_input, case model.packages_filter_version_input {
      "" -> None
      content -> Some(content)
    })
    |> list.wrap
    |> list.append(model.packages_filter, _)
    |> list.unique
  let model =
    Model(
      ..model,
      packages_filter:,
      packages_filter_input: "",
      packages_filter_version_input: "",
    )
  #(model, {
    route.push(route.Search(
      q: model.search_input,
      packages: model.packages_filter,
    ))
  })
}

fn user_toggled_preview(model: Model, id: String) {
  Model(..model, opened_previews: {
    use opened <- dict.upsert(model.opened_previews, id)
    let opened = option.unwrap(opened, False)
    !opened
  })
  |> pair.new(effect.none())
}
