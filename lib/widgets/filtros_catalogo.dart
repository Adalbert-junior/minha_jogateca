import 'package:flutter/material.dart';

import '../models/jogo.dart';
import '../state/acervo.dart';

/// Busca, filtro por situação e ordenação da lista.
class FiltrosCatalogo extends StatefulWidget {
  const FiltrosCatalogo({super.key, required this.acervo});

  final Acervo acervo;

  @override
  State<FiltrosCatalogo> createState() => _FiltrosCatalogoState();
}

class _FiltrosCatalogoState extends State<FiltrosCatalogo> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.acervo.busca,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final acervo = widget.acervo;
    final resumo = acervo.resumo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: acervo.definirBusca,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Pesquisar na coleção',
                  hintText: 'Título, gênero ou plataforma',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar busca',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _controller.clear();
                            acervo.definirBusca('');
                            setState(() {});
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<Ordenacao>(
              tooltip: 'Ordenar: ${acervo.ordenacao.rotulo}',
              icon: const Icon(Icons.sort),
              initialValue: acervo.ordenacao,
              onSelected: acervo.definirOrdenacao,
              itemBuilder: (_) => [
                for (final o in Ordenacao.values)
                  PopupMenuItem(value: o, child: Text(o.rotulo)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text('Todos (${resumo.total})'),
                selected: acervo.filtro == null,
                onSelected: (_) => acervo.definirFiltro(null),
              ),
              for (final status in StatusJogo.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('${status.rotulo} (${resumo.quantos(status)})'),
                  selected: acervo.filtro == status,
                  onSelected: (_) => acervo.definirFiltro(
                    acervo.filtro == status ? null : status,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
