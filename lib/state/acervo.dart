import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/repositorio.dart';
import '../models/jogo.dart';

enum Ordenacao {
  recentes('Mais recentes'),
  titulo('Título (A–Z)'),
  nota('Maior nota'),
  horas('Mais horas');

  const Ordenacao(this.rotulo);

  final String rotulo;
}

/// Números do painel, calculados sempre a partir da coleção atual.
class Resumo {
  const Resumo({
    required this.total,
    required this.horas,
    required this.porStatus,
    required this.horasPorPlataforma,
    required this.mediaNota,
  });

  final int total;
  final int horas;
  final Map<StatusJogo, int> porStatus;
  final Map<Plataforma, int> horasPorPlataforma;

  /// Média só dos jogos que têm nota; nula quando nenhum foi avaliado.
  final double? mediaNota;

  int quantos(StatusJogo status) => porStatus[status] ?? 0;

  /// Fração (0 a 1) de jogos zerados entre os que já foram jogados de fato.
  double get taxaDeConclusao {
    final iniciados = total - quantos(StatusJogo.queroJogar);
    if (iniciados == 0) return 0;
    return quantos(StatusJogo.zerado) / iniciados;
  }
}

/// Estado da coleção. As telas só leem daqui e pedem alterações pelos
/// métodos; cada alteração é gravada no [Repositorio].
class Acervo extends ChangeNotifier {
  Acervo(this._repositorio);

  final Repositorio _repositorio;
  final List<Jogo> _jogos = [];

  bool _carregado = false;
  String _busca = '';
  StatusJogo? _filtro;
  Ordenacao _ordenacao = Ordenacao.recentes;

  bool get carregado => _carregado;
  String get busca => _busca;
  StatusJogo? get filtro => _filtro;
  Ordenacao get ordenacao => _ordenacao;
  List<Jogo> get todos => List.unmodifiable(_jogos);
  bool get vazio => _jogos.isEmpty;

  Future<void> carregar() async {
    _jogos
      ..clear()
      ..addAll(await _repositorio.carregar());
    _carregado = true;
    notifyListeners();
  }

  /// Jogos que passam pela busca e pelo filtro, já na ordem escolhida.
  List<Jogo> get visiveis {
    final termo = _normalizar(_busca.trim());
    final lista = _jogos.where((j) {
      if (_filtro != null && j.status != _filtro) return false;
      if (termo.isEmpty) return true;
      return _normalizar(j.titulo).contains(termo) ||
          _normalizar(j.genero).contains(termo) ||
          _normalizar(j.plataforma.rotulo).contains(termo);
    }).toList();

    lista.sort(switch (_ordenacao) {
      Ordenacao.recentes => (a, b) => b.adicionadoEm.compareTo(a.adicionadoEm),
      Ordenacao.titulo => (a, b) => _normalizar(
        a.titulo,
      ).compareTo(_normalizar(b.titulo)),
      Ordenacao.nota => (a, b) => b.nota.compareTo(a.nota),
      Ordenacao.horas => (a, b) => b.horas.compareTo(a.horas),
    });
    return lista;
  }

  Jogo? porId(String id) {
    final i = _jogos.indexWhere((j) => j.id == id);
    return i == -1 ? null : _jogos[i];
  }

  /// Já existe um jogo com esse título nessa plataforma? Na edição o próprio
  /// item é ignorado, senão ele conflitaria consigo mesmo.
  bool jaExiste(String titulo, Plataforma plataforma, {String? ignorarId}) {
    final alvo = _normalizar(titulo.trim());
    return _jogos.any(
      (j) =>
          j.id != ignorarId &&
          j.plataforma == plataforma &&
          _normalizar(j.titulo) == alvo,
    );
  }

  void adicionar(Jogo jogo) {
    _jogos.add(jogo);
    _mudou();
  }

  void adicionarVarios(Iterable<Jogo> jogos) {
    _jogos.addAll(jogos);
    _mudou();
  }

  /// Troca o item de mesmo id. Comparar por id (e não por título) é o que
  /// impede a edição de duplicar ou de mexer em outro jogo homônimo.
  void atualizar(Jogo jogo) {
    final i = _jogos.indexWhere((j) => j.id == jogo.id);
    if (i == -1) return;
    _jogos[i] = jogo;
    _mudou();
  }

  /// Remove e devolve o jogo e a posição em que ele estava, para o "Desfazer".
  ({Jogo jogo, int indice})? remover(String id) {
    final i = _jogos.indexWhere((j) => j.id == id);
    if (i == -1) return null;
    final removido = _jogos.removeAt(i);
    _mudou();
    return (jogo: removido, indice: i);
  }

  void restaurar(Jogo jogo, int indice) {
    _jogos.insert(indice.clamp(0, _jogos.length), jogo);
    _mudou();
  }

  void definirBusca(String valor) {
    _busca = valor;
    notifyListeners();
  }

  void definirFiltro(StatusJogo? valor) {
    _filtro = valor;
    notifyListeners();
  }

  void definirOrdenacao(Ordenacao valor) {
    _ordenacao = valor;
    notifyListeners();
  }

  Resumo get resumo {
    final porStatus = <StatusJogo, int>{};
    final horasPorPlataforma = <Plataforma, int>{};
    var horas = 0;
    var somaNotas = 0;
    var avaliados = 0;
    for (final j in _jogos) {
      porStatus[j.status] = (porStatus[j.status] ?? 0) + 1;
      horasPorPlataforma[j.plataforma] =
          (horasPorPlataforma[j.plataforma] ?? 0) + j.horas;
      horas += j.horas;
      if (j.temNota) {
        somaNotas += j.nota;
        avaliados++;
      }
    }
    return Resumo(
      total: _jogos.length,
      horas: horas,
      porStatus: porStatus,
      horasPorPlataforma: horasPorPlataforma,
      mediaNota: avaliados == 0 ? null : somaNotas / avaliados,
    );
  }

  void _mudou() {
    notifyListeners();
    unawaited(_repositorio.salvar(List.of(_jogos)));
  }

  static String _normalizar(String texto) {
    const de = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const para = 'aaaaaeeeeiiiiooooouuuucn';
    final minusculo = texto.toLowerCase();
    final saida = StringBuffer();
    for (final c in minusculo.split('')) {
      final i = de.indexOf(c);
      saida.write(i == -1 ? c : para[i]);
    }
    return saida.toString();
  }
}

/// Entrega o [Acervo] para a árvore de widgets e reconstrói quem depender dele.
class AcervoScope extends InheritedNotifier<Acervo> {
  const AcervoScope({super.key, required Acervo acervo, required super.child})
    : super(notifier: acervo);

  static Acervo of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AcervoScope>();
    assert(scope != null, 'AcervoScope não encontrado acima deste widget');
    return scope!.notifier!;
  }
}
