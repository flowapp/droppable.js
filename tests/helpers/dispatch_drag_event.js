import MockDataTransfer from "../mocks/data_transfer";
import initDragEvent from "../mocks/drag_event";

let dispatchDragEvent = function(element, name, options = {}, data = {}) {
  let dataTransfer = new MockDataTransfer(data);

  let defaults = {
    bubbles: true,
    cancelable: true,
    view: null,
    detail: null,
    screenX: 100,
    screenY: 100,
    clientX: 100,
    clientY: 100,
    ctrl: false,
    alt: false,
    shift: false,
    meta: false,
    button: 0,
    relatedTarget: null,
    dataTransfer: dataTransfer
  };

  for (let key of Object.keys(options)) {
    defaults[key] = options[key];
  }

  let immediatePropagationStopped = true;
  let propagationStopped = true;

  let immediatePropagationCheck = function() {
    immediatePropagationStopped = false;
  };

  let propagationCheck = function() {
    propagationStopped = false;
  }

  element.addEventListener(name, immediatePropagationCheck);
  element.parentNode.addEventListener(name, propagationCheck);

  let event = initDragEvent(name,
                            defaults.bubbles,
                            defaults.cancelable,
                            defaults.view,
                            defaults.detail,
                            defaults.screenX,
                            defaults.screenY,
                            defaults.clientX,
                            defaults.clientY,
                            defaults.ctrl,
                            defaults.alt,
                            defaults.shift,
                            defaults.meta,
                            defaults.button,
                            defaults.relatedTarget,
                            defaults.dataTransfer);

  let defaultPrevented = !element.dispatchEvent(event);

  element.removeEventListener(name, immediatePropagationCheck, true);
  element.parentNode.removeEventListener(name, propagationCheck, true);
  data = event.dataTransfer._data
  return {
    event,
    defaultPrevented,
    immediatePropagationStopped,
    propagationStopped,
    data
  };
};

export default dispatchDragEvent;
