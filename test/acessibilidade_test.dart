import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_jogoteca/models/jogo.dart';
import 'package:minha_jogoteca/theme/app_theme.dart';

import 'ajudante.dart';

double _luminancia(Color c) => c.computeLuminance();

double contraste(Color a, Color b) {
  final claro = _luminancia(a) > _luminancia(b) ? a : b;
  final escuro = identical(claro, a) ? b : a;
  return (_luminancia(claro) + 0.05) / (_luminancia(escuro) + 0.05);
}

void main() {
  setUpAll(carregarFontes);

  group('contraste das cores do tema (mínimo 4,5:1 para texto)', () {
    for (final (nome, tema) in [
      ('escuro', AppTheme.escuro),
      ('claro', AppTheme.claro),
    ]) {
      test('tema $nome: texto sobre as superfícies', () {
        final c = tema.colorScheme;
        final fundos = [
          c.surface,
          c.surfaceContainerLowest,
          c.surfaceContainer,
          c.surfaceContainerHigh,
        ];
        for (final fundo in fundos) {
          expect(contraste(c.onSurface, fundo), greaterThanOrEqualTo(4.5));
          expect(
            contraste(c.onSurfaceVariant, fundo),
            greaterThanOrEqualTo(4.5),
            reason: 'texto secundário sobre $fundo',
          );
        }
        expect(contraste(c.onPrimary, c.primary), greaterThanOrEqualTo(4.5));
        expect(
          contraste(c.onPrimaryContainer, c.primaryContainer),
          greaterThanOrEqualTo(4.5),
        );
        expect(contraste(c.error, c.surface), greaterThanOrEqualTo(4.5));
        expect(contraste(c.primary, c.surface), greaterThanOrEqualTo(4.5));
      });

      testWidgets('tema $nome: cores de situação legíveis nos cartões', (
        tester,
      ) async {
        late BuildContext contexto;
        await tester.pumpWidget(
          MaterialApp(
            theme: tema,
            home: Builder(
              builder: (c) {
                contexto = c;
                return const SizedBox();
              },
            ),
          ),
        );
        final fundo = tema.colorScheme.surfaceContainer;
        for (final s in StatusJogo.values) {
          final cor = AppTheme.corDoStatus(contexto, s);
          // A etiqueta pinta um véu de 14% da própria cor sobre o cartão.
          final etiqueta = Color.alphaBlend(cor.withValues(alpha: 0.14), fundo);
          expect(
            contraste(cor, etiqueta),
            greaterThanOrEqualTo(4.5),
            reason: '${s.rotulo} no tema $nome',
          );
        }
      });
    }
  });

  group('diretrizes de acessibilidade do Flutter', () {
    final jogos = [
      jogoDe(
        'Hades',
        status: StatusJogo.jogando,
        nota: 4,
        horas: 31,
        observacoes: 'Boa demais.',
      ),
      jogoDe('Celeste', status: StatusJogo.zerado, nota: 5, horas: 14),
    ];

    for (final modo in [ThemeMode.dark, ThemeMode.light]) {
      testWidgets('lista: áreas de toque, rótulos e contraste ($modo)', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await montarApp(tester, jogos: jogos, tema: modo);

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });

      testWidgets('formulário: áreas de toque, rótulos e contraste ($modo)', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await montarApp(
          tester,
          jogos: jogos,
          tema: modo,
          tamanho: const Size(420, 1500),
        );
        await tester.tap(find.text('Adicionar jogo'));
        await tester.pumpAndSettle();

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });

      testWidgets('detalhe: áreas de toque, rótulos e contraste ($modo)', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await montarApp(tester, jogos: jogos, tema: modo);
        await tester.tap(find.text('Hades'));
        await tester.pumpAndSettle();

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }

    testWidgets('o cartão é um botão com descrição falada completa', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await montarApp(tester, jogos: [jogos.first]);

      expect(
        find.bySemanticsLabel(
          'Hades, PC, Jogando, nota 4 de 5, 31 horas jogadas',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('botões só com ícone têm tooltip', (tester) async {
      await montarApp(tester, jogos: jogos);
      expect(find.byTooltip('Painel e estatísticas'), findsOneWidget);
      expect(find.byTooltip('Aparência do app'), findsOneWidget);
      expect(find.byTooltip('Ordenar: Mais recentes'), findsOneWidget);
    });
  });
}
