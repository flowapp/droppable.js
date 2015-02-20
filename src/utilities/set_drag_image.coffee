module.exports = (dataTransfer, iconAndSize) ->
  image = iconAndSize[0]
  if image instanceof Image && !image.complete
    # Early exit; not loaded image will not work and more importantly it craches Safari 6
    return

  if dataTransfer.setDragImage
    if image instanceof HTMLElement
      # Chrome hack; position the drag element where the UA are suppose to position it.
      # This since UA's requires it to be in the DOM and Chrome requires it to be in view…
      iconAndSize[0] = image = image.cloneNode true
      image.style.position = "absolute"
      image.style.left = "#{e.clientX - iconAndSize[1]}px"
      image.style.top = "#{e.clientY - iconAndSize[2]}px"
      document.body.appendChild image
      # Remove it from the DOM at the next run loop
      setTimeout(->
        document.body.removeChild image
      , 0)

    dataTransfer.setDragImage.apply dataTransfer, iconAndSize
