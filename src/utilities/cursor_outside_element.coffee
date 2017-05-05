module.exports = (e, element, options = {}) ->
  rect = element.getBoundingClientRect()
  x = e.clientX
  y = e.clientY
  top = Math.floor(rect.top)
  bottom = Math.floor(rect.bottom)
  left = Math.floor(rect.left)
  right = Math.floor(rect.right)

  if (x < left || x >= right || y < top || y >= bottom)
    # Cursor is outside of element
    return true
  else
    # Otherwise check if cursor is on a part of the element that is scrolled out of view - if so, consider the cursor to be outside of element.
    scrollableParent = element.closest("[data-scrollable='true']")
    if scrollableParent
      parentRect = scrollableParent.getBoundingClientRect()
      parentTop = Math.floor(parentRect.top)
      parentBottom = Math.floor(parentRect.bottom)
      parentLeft = Math.floor(parentRect.left)
      parentRight = Math.floor(parentRect.right)
      return (x <= parentLeft || x >= parentRight || y <= parentTop || y >= parentBottom)
    else
      return false
