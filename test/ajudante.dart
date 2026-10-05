import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_jogoteca/app.dart';
import 'package:minha_jogoteca/data/repositorio.dart';
import 'package:minha_jogoteca/models/jogo.dart';
import 'package:minha_jogoteca/state/acervo.dart';
import 'package:minha_jogoteca/state/modo_tema.dart';

/// Carrega as fontes reais do app. Sem isso o teste usaria a fonte padrão de
/// teste, cujos caracteres são quadrados largos, e mediria layouts falsos.
Future<void> carregarFontes() async {
  Future<void> carregar(String familia, List<String> arquivos) async {
    final loader = FontLoader(familia);
    for (final arquivo in arquivos) {
      loader.addFont(rootBundle.load('assets/fonts/$arquivo'));
    }
    await loader.load();
  }

  await carregar('ChakraPetch', [
    'ChakraPetch-Medium.ttf',
    'ChakraPetch-SemiBold.ttf',
    'ChakraPetch-Bold.ttf',
  ]);
  await carregar('Barlow', [
    'Barlow-Regular.ttf',
    'Barlow-Medium.ttf',
    'Barlow-SemiBold.ttf',
  ]);
}

Jogo jogoDe(
  String titulo, {
  Plataforma plataforma = Plataforma.pc,
  StatusJogo status = StatusJogo.queroJogar,
  String genero = 'Ação',
  int nota = 0,
  int horas = 0,
  String observacoes = '',
}) => Jogo.novo(
  titulo: titulo,
  plataforma: plataforma,
  genero: genero,
  status: status,
  nota: nota,
  horas: horas,
  observacoes: observacoes,
);

/// Monta o app completo com um acervo em memória e devolve esse acervo, para
/// o teste poder inspecionar o estado depois das interações.
Future<Acervo> montarApp(
  WidgetTester tester, {
  List<Jogo> jogos = const [],
  Size tamanho = const Size(390, 844),
  double escalaTexto = 1,
  ThemeMode tema = ThemeMode.dark,
}) async {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final acervo = Acervo(RepositorioMemoria(jogos));
  await acervo.carregar();
  final modo = ModoTema(persistir: false);
  await modo.definir(tema);

  tester.platformDispatcher.textScaleFactorTestValue = escalaTexto;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(JogotecaApp(acervo: acervo, tema: modo));
  await tester.pumpAndSettle();
  return acervo;
}
