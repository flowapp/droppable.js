module.exports = (e, element) -> 
  rect = element.getBoundingClientRect()
  x = e.clientX
  y = e.clientY
  top = Math.floor(rect.top)
  bottom = Math.floor(rect.bottom)
  left = Math.floor(rect.left)
  right = Math.floor(rect.right)

  (x < left || x >= right || y < top || y >= bottom)
