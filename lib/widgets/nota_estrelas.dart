import 'package:flutter/material.dart';

Color _corEstrela(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFFFB800)
    : const Color(0xFFB36B00);

/// Nota de 0 a 5. Sem [aoMudar] só exibe; com [aoMudar] cada estrela vira um
/// botão de 48 px, e tocar de novo na nota atual limpa a avaliação.
class NotaEstrelas extends StatelessWidget {
  const NotaEstrelas({
    super.key,
    required this.nota,
    this.aoMudar,
    this.tamanho = 18,
  });

  final int nota;
  final ValueChanged<int>? aoMudar;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final vazia = Theme.of(context).colorScheme.outline;

    if (aoMudar == null) {
      return Semantics(
        label: nota == 0 ? 'Sem nota' : 'Nota $nota de 5',
        excludeSemantics: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 1; i <= 5; i++)
              Icon(
                i <= nota ? Icons.star_rounded : Icons.star_outline_rounded,
                size: tamanho,
                color: i <= nota ? _corEstrela(context) : vazia,
              ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            onPressed: () => aoMudar!(i == nota ? 0 : i),
            tooltip: i == nota ? 'Limpar nota' : 'Dar nota $i',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            isSelected: i <= nota,
            icon: Icon(Icons.star_outline_rounded, size: 30, color: vazia),
            selectedIcon: Icon(
              Icons.star_rounded,
              size: 30,
              color: _corEstrela(context),
            ),
          ),
      ],
    );
  }
}
