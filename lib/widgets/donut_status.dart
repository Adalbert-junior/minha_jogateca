import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/jogo.dart';
import '../state/acervo.dart';
import '../theme/app_theme.dart';

/// Rosca com a divisão do catálogo por situação, mais a legenda ao lado.
class DonutStatus extends StatelessWidget {
  const DonutStatus({super.key, required this.resumo});

  final Resumo resumo;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;
    final fatias = [
      for (final s in StatusJogo.values)
        (cor: AppTheme.corDoStatus(context, s), valor: resumo.quantos(s)),
    ];
    final descricao = StatusJogo.values
        .map((s) => '${s.rotulo}: ${resumo.quantos(s)}')
        .join(', ');

    return Semantics(
      label: 'Jogos por situação. $descricao',
      excludeSemantics: true,
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 148,
            height: 148,
            child: CustomPaint(
              painter: _DonutPainter(fatias, cores.outlineVariant),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${resumo.total}', style: texto.headlineMedium),
                    Text(
                      resumo.total == 1 ? 'jogo' : 'jogos',
                      style: texto.bodyMedium?.copyWith(
                        color: cores.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in StatusJogo.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.corDoStatus(context, s),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${s.rotulo}  ', style: texto.bodyLarge),
                      Text(
                        '${resumo.quantos(s)}',
                        style: texto.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.fatias, this.corTrilho);

  final List<({Color cor, int valor})> fatias;
  final Color corTrilho;

  @override
  void paint(Canvas canvas, Size size) {
    final espessura = size.shortestSide * 0.16;
    final area = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - espessura / 2,
    );
    final tinta = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = espessura
      ..strokeCap = StrokeCap.butt;

    final total = fatias.fold(0, (soma, f) => soma + f.valor);
    if (total == 0) {
      canvas.drawArc(area, 0, 2 * math.pi, false, tinta..color = corTrilho);
      return;
    }

    const folga = 0.05;
    var inicio = -math.pi / 2;
    for (final f in fatias.where((f) => f.valor > 0)) {
      final varredura = 2 * math.pi * f.valor / total;
      final uma = fatias.where((x) => x.valor > 0).length == 1;
      canvas.drawArc(
        area,
        inicio + (uma ? 0 : folga / 2),
        uma ? varredura : math.max(varredura - folga, 0.01),
        false,
        tinta..color = f.cor,
      );
      inicio += varredura;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter antigo) =>
      antigo.fatias != fatias || antigo.corTrilho != corTrilho;
}
