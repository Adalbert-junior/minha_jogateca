import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/conquistas.dart';
import '../models/jogo.dart';
import '../state/acervo.dart';
import '../widgets/donut_status.dart';
import '../widgets/roleta_backlog.dart';
import 'fluxos.dart';

/// Texto pronto para colar em qualquer conversa.
String montarResumoTexto(List<Jogo> jogos, Resumo resumo) {
  final media = resumo.mediaNota == null
      ? 'sem notas'
      : 'nota média ${_decimal(resumo.mediaNota!)}';
  final linhas = [
    'Minha Jogoteca — minha coleção',
    '${_contagem(resumo.total, 'jogo', 'jogos')} · '
        '${_contagem(resumo.quantos(StatusJogo.zerado), 'zerado', 'zerados')} · '
        '${resumo.horas} h jogadas · $media',
  ];
  for (final status in StatusJogo.values) {
    final nomes = jogos
        .where((j) => j.status == status)
        .map((j) => j.titulo)
        .toList();
    if (nomes.isNotEmpty) linhas.add('${status.rotulo}: ${nomes.join(', ')}');
  }
  return linhas.join('\n');
}

String _contagem(int n, String singular, String plural) =>
    '$n ${n == 1 ? singular : plural}';

String _decimal(double valor) => valor.toStringAsFixed(1).replaceAll('.', ',');

class PainelPage extends StatelessWidget {
  const PainelPage({super.key, this.random});

  /// Permite testes fixarem o sorteio da roleta.
  final Random? random;

  @override
  Widget build(BuildContext context) {
    final acervo = AcervoScope.of(context);
    final resumo = acervo.resumo;
    final texto = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Painel')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                _Numeros(resumo: resumo),
                const SizedBox(height: 24),
                Text('Por situação', style: texto.titleLarge),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: DonutStatus(resumo: resumo),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Horas por plataforma', style: texto.titleLarge),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _BarrasPlataforma(resumo: resumo),
                  ),
                ),
                const SizedBox(height: 24),
                RoletaBacklog(
                  acervo: acervo,
                  random: random,
                  aoAbrir: (jogo) => abrirDetalhe(context, jogo),
                ),
                const SizedBox(height: 24),
                _Conquistas(jogos: acervo.todos),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: acervo.vazio
                      ? null
                      : () async {
                          await Clipboard.setData(
                            ClipboardData(
                              text: montarResumoTexto(acervo.todos, resumo),
                            ),
                          );
                          if (context.mounted) {
                            mostrarAviso(
                              context,
                              'Resumo copiado para a área de transferência',
                            );
                          }
                        },
                  icon: const Icon(Icons.copy_all_outlined),
                  label: const Text('Copiar resumo da coleção'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Numeros extends StatelessWidget {
  const _Numeros({required this.resumo});

  final Resumo resumo;

  @override
  Widget build(BuildContext context) {
    final itens = [
      (Icons.sports_esports_outlined, '${resumo.total}', 'jogos no catálogo'),
      (Icons.timer_outlined, '${resumo.horas} h', 'jogadas no total'),
      (
        Icons.star_outline_rounded,
        resumo.mediaNota == null ? '—' : _decimal(resumo.mediaNota!),
        'nota média',
      ),
      (
        Icons.flag_outlined,
        '${(resumo.taxaDeConclusao * 100).round()}%',
        'dos iniciados, zerados',
      ),
    ];

    return LayoutBuilder(
      builder: (context, restricoes) {
        final colunas = restricoes.maxWidth >= 640 ? 4 : 2;
        final largura = (restricoes.maxWidth - 12 * (colunas - 1)) / colunas;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (icone, valor, rotulo) in itens)
              SizedBox(
                width: largura,
                child: Semantics(
                  label: '$valor $rotulo',
                  excludeSemantics: true,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            icone,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            valor,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            rotulo,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BarrasPlataforma extends StatelessWidget {
  const _BarrasPlataforma({required this.resumo});

  final Resumo resumo;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;
    final maior = resumo.horasPorPlataforma.values.fold(0, max);

    if (maior == 0) {
      return Text(
        'Registre horas jogadas para ver a comparação entre plataformas.',
        style: texto.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
      );
    }

    return Column(
      children: [
        for (final p in Plataforma.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Semantics(
              label: '${p.rotulo}: ${resumo.horasPorPlataforma[p] ?? 0} horas',
              excludeSemantics: true,
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(p.rotulo, style: texto.bodyLarge),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (resumo.horasPorPlataforma[p] ?? 0) / maior,
                        minHeight: 14,
                        backgroundColor: cores.surfaceContainerHighest,
                        color: cores.primary,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: Text(
                      '${resumo.horasPorPlataforma[p] ?? 0} h',
                      textAlign: TextAlign.end,
                      style: texto.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Conquistas extends StatelessWidget {
  const _Conquistas({required this.jogos});

  final List<Jogo> jogos;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;
    final liberadas = conquistas.where((c) => c.liberada(jogos)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conquistas  $liberadas/${conquistas.length}',
          style: texto.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final c in conquistas)
              _Selo(conquista: c, liberada: c.liberada(jogos), cores: cores),
          ],
        ),
      ],
    );
  }
}

class _Selo extends StatelessWidget {
  const _Selo({
    required this.conquista,
    required this.liberada,
    required this.cores,
  });

  final Conquista conquista;
  final bool liberada;
  final ColorScheme cores;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final destaque = liberada ? cores.primary : cores.onSurfaceVariant;
    return Semantics(
      label:
          '${conquista.titulo}, ${liberada ? 'liberada' : 'bloqueada'}. '
          '${conquista.descricao}',
      excludeSemantics: true,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: liberada ? cores.primaryContainer : cores.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: liberada ? cores.primary : cores.outlineVariant,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              liberada ? conquista.icone : Icons.lock_outline,
              color: liberada ? cores.onPrimaryContainer : destaque,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conquista.titulo,
                    style: texto.titleSmall?.copyWith(
                      color: liberada
                          ? cores.onPrimaryContainer
                          : cores.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conquista.descricao,
                    style: texto.bodyMedium?.copyWith(
                      fontSize: 13,
                      color: liberada
                          ? cores.onPrimaryContainer
                          : cores.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
