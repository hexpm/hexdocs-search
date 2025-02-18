import gleam/dynamic/decode
import gleam/http/response
import gleam/uri
import hexdocs_search/loss.{type Loss}
import hexdocs_search/services/hex

pub type Msg {
  ApiReturnedPackageVersions(Loss(response.Response(hex.Package)))
  ApiReturnedPackages(Loss(response.Response(String)))
  ApiReturnedTypesenseSearch(Loss(response.Response(decode.Dynamic)))
  DocumentChangedLocation(location: uri.Uri)
  DocumentRegisteredEventListener(unsubscriber: fn() -> Nil)
  UserBlurredSearch
  UserEditedPackagesFilter(packages_filter_input: String)
  UserEditedSearch(search: String)
  UserEditedSearchInput(search_input: String)
  UserFocusedSearch
  UserSelectedPreviousAutocompletePackage
  UserSelectedAutocompletePackage(package: String)
  UserSelectedNextAutocompletePackage
  UserSubmittedPackagesFilter
  UserSubmittedSearch
  UserSubmittedSearchInput
  UserSuppressedPackagesFilter(filter: String)
}
