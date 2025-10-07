export function addDocumentListener(callback) {
  const callback_ = () => {
    console.log("mimuf")
    callback()
  }
  document.addEventListener("click", callback_, { once: true })
  return () => document.removeEventListener("click", callback_)
}
