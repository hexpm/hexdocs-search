import gleam/dynamic/decode
import gleam/http/response
import gleam/uri
import hexdocs_search/error
import hexdocs_search/services/hex

pub type Msg {
  ApiReturnedPackageVersions(error.Result(response.Response(hex.Package)))
  ApiReturnedPackages(error.Result(response.Response(String)))
  ApiReturnedTypesenseSearch(error.Result(response.Response(decode.Dynamic)))
  DocumentChangedLocation(location: uri.Uri)
  DocumentRegisteredEventListener(unsubscriber: fn() -> Nil)
  UserBlurredSearch
  UserEditedSearch(search: String)
  UserFocusedSearch
  UserNextAutocompletePackageSelected
  UserPreviousAutocompletePackageSelected
  UserSelectedAutocompletePackage(package: String)
  UserSubmittedSearch
  UserEditedSearchInput(search_input: String)
  UserSubmittedSearchInput
}
