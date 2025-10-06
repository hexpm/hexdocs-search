import gleam/dynamic.{type Dynamic}
import gleam/hexpm
import gleam/http/response.{type Response}
import gleam/uri
import hexdocs_search/loss.{type Loss}

pub type Msg {
  // API messages.
  ApiReturnedPackageVersions(
    package: String,
    response: Loss(Response(hexpm.Package)),
  )
  ApiReturnedPackages(Loss(Response(String)))
  ApiReturnedTypesenseSearch(Loss(Response(Dynamic)))

  // Application messages.
  DocumentChangedLocation(location: uri.Uri)
  DocumentRegisteredEventListener(unsubscriber: fn() -> Nil)
  UserClickedGoBack
  UserToggledDarkMode

  // Home page messages.
  UserBlurredSearch
  UserClickedAutocompletePackage(package: String)
  UserEditedSearch(search: String)
  UserFocusedSearch
  UserSelectedNextAutocompletePackage
  UserSelectedPreviousAutocompletePackage
  UserSubmittedSearch

  // Search page messages.
  UserDeletedPackagesFilter(#(String, String))
  UserEditedPackagesFilterInput(String)
  UserEditedPackagesFilterVersion(String)
  UserEditedSearchInput(search_input: String)
  UserFocusedPackagesFilterInput
  UserFocusedPackagesFilterVersion
  UserSelectedPackageFilter
  UserSelectedPackageFilterVersion
  UserSubmittedPackagesFilter
  UserSubmittedSearchInput
  UserToggledPreview(id: String)

  // Neutral element, because we need to call `stop_propagation` conditionnally.
  None
}
