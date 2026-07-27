/// Estado de carregamento de uma tela, modelado como união selada.
///
/// Torna impossível representar combinações inválidas (ex.: carregando com
/// erro preenchido), em vez de validar flags soltas na view.
sealed class ViewState<T> {
  const ViewState();

  /// Dados disponíveis, ou `null` quando o estado ainda não é de sucesso.
  T? get dataOrNull => switch (this) {
    ViewStateSuccess<T>(:final data) => data,
    _ => null,
  };

  bool get isLoading => this is ViewStateLoading<T>;
}

final class ViewStateLoading<T> extends ViewState<T> {
  const ViewStateLoading();
}

final class ViewStateSuccess<T> extends ViewState<T> {
  final T data;

  const ViewStateSuccess(this.data);
}

final class ViewStateFailure<T> extends ViewState<T> {
  final String message;

  const ViewStateFailure(this.message);
}
