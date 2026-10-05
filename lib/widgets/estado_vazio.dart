import 'package:flutter/material.dart';

/// Mensagem exibida quando não há nada para mostrar. É usada em dois casos:
/// catálogo sem nenhum jogo e busca/filtro sem resultado. Só muda o texto e
/// as ações, por isso virou widget.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    this.acoes = const [],
  });

  final IconData icone;
  final String titulo;
  final String mensagem;
  final List<Widget> acoes;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cores.primaryContainer,
                    boxShadow: [
                      BoxShadow(
                        color: cores.primary.withValues(alpha: 0.28),
                        blurRadius: 40,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(icone, size: 52, color: cores.onPrimaryContainer),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: texto.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: texto.bodyLarge?.copyWith(color: cores.onSurfaceVariant),
              ),
              if (acoes.isNotEmpty) ...[
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: acoes,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
