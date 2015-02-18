class MockDataTransfer {
  constructor(data = {}) {
    this._data = data;
  }

  get types() {
    return Object.keys(this._data);
  }

  clearData(format) {
    if (format) {
      delete this._data[format]
    } else {
      this._data = {}
    }
  }

  setData(format, data) {
    this._data[format] = data
  }

  getData(format) {
    return this._data[format]
  }

  setDragImage(image, x, y) {
    // no-op for now
  }

  addElement(element) {
    // no-op for now
  }
}

export default MockDataTransfer;
