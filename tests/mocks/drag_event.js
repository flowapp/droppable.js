import initMouseEvent from "./mouse_event";

let initDragEvent = function(type, bubbles, cancelable, view,
                             detail, screenX, screenY, clientX,
                             clientY, ctrlKey, altKey, shiftKey,
                             metaKey, button, relatedTarget, dataTransfer) {

  let event = initMouseEvent(type, bubbles, cancelable, view,
                             detail, screenX, screenY, clientX,
                             clientY, ctrlKey, altKey, shiftKey,
                             metaKey, button, relatedTarget);

  Object.defineProperty(event, "dataTransfer", {value: dataTransfer});
  return event;
}

export default initDragEvent;
