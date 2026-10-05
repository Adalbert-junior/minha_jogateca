import 'package:flutter/material.dart';

import '../models/jogo.dart';
import '../theme/app_theme.dart';

/// Selo com ícone e texto. A informação nunca depende só da cor: o rótulo e o
/// ícone repetem o significado.
class StatusTag extends StatelessWidget {
  const StatusTag({super.key, required this.status});

  final StatusJogo status;

  @override
  Widget build(BuildContext context) {
    final cor = AppTheme.corDoStatus(context, status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cor.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppTheme.iconeDoStatus(status), size: 15, color: cor),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                status.rotulo,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
