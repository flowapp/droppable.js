module.exports = (callback) ->
  (e) ->
    nativeEvent = e.originalEvent || e
    dataTransfer = nativeEvent.dataTransfer
    callback.call(this, e, dataTransfer)
    undefined
