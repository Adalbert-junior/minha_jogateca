import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'data/repositorio.dart';
import 'state/acervo.dart';
import 'state/modo_tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // As fontes empacotadas são OFL; registrá-las faz a licença aparecer na tela
  // "Ver licenças" do diálogo Sobre.
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      ['Chakra Petch', 'Barlow'],
      'Fontes distribuídas sob a SIL Open Font License, versão 1.1.\n'
      'https://openfontlicense.org',
    );
  });

  final acervo = Acervo(RepositorioLocal());
  final tema = ModoTema();
  await Future.wait([acervo.carregar(), tema.carregar()]);

  runApp(JogotecaApp(acervo: acervo, tema: tema));
}
