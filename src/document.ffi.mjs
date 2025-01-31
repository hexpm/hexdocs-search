export function addDocumentListener(callback_) {
  const callback = (e) => {
    console.log(e)
    console.log("urn")
    callback_()
  }
  document.addEventListener("click", callback, { once: true })
  return () => document.removeEventListener("click", callback)
}
