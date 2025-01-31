import gleam/http/response
import hexdocs_search/error
import hexdocs_search/services/hex

pub type Msg {
  ApiReturnedPackageVersions(error.Result(response.Response(hex.Package)))
  ApiReturnedPackages(error.Result(response.Response(String)))
  DocumentRegisteredEventListener(unsubscriber: fn() -> Nil)
  UserBlurredSearch
  UserEditedSearch(search: String)
  UserFocusedSearch
  UserNextAutocompletePackageSelected
  UserPreviousAutocompletePackageSelected
  UserSelectedAutocompletePackage(package: String)
  UserSubmittedSearch
}
