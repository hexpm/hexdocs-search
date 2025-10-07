import browser/window/location

@external(javascript, "./window/location.ffi.mjs", "location")
pub fn location() -> Result(location.Location, Nil)

@external(javascript, "./window.ffi.mjs", "requestAnimationFrame")
pub fn request_animation_frame(callback: fn() -> Nil) -> Nil
