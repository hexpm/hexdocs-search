import gleam/http/response
import hexdocs_search/error

pub type Msg {
  ApiReturnedPackages(response: error.Result(response.Response(String)))
  UserBlurredSearch
  UserEditedSearch(search: String)
  UserFocusedSearch
  UserNextAutocompletePackageSelected
  UserPreviousAutocompletePackageSelected
}
