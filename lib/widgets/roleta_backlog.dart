import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/jogo.dart';
import '../state/acervo.dart';
import 'capa_jogo.dart';

/// "Não sei o que jogar": sorteia um jogo entre os que estão como
/// "Quero jogar". O [random] pode ser trocado nos testes para o resultado ser
/// previsível.
class RoletaBacklog extends StatefulWidget {
  const RoletaBacklog({
    super.key,
    required this.acervo,
    required this.aoAbrir,
    this.random,
  });

  final Acervo acervo;
  final void Function(Jogo jogo) aoAbrir;
  final Random? random;

  @override
  State<RoletaBacklog> createState() => _RoletaBacklogState();
}

class _RoletaBacklogState extends State<RoletaBacklog> {
  late final Random _random = widget.random ?? Random();
  Timer? _timer;
  bool _girando = false;
  Jogo? _exibido;
  Jogo? _sorteado;

  List<Jogo> get _candidatos => widget.acervo.todos
      .where((j) => j.status == StatusJogo.queroJogar)
      .toList();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _sortear() {
    final candidatos = _candidatos;
    if (candidatos.isEmpty || _girando) return;
    final alvo = candidatos[_random.nextInt(candidatos.length)];

    // Quem pede menos movimento no sistema recebe o resultado direto.
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _exibido = _sorteado = alvo);
      return;
    }

    setState(() {
      _girando = true;
      _sorteado = null;
    });

    const voltas = 16;
    var passo = 0;
    void proximo() {
      if (!mounted) return;
      if (passo >= voltas) {
        setState(() {
          _girando = false;
          _exibido = _sorteado = alvo;
        });
        return;
      }
      setState(() => _exibido = candidatos[_random.nextInt(candidatos.length)]);
      passo++;
      // Cada volta demora um pouco mais que a anterior, como numa roleta.
      _timer = Timer(Duration(milliseconds: 40 + passo * 9), proximo);
    }

    proximo();
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;
    final candidatos = _candidatos;
    // Se o sorteado saiu da fila (mudou de situação), a vitrine é limpa.
    final exibido =
        _exibido != null && widget.acervo.porId(_exibido!.id) != null
        ? widget.acervo.porId(_exibido!.id)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Escolher próximo jogo', style: texto.titleLarge),
            const SizedBox(height: 4),
            Text(
              candidatos.isEmpty
                  ? 'Nenhum jogo marcado como “Quero jogar”. Cadastre alguns '
                        'para a roleta escolher por você.'
                  : 'Indecisão? Sorteie o próximo entre os '
                        '${candidatos.length} que estão na fila.',
              style: texto.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
            ),
            if (exibido != null) ...[
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                label: _girando
                    ? 'Sorteando'
                    : 'Sorteado: ${exibido.titulo}, ${exibido.plataforma.rotulo}',
                excludeSemantics: true,
                child: Row(
                  children: [
                    AnimatedScale(
                      scale: _girando ? 0.92 : 1,
                      duration: const Duration(milliseconds: 120),
                      child: SizedBox(
                        width: 72,
                        height: 96,
                        child: CapaJogo(titulo: exibido.titulo, raio: 12),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exibido.titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: texto.titleMedium?.copyWith(
                              color: _girando
                                  ? cores.onSurfaceVariant
                                  : cores.primary,
                            ),
                          ),
                          Text(
                            '${exibido.plataforma.rotulo} · ${exibido.genero}',
                            style: texto.bodyMedium?.copyWith(
                              color: cores.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: candidatos.isEmpty || _girando ? null : _sortear,
                  icon: const Icon(Icons.casino_outlined),
                  label: Text(
                    _sorteado == null ? 'Sortear' : 'Sortear de novo',
                  ),
                ),
                if (_sorteado != null && exibido != null) ...[
                  OutlinedButton(
                    onPressed: () {
                      widget.acervo.atualizar(
                        exibido.copyWith(status: StatusJogo.jogando),
                      );
                      setState(() => _sorteado = null);
                    },
                    child: const Text('Começar a jogar'),
                  ),
                  OutlinedButton(
                    onPressed: () => widget.aoAbrir(exibido),
                    child: const Text('Ver detalhes'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
