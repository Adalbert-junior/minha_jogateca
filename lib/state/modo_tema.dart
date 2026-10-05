import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda se o usuário quer tema claro, escuro ou o do sistema.
class ModoTema extends ChangeNotifier {
  ModoTema({this.persistir = true});

  static const _chave = 'zerado.tema.v1';

  final bool persistir;
  ThemeMode _modo = ThemeMode.dark;

  ThemeMode get modo => _modo;

  Future<void> carregar() async {
    if (!persistir) return;
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getString(_chave);
    _modo = ThemeMode.values.firstWhere(
      (m) => m.name == salvo,
      orElse: () => ThemeMode.dark,
    );
    notifyListeners();
  }

  Future<void> definir(ThemeMode novo) async {
    if (novo == _modo) return;
    _modo = novo;
    notifyListeners();
    if (!persistir) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, novo.name);
  }
}
