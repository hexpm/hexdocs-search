export function submitPackageInput() {
  if (document.activeElement.id !== "search-package-input") return
  document.activeElement.blur()
  window.requestAnimationFrame(() => focusNode())
}

function focusNode() {
  const node = document.getElementById("search-version-input")
  if (!node) return
  const hasDisabled = node.hasAttribute("disabled")
  if (hasDisabled) {
    const disabled = node.getAttribute("disabled")
    if (disabled === null || disabled === "" || disabled === "true") {
      return window.requestAnimationFrame(() => focusNode())
    }
  }
  node.focus()
}
