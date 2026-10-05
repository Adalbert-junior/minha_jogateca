import 'package:flutter/material.dart';

import '../models/jogo.dart';
import 'capa_jogo.dart';
import 'nota_estrelas.dart';
import 'status_tag.dart';

/// Cartão de um jogo. Aparece na lista principal e no sorteio do painel, por
/// isso recebe só o [Jogo] e o que fazer ao tocar.
class JogoCard extends StatelessWidget {
  const JogoCard({
    super.key,
    required this.jogo,
    required this.aoAbrir,
    this.comHero = true,
  });

  final Jogo jogo;
  final VoidCallback aoAbrir;
  final bool comHero;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;

    Widget capa = SizedBox(
      width: 84,
      height: 108,
      child: CapaJogo(titulo: jogo.titulo, raio: 14),
    );
    if (comHero) capa = Hero(tag: 'capa-${jogo.id}', child: capa);

    return Semantics(
      button: true,
      label: jogo.descricaoFalada,
      onTapHint: 'Abrir detalhes',
      excludeSemantics: true,
      child: Card(
        child: InkWell(
          onTap: aoAbrir,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                capa,
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jogo.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: texto.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${jogo.plataforma.rotulo} · ${jogo.genero}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: texto.bodyMedium?.copyWith(
                          color: cores.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      StatusTag(status: jogo.status),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          NotaEstrelas(nota: jogo.nota, tamanho: 17),
                          const Spacer(),
                          if (jogo.horas > 0)
                            Text(
                              '${jogo.horas} h',
                              style: texto.bodyMedium?.copyWith(
                                color: cores.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
