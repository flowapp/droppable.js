let initMouseEvent = function(type, bubbles, cancelable, view,
                                detail, screenX, screenY, clientX, clientY,
                                ctrlKey, altKey, shiftKey, metaKey,
                                button, relatedTarget) {

  let event = new Event(type, {bubbles, cancelable});
  Object.defineProperty(event, 'view', {value: view});
  Object.defineProperty(event, 'detail', {value: detail});
  Object.defineProperty(event, 'screenX', {value: screenX});
  Object.defineProperty(event, 'screenY', {value: screenY});
  Object.defineProperty(event, 'clientX', {value: clientX});
  Object.defineProperty(event, 'clientY', {value: clientY});
  Object.defineProperty(event, 'ctrlKey', {value: ctrlKey});
  Object.defineProperty(event, 'altKey', {value: altKey});
  Object.defineProperty(event, 'shiftKey', {value: shiftKey});
  Object.defineProperty(event, 'metaKey', {value: metaKey});
  Object.defineProperty(event, 'button', {value: button});
  Object.defineProperty(event, 'relatedTarget', {value: relatedTarget});

  return event;
};

export default initMouseEvent;
