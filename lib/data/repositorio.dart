import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/jogo.dart';

/// Onde a coleção fica guardada. O app usa [RepositorioLocal]; os testes usam
/// [RepositorioMemoria] para não depender de armazenamento do dispositivo.
abstract class Repositorio {
  Future<List<Jogo>> carregar();
  Future<void> salvar(List<Jogo> jogos);
}

class RepositorioMemoria implements Repositorio {
  RepositorioMemoria([List<Jogo> inicial = const []])
    : _jogos = List.of(inicial);

  List<Jogo> _jogos;

  @override
  Future<List<Jogo>> carregar() async => List.of(_jogos);

  @override
  Future<void> salvar(List<Jogo> jogos) async => _jogos = List.of(jogos);
}

class RepositorioLocal implements Repositorio {
  static const _chave = 'zerado.jogos.v1';

  @override
  Future<List<Jogo>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_chave);
    if (texto == null) return [];
    try {
      final lista = jsonDecode(texto) as List<dynamic>;
      return [
        for (final item in lista) Jogo.deJson(item as Map<String, dynamic>),
      ];
    } on Object {
      // Dado corrompido não pode impedir o app de abrir.
      return [];
    }
  }

  @override
  Future<void> salvar(List<Jogo> jogos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave,
      jsonEncode([for (final j in jogos) j.paraJson()]),
    );
  }
}
