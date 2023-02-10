abstract class Pair<F, S> {
  const Pair();
  F get first;
  S get second;
  set setFirst(F x);
  set setSecond(S x);

  @override
  String toString() {
    return "$first : $second";
  }
}

class ImmutablePair<F, S> extends Pair {
  final F _f;
  final S _s;
  const ImmutablePair(this._f, this._s);
  @override
  F get first => _f;
  @override
  S get second => _s;

  @override
  set setFirst(x) {
    throw Exception("cannot set for immutable pair");
  }

  @override
  set setSecond(x) {
    throw Exception("cannot set for immutable pair");
  }
}

class MutablePair<F, S> extends Pair {
  F _f;
  S _s;
  MutablePair(this._f, this._s);
  @override
  F get first => _f;
  @override
  S get second => _s;
  @override
  set setFirst(dynamic x) => _f = x;
  @override
  set setSecond(dynamic x) => _s = x;

  void setFirstF(F x) {
    _f = x;
  }

  @override
  String toString() {
    return "mutable: ${super.toString()}";
  }
}
