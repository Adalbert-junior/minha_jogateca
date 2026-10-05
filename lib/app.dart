import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/lista_page.dart';
import 'state/acervo.dart';
import 'state/modo_tema.dart';
import 'theme/app_theme.dart';

class JogotecaApp extends StatelessWidget {
  const JogotecaApp({super.key, required this.acervo, required this.tema});

  final Acervo acervo;
  final ModoTema tema;

  @override
  Widget build(BuildContext context) {
    // O AcervoScope fica acima do MaterialApp para que as rotas empilhadas
    // (detalhe, formulário, painel) também enxerguem a coleção.
    return AcervoScope(
      acervo: acervo,
      child: ListenableBuilder(
        listenable: tema,
        builder: (context, _) => MaterialApp(
          title: 'Minha Jogoteca',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.escuro,
          themeMode: tema.modo,
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: ListaPage(tema: tema),
        ),
      ),
    );
  }
}
