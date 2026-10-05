import 'package:flutter/material.dart';

import '../models/jogo.dart';
import '../state/acervo.dart';
import '../theme/app_theme.dart';
import '../widgets/capa_jogo.dart';
import '../widgets/nota_estrelas.dart';
import '../widgets/status_tag.dart';
import 'fluxos.dart';

/// Detalhe de um jogo. Recebe só o id e lê o jogo do [Acervo], então uma
/// edição ou troca de situação aparece aqui na hora.
class DetalhePage extends StatelessWidget {
  const DetalhePage({super.key, required this.jogoId});

  final String jogoId;

  @override
  Widget build(BuildContext context) {
    final acervo = AcervoScope.of(context);
    final jogo = acervo.porId(jogoId);

    // O jogo pode sumir enquanto esta tela está aberta (exclusão em outra
    // parte do app); nesse caso não há o que mostrar.
    if (jogo == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: [
          IconButton(
            tooltip: 'Editar jogo',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => editarJogo(context, jogo),
          ),
          IconButton(
            tooltip: 'Excluir jogo',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmarExclusao(context, jogo),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, restricoes) {
            final largo = restricoes.maxWidth >= 720;
            final capa = Hero(
              tag: 'capa-${jogo.id}',
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: CapaJogo(titulo: jogo.titulo, raio: 24),
              ),
            );
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: largo
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 300, child: capa),
                            const SizedBox(width: 32),
                            Expanded(child: _Informacoes(jogo: jogo)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: SizedBox(width: 200, child: capa)),
                            const SizedBox(height: 24),
                            _Informacoes(jogo: jogo),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao(BuildContext context, Jogo jogo) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Excluir jogo?'),
        content: Text('“${jogo.titulo}” sai do seu catálogo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogo).pop(true),
            style: FilledButton.styleFrom(
              minimumSize: const Size(96, 48),
              backgroundColor: Theme.of(dialogo).colorScheme.error,
              foregroundColor: Theme.of(dialogo).colorScheme.onError,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true || !context.mounted) return;
    excluirComDesfazer(context, jogo);
    Navigator.of(context).pop();
  }
}

class _Informacoes extends StatelessWidget {
  const _Informacoes({required this.jogo});

  final Jogo jogo;

  @override
  Widget build(BuildContext context) {
    final acervo = AcervoScope.of(context);
    final texto = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(jogo.titulo, style: texto.headlineMedium),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusTag(status: jogo.status),
            NotaEstrelas(nota: jogo.nota, tamanho: 22),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _Dado(
              icone: Icons.devices_outlined,
              rotulo: 'Plataforma',
              valor: jogo.plataforma.rotulo,
            ),
            _Dado(
              icone: Icons.category_outlined,
              rotulo: 'Gênero',
              valor: jogo.genero,
            ),
            _Dado(
              icone: Icons.timer_outlined,
              rotulo: 'Tempo jogado',
              valor: jogo.horas == 0 ? '—' : '${jogo.horas} h',
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Situação', style: texto.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in StatusJogo.values)
              ChoiceChip(
                avatar: Icon(
                  AppTheme.iconeDoStatus(s),
                  size: 18,
                  color: jogo.status == s
                      ? cores.onPrimaryContainer
                      : AppTheme.corDoStatus(context, s),
                ),
                label: Text(s.rotulo),
                selected: jogo.status == s,
                showCheckmark: false,
                onSelected: (_) {
                  if (jogo.status == s) return;
                  acervo.atualizar(jogo.copyWith(status: s));
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Anotações', style: texto.titleSmall),
        const SizedBox(height: 8),
        Text(
          jogo.observacoes.isEmpty
              ? 'Nenhuma anotação ainda. Use “Editar” para registrar o que achou.'
              : jogo.observacoes,
          style: texto.bodyLarge?.copyWith(
            color: jogo.observacoes.isEmpty
                ? cores.onSurfaceVariant
                : cores.onSurface,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Adicionado em ${_data(jogo.adicionadoEm)}',
          style: texto.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => editarJogo(context, jogo),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar jogo'),
        ),
      ],
    );
  }

  static String _data(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _Dado extends StatelessWidget {
  const _Dado({required this.icone, required this.rotulo, required this.valor});

  final IconData icone;
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;
    return Expanded(
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, size: 20, color: cores.onSurfaceVariant),
            const SizedBox(height: 6),
            Text(
              rotulo,
              style: texto.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
            ),
            Text(
              valor,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: texto.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
