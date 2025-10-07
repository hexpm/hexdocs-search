import gleam/dict
import gleam/dynamic/decode
import gleam/function
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
import hexdocs_search/data/model/autocomplete
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
    msg.DocumentRegisteredSidebarListener(unsubscriber:) ->
      document_registered_sidebar_listener(model, unsubscriber)
    msg.DocumentChangedTheme(theme) ->
      model.update_color_theme(model, theme)
      |> pair.new(effect.none())

    msg.UserToggledDarkMode -> user_toggled_dark_mode(model)
    msg.UserToggledSidebar -> model.toggle_sidebar(model)
    msg.UserClosedSidebar -> model.close_sidebar(model)
    msg.UserClickedGoBack -> user_clicked_go_back(model)

    msg.UserFocusedSearch -> user_focused_search(model)
    msg.UserBlurredSearch -> model.blur_search(model)

    msg.UserEditedSearch(search:) -> model.update_home_search(model, search)
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
    msg.UserFocusedPackagesFilterInput ->
      user_focused_packages_filter_input(model)
    msg.UserFocusedPackagesFilterVersion ->
      user_focused_packages_filter_version_input(model)
    msg.UserToggledPreview(id) -> user_toggled_preview(model, id)
    msg.UserSelectedPackageFilter -> user_selected_package_filter(model)
    msg.UserSelectedPackageFilterVersion ->
      user_selected_package_filter_version(model)

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
      Model(..model, packages_versions: {
        dict.insert(model.packages_versions, package, body)
      })
      |> model.focus_home_search
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

fn document_registered_sidebar_listener(model: Model, unsubscriber: fn() -> Nil) {
  let dom_click_sidebar_unsubscriber = Some(unsubscriber)
  Model(..model, dom_click_sidebar_unsubscriber:)
  |> pair.new(effect.none())
}

fn user_toggled_dark_mode(model: Model) {
  let model = model.toggle_dark_theme(model)
  #(model, {
    use _ <- effect.from()
    update_color_theme(case model.dark_mode.mode {
      msg.Dark -> "dark"
      msg.Light -> "light"
    })
  })
}

fn user_edited_search_input(model: Model, search_input: String) {
  Model(..model, search_input:)
  |> pair.new(effect.none())
}

fn user_edited_packages_filter_input(model: Model, content: String) {
  Model(
    ..model,
    search_packages_filter_input: content,
    search_packages_filter_input_displayed: content,
  )
  |> model.autocomplete_packages(content)
  |> function.tap(fn(m) { m.autocomplete })
  |> pair.new(effect.none())
}

fn user_edited_packages_filter_version(model: Model, content: String) {
  Model(
    ..model,
    search_packages_filter_version_input: content,
    search_packages_filter_version_input_displayed: content,
  )
  |> pair.new(effect.none())
}

fn user_submitted_search(model: Model) {
  let model = model.compute_filters_input(model)
  #(model, {
    route.push({
      route.Search(
        q: model.search_input,
        packages: model.search_packages_filters,
      )
    })
  })
}

fn user_submitted_search_input(model: Model) {
  #(model, {
    route.push({
      route.Search(
        q: model.search_input,
        packages: model.search_packages_filters,
      )
    })
  })
}

fn user_focused_search(model: Model) {
  let #(model, effect) = model.focus_home_search(model)
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
    let versions = case model.autocomplete {
      None -> effect.none()
      Some(#(model.Version, _)) -> effect.none()
      Some(#(model.Package, _)) -> effects.package_versions(package)
    }
    effect.batch([versions, effects])
  })
}

fn user_deleted_packages_filter(
  model: Model,
  filter: #(String, String),
) -> #(Model, Effect(msg)) {
  let search_packages_filters =
    list.filter(model.search_packages_filters, fn(f) { f != filter })
  let model = Model(..model, search_packages_filters:)
  #(model, {
    route.push(route.Search(
      q: model.search_input,
      packages: model.search_packages_filters,
    ))
  })
}

fn user_clicked_go_back(model: Model) -> #(Model, Effect(msg)) {
  #(model, modem.back(1))
}

fn user_submitted_packages_filter(model: Model) {
  let package = model.search_packages_filter_input
  let version = model.search_packages_filter_version_input
  model.packages_versions
  |> dict.get(package)
  |> result.map(fn(package) { package.releases })
  |> result.try(list.find(_, fn(r) { r.version == version }))
  |> result.map(fn(_) {
    let search_packages_filters =
      [#(package, version)]
      |> list.append(model.search_packages_filters, _)
      |> list.unique
    let model =
      Model(
        ..model,
        search_packages_filters:,
        search_packages_filter_input: "",
        search_packages_filter_input_displayed: "",
        search_packages_filter_version_input: "",
        search_packages_filter_version_input_displayed: "",
      )
    route.Search(q: model.search_input, packages: model.search_packages_filters)
    |> route.push
    |> pair.new(model, _)
  })
  |> result.lazy_unwrap(fn() { #(model, effect.none()) })
}

fn user_focused_packages_filter_input(model: Model) {
  let model = model.focus_packages_filter_search(model)
  let effect = effects.subscribe_blurred_search()
  #(model, effect)
}

fn user_focused_packages_filter_version_input(
  model: Model,
) -> #(Model, Effect(Msg)) {
  let #(model, effect) = model.focus_packages_filter_version_search(model)
  let effects = effect.batch([effects.subscribe_blurred_search(), effect])
  #(model, effects)
}

fn user_toggled_preview(model: Model, id: String) {
  Model(..model, search_opened_previews: {
    use opened <- dict.upsert(model.search_opened_previews, id)
    let opened = option.unwrap(opened, False)
    !opened
  })
  |> pair.new(effect.none())
}

fn user_selected_package_filter(model: Model) {
  let is_valid =
    list.contains(model.packages, model.search_packages_filter_input_displayed)
  let package = case is_valid {
    True -> Ok(model.search_packages_filter_input_displayed)
    False ->
      case model.autocomplete {
        None -> Error(Nil)
        Some(#(_, autocomplete)) ->
          autocomplete.all(autocomplete)
          |> list.first
      }
  }
  case package {
    Error(_) -> #(model, effect.none())
    Ok(package) -> {
      let model =
        Model(
          ..model,
          search_packages_filter_input_displayed: package,
          search_packages_filter_input: package,
        )
      let #(model, blur_effect) = model.blur_search(model)
      #(model, {
        effect.batch([
          blur_effect,
          effect.from(fn(_) { submit_package_input() }),
        ])
      })
    }
  }
}

fn user_selected_package_filter_version(model: Model) {
  let package = model.search_packages_filter_input_displayed
  let version = model.search_packages_filter_version_input_displayed
  let releases =
    model.packages_versions
    |> dict.get(package)
    |> result.map(fn(p) { p.releases })
    |> result.unwrap([])
  let release =
    releases
    |> list.find(fn(r) { r.version == version })
    |> result.try_recover(fn(_) { list.first(releases) })
  case release {
    Error(_) -> #(model, effect.none())
    Ok(release) -> {
      let model =
        Model(
          ..model,
          search_packages_filter_version_input: release.version,
          search_packages_filter_version_input_displayed: release.version,
        )
      let #(model, effect1) = model.blur_search(model)
      let #(model, effect2) = user_submitted_packages_filter(model)
      #(model, effect.batch([effect1, effect2]))
    }
  }
}

@external(javascript, "./hexdocs_search.ffi.mjs", "submitPackageInput")
fn submit_package_input() -> Nil

@external(javascript, "./hexdocs_search.ffi.mjs", "updateColorTheme")
fn update_color_theme(color_mode: String) -> Nil
