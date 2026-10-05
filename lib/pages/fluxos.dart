import 'package:flutter/material.dart';

import '../models/jogo.dart';
import '../state/acervo.dart';
import 'detalhe_page.dart';
import 'formulario_page.dart';

/// Os fluxos de navegação ficam aqui para que lista, detalhe e painel os
/// reaproveitem sem repetir a mesma sequência (abrir, esperar, aplicar).

void mostrarAviso(
  BuildContext context,
  String mensagem, {
  SnackBarAction? acao,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(mensagem), action: acao));
}

Future<void> cadastrarJogo(BuildContext context) async {
  final acervo = AcervoScope.of(context);
  final novo = await Navigator.of(context)
      .push<Jogo>(MaterialPageRoute(builder: (_) => const FormularioPage()));
  // Cancelar devolve null: a coleção não é tocada.
  if (novo == null || !context.mounted) return;
  acervo.adicionar(novo);
  mostrarAviso(context, '“${novo.titulo}” entrou no catálogo');
}

Future<void> editarJogo(BuildContext context, Jogo jogo) async {
  final acervo = AcervoScope.of(context);
  final editado = await Navigator.of(
    context,
  ).push<Jogo>(MaterialPageRoute(builder: (_) => FormularioPage(jogo: jogo)));
  if (editado == null || !context.mounted) return;
  acervo.atualizar(editado);
  mostrarAviso(context, '“${editado.titulo}” atualizado');
}

Future<void> abrirDetalhe(BuildContext context, Jogo jogo) {
  return Navigator.of(
    context,
  ).push<void>(MaterialPageRoute(builder: (_) => DetalhePage(jogoId: jogo.id)));
}

/// Remove o jogo e oferece desfazer. O aviso é mostrado pelo
/// [ScaffoldMessenger] raiz, então continua na tela mesmo que a página que
/// pediu a exclusão já tenha fechado.
void excluirComDesfazer(BuildContext context, Jogo jogo) {
  final acervo = AcervoScope.of(context);
  final removido = acervo.remover(jogo.id);
  if (removido == null) return;
  mostrarAviso(
    context,
    '“${jogo.titulo}” foi excluído',
    acao: SnackBarAction(
      label: 'Desfazer',
      onPressed: () => acervo.restaurar(removido.jogo, removido.indice),
    ),
  );
}
