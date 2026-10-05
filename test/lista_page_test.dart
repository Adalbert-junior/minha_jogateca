import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_jogoteca/models/jogo.dart';
import 'package:minha_jogoteca/widgets/estado_vazio.dart';
import 'package:minha_jogoteca/widgets/jogo_card.dart';

import 'ajudante.dart';

void main() {
  setUpAll(carregarFontes);

  group('coleção e estado vazio', () {
    testWidgets('mostra o estado vazio, uma vez só, e nenhum cartão', (
      tester,
    ) async {
      await montarApp(tester);

      expect(find.byType(EstadoVazio), findsOneWidget);
      expect(find.text('Sua coleção ainda está vazia'), findsOneWidget);
      expect(find.byType(JogoCard), findsNothing);
      // A ação nomeada existe: a tela não fica só em branco.
      expect(find.text('Registrar jogo'), findsOneWidget);
    });

    testWidgets('carregar exemplos preenche a lista e some com o vazio', (
      tester,
    ) async {
      await montarApp(tester);

      await tester.tap(find.text('Experimentar coleção de exemplo'));
      await tester.pumpAndSettle();

      expect(find.byType(EstadoVazio), findsNothing);
      expect(find.byType(JogoCard), findsWidgets);
      expect(find.text('Hollow Knight'), findsOneWidget);
    });

    testWidgets('a lista reflete a coleção: um cartão por jogo', (
      tester,
    ) async {
      await montarApp(
        tester,
        jogos: [jogoDe('Alpha'), jogoDe('Beta'), jogoDe('Gama')],
      );
      expect(find.byType(JogoCard), findsNWidgets(3));
    });

    testWidgets('busca sem resultado mostra o vazio de filtro', (tester) async {
      await montarApp(tester, jogos: [jogoDe('Alpha')]);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();

      expect(find.byType(JogoCard), findsNothing);
      expect(find.text('Nada por aqui'), findsOneWidget);

      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();
      expect(find.byType(JogoCard), findsOneWidget);
    });

    testWidgets('filtro por situação mostra só os jogos daquela situação', (
      tester,
    ) async {
      await montarApp(
        tester,
        jogos: [
          jogoDe('Alpha', status: StatusJogo.zerado, horas: 3),
          jogoDe('Beta', status: StatusJogo.jogando, horas: 3),
        ],
      );

      final chip = find.widgetWithText(ChoiceChip, 'Zerado (1)');
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsNothing);
    });
  });

  testWidgets('o Sobre lista os integrantes do grupo', (tester) async {
    await montarApp(tester);

    await tester.tap(find.byTooltip('Sobre o projeto'));
    await tester.pumpAndSettle();

    expect(find.text('Luiz Ragi'), findsOneWidget);
    expect(find.text('Israel Messias'), findsOneWidget);
    expect(find.text('Adalbert'), findsOneWidget);
  });

  group('detalhe', () {
    testWidgets('tocar no cartão abre o detalhe do mesmo jogo', (tester) async {
      await montarApp(
        tester,
        jogos: [
          jogoDe('Alpha'),
          jogoDe(
            'O Hobbit',
            plataforma: Plataforma.xbox,
            genero: 'Aventura',
            status: StatusJogo.jogando,
            nota: 4,
            horas: 12,
            observacoes: 'Livro melhor.',
          ),
        ],
      );

      await tester.tap(find.text('O Hobbit'));
      await tester.pumpAndSettle();

      expect(find.text('Detalhes'), findsOneWidget);
      expect(find.text('O Hobbit'), findsOneWidget);
      expect(find.text('Xbox'), findsOneWidget);
      expect(find.text('12 h'), findsOneWidget);
      expect(find.text('Livro melhor.'), findsOneWidget);
      // O outro jogo não vaza para esta tela.
      expect(find.text('Alpha'), findsNothing);
    });

    testWidgets('mudar a situação no detalhe atualiza o jogo certo', (
      tester,
    ) async {
      final a = jogoDe('Alpha');
      final b = jogoDe('Beta');
      final acervo = await montarApp(tester, jogos: [a, b]);

      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Jogando'));
      await tester.pumpAndSettle();

      expect(acervo.porId(b.id)!.status, StatusJogo.jogando);
      expect(acervo.porId(a.id)!.status, StatusJogo.queroJogar);
    });

    testWidgets('excluir pede confirmação e permite desfazer', (tester) async {
      final acervo = await montarApp(tester, jogos: [jogoDe('Alpha')]);

      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Excluir jogo'));
      await tester.pumpAndSettle();
      expect(find.text('Excluir jogo?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
      await tester.pumpAndSettle();
      expect(acervo.vazio, isTrue);

      await tester.tap(find.text('Desfazer'));
      await tester.pumpAndSettle();
      expect(acervo.todos.map((j) => j.titulo), ['Alpha']);
    });
  });

  group('dois espaços de tela', () {
    final jogos = [
      for (final n in ['A', 'B', 'C', 'D']) jogoDe('Jogo $n'),
    ];

    testWidgets('390 px usa uma coluna', (tester) async {
      await montarApp(tester, jogos: jogos, tamanho: const Size(390, 844));

      final xs = {
        for (final e in tester.elementList(find.byType(JogoCard)))
          tester.getTopLeft(find.byWidget(e.widget)).dx.round(),
      };
      expect(xs.length, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('840 px usa duas colunas na mesma ordem de leitura', (
      tester,
    ) async {
      await montarApp(tester, jogos: jogos, tamanho: const Size(840, 900));

      final cartoes = tester.elementList(find.byType(JogoCard)).toList();
      final xs = {
        for (final e in cartoes)
          tester.getTopLeft(find.byWidget(e.widget)).dx.round(),
      };
      expect(xs.length, 2);

      // A ordem de leitura continua: esquerda, direita, depois a linha de baixo.
      final pos = [
        for (final e in cartoes) tester.getTopLeft(find.byWidget(e.widget)),
      ];
      expect(pos[0].dx, lessThan(pos[1].dx));
      expect(pos[2].dy, greaterThan(pos[0].dy));
      expect(tester.takeException(), isNull);
    });

    testWidgets('título muito longo é cortado com reticências, sem overflow', (
      tester,
    ) async {
      await montarApp(
        tester,
        jogos: [
          jogoDe(
            'Um título absurdamente comprido para testar o corte no cartão do catálogo',
            status: StatusJogo.zerado,
            nota: 5,
            horas: 9999,
          ),
        ],
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('texto ampliado a 200% não estoura o layout', (tester) async {
      await montarApp(
        tester,
        jogos: [
          jogoDe(
            'Um título bem comprido para forçar quebra de linha no cartão',
            status: StatusJogo.jogando,
            nota: 4,
            horas: 120,
          ),
        ],
        escalaTexto: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
