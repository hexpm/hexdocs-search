import gleam/dynamic/decode
import gleam/hexpm
import gleam/http/response
import gleam/uri
import hexdocs_search/loss.{type Loss}

pub type Msg {
  ApiReturnedPackageVersions(Loss(response.Response(hexpm.Package)))
  ApiReturnedPackages(Loss(response.Response(String)))
  ApiReturnedTypesenseSearch(Loss(response.Response(decode.Dynamic)))

  DocumentChangedLocation(location: uri.Uri)
  DocumentRegisteredEventListener(unsubscriber: fn() -> Nil)

  UserToggledDarkMode
  UserClickedGoBack

  UserFocusedSearch
  UserBlurredSearch
  UserEditedSearch(search: String)
  UserClickedAutocompletePackage(package: String)
  UserSelectedNextAutocompletePackage
  UserSelectedPreviousAutocompletePackage
  UserSubmittedSearch

  UserEditedPackagesFilter(packages_filter_input: String)
  UserSubmittedPackagesFilter
  UserEditedSearchInput(search_input: String)
  UserSubmittedSearchInput
  UserSuppressedPackagesFilter(filter: String)
}
