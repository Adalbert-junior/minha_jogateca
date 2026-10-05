import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_jogoteca/models/conquistas.dart';
import 'package:minha_jogoteca/models/jogo.dart';
import 'package:minha_jogoteca/pages/painel_page.dart';
import 'package:minha_jogoteca/state/acervo.dart';
import 'package:minha_jogoteca/data/repositorio.dart';
import 'package:minha_jogoteca/widgets/roleta_backlog.dart';

import 'ajudante.dart';

void main() {
  setUpAll(carregarFontes);

  Future<Acervo> abrirPainel(WidgetTester tester, List<Jogo> jogos) async {
    final acervo = await montarApp(
      tester,
      jogos: jogos,
      tamanho: const Size(420, 2400),
    );
    await tester.tap(find.byTooltip('Painel e estatísticas'));
    await tester.pumpAndSettle();
    return acervo;
  }

  testWidgets('o painel mostra os números da coleção', (tester) async {
    await abrirPainel(tester, [
      jogoDe('A', status: StatusJogo.zerado, nota: 5, horas: 10),
      jogoDe('B', status: StatusJogo.zerado, nota: 3, horas: 20),
      jogoDe('C'),
    ]);

    expect(find.text('30 h'), findsWidgets); // total e barra da plataforma
    expect(find.text('4,0'), findsOneWidget); // nota média
    expect(find.text('100%'), findsOneWidget); // 2 de 2 iniciados
  });

  testWidgets('a roleta sorteia só entre os jogos "quero jogar"', (
    tester,
  ) async {
    final acervo = await montarApp(
      tester,
      jogos: [
        jogoDe('Fila 1'),
        jogoDe('Jogando', status: StatusJogo.jogando, horas: 2),
      ],
      tamanho: const Size(420, 2400),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoletaBacklog(
            acervo: acervo,
            random: Random(1),
            aoAbrir: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sortear'));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Fila 1'), findsOneWidget);
    expect(find.text('Jogando'), findsNothing);
    expect(find.text('Sortear de novo'), findsOneWidget);
  });

  testWidgets('sem jogos na fila o botão da roleta fica desligado', (
    tester,
  ) async {
    final acervo = Acervo(
      RepositorioMemoria([jogoDe('X', status: StatusJogo.zerado, horas: 3)]),
    );
    await acervo.carregar();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoletaBacklog(acervo: acervo, aoAbrir: (_) {}),
        ),
      ),
    );

    final botao = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(botao.onPressed, isNull);
  });

  testWidgets('"Começar a jogar" muda a situação do jogo sorteado', (
    tester,
  ) async {
    final alvo = jogoDe('Único');
    final acervo = Acervo(RepositorioMemoria([alvo]));
    await acervo.carregar();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoletaBacklog(acervo: acervo, aoAbrir: (_) {}),
        ),
      ),
    );

    await tester.tap(find.text('Sortear'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.text('Começar a jogar'));
    await tester.pumpAndSettle();

    expect(acervo.porId(alvo.id)!.status, StatusJogo.jogando);
  });

  group('conquistas', () {
    test('cada selo é liberado pela condição descrita', () {
      Conquista por(String titulo) =>
          conquistas.firstWhere((c) => c.titulo == titulo);

      expect(por('Primeiro save').liberada([]), isFalse);
      expect(por('Primeiro save').liberada([jogoDe('A')]), isTrue);

      final dez = [for (var i = 0; i < 10; i++) jogoDe('J$i')];
      expect(por('Colecionador').liberada(dez.take(9).toList()), isFalse);
      expect(por('Colecionador').liberada(dez), isTrue);

      expect(
        por('Multiplataforma').liberada([
          jogoDe('A', plataforma: Plataforma.pc),
          jogoDe('B', plataforma: Plataforma.xbox),
        ]),
        isFalse,
      );
      expect(
        por('Multiplataforma').liberada([
          jogoDe('A', plataforma: Plataforma.pc),
          jogoDe('B', plataforma: Plataforma.xbox),
          jogoDe('C', plataforma: Plataforma.mobile),
        ]),
        isTrue,
      );

      expect(
        por('Sem vida social').liberada([
          jogoDe('A', horas: 60, status: StatusJogo.jogando),
          jogoDe('B', horas: 40, status: StatusJogo.jogando),
        ]),
        isTrue,
      );
    });
  });

  test('o resumo em texto lista os jogos por situação', () {
    final jogos = [
      jogoDe('Hades', status: StatusJogo.zerado, nota: 5, horas: 30),
      jogoDe('Dune'),
    ];
    final acervo = Acervo(RepositorioMemoria());
    acervo.adicionarVarios(jogos);

    final texto = montarResumoTexto(acervo.todos, acervo.resumo);
    expect(
      texto,
      contains('2 jogos · 1 zerado · 30 h jogadas · nota média 5,0'),
    );
    expect(texto, contains('Zerado: Hades'));
    expect(texto, contains('Quero jogar: Dune'));
  });
}
