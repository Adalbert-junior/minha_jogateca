import 'package:flutter/material.dart';

const versaoDoApp = '1.0.0';

const integrantes = <String>['Luiz Ragi', 'Israel Messias', 'Adalbert'];

void mostrarSobre(BuildContext context) {
  final texto = Theme.of(context).textTheme;
  final cores = Theme.of(context).colorScheme;

  showAboutDialog(
    context: context,
    applicationName: 'Minha Jogoteca',
    applicationVersion: 'versão $versaoDoApp',
    applicationLegalese: 'Trabalho final de Desenvolvimento Mobile I\nUnilavras · 2º semestre de 2026',
    children: [
      const SizedBox(height: 16),
      Text('Feito por', style: texto.titleSmall),
      const SizedBox(height: 4),
      for (final nome in integrantes) Text(nome, style: texto.bodyLarge),
      const SizedBox(height: 16),
      Text(
        'Seus jogos ficam salvos só neste aparelho. Nada é enviado para a internet.',
        style: texto.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
      ),
    ],
  );
}
