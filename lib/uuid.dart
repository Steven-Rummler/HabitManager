int _nextIdValue = 10;

int nextId() {
  _nextIdValue += 1;

  return _nextIdValue;
}

setId(int id) {
  _nextIdValue = id;
}
