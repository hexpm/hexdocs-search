import window/location

@external(javascript, "./window/window.ffi.mjs", "location")
pub fn location() -> Result(location.Location, Nil) {
  Error(Nil)
}
