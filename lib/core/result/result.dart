class Result<T> {
  final T? _value;
  final String? _error;
  final bool _isSuccess;

  Result.success([this._value])
      : _error = null,
        _isSuccess = true;

  Result.error([this._error])
      : _value = null,
        _isSuccess = false;

  bool get isSuccess => _isSuccess;
  bool get isError => !_isSuccess;

  T get value => _value!;
  String get error => _error!;

  @override
  String toString() {
    return isSuccess ? 'Success($_value)' : 'Error($_error)';
  }
}
