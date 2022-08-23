class StoreRequest<Key> {
  Key key;
  bool refresh;

  StoreRequest({
    required this.key,
    required this.refresh,
  });
}
