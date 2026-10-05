import '../models/jogo.dart';

/// Coleção de partida oferecida no estado vazio, para o app poder ser
/// explorado sem cadastrar tudo à mão. A ordem em que aparecem é a ordem em
/// que estão escritos aqui: cada um é "adicionado" um minuto antes do anterior.
List<Jogo> jogosDeExemplo() {
  final agora = DateTime.now();
  var posicao = 0;

  Jogo j(
    String titulo,
    Plataforma plataforma,
    String genero,
    StatusJogo status, {
    int nota = 0,
    int horas = 0,
    String observacoes = '',
  }) => Jogo.novo(
    titulo: titulo,
    plataforma: plataforma,
    genero: genero,
    status: status,
    nota: nota,
    horas: horas,
    observacoes: observacoes,
    adicionadoEm: agora.subtract(Duration(minutes: posicao++)),
  );

  return [
    j(
      'Hollow Knight',
      Plataforma.pc,
      'Aventura',
      StatusJogo.zerado,
      nota: 5,
      horas: 46,
      observacoes: 'Final verdadeiro feito. O Caminho da Dor quase me quebrou.',
    ),
    j(
      'Elden Ring',
      Plataforma.playstation,
      'RPG',
      StatusJogo.jogando,
      nota: 5,
      horas: 78,
      observacoes: 'Parado na Malenia. Preciso de uma build melhor.',
    ),
    j(
      'Celeste',
      Plataforma.nintendo,
      'Indie',
      StatusJogo.zerado,
      nota: 5,
      horas: 14,
    ),
    j(
      'Hades',
      Plataforma.pc,
      'Ação',
      StatusJogo.jogando,
      nota: 4,
      horas: 31,
      observacoes: 'Subindo o nível de calor aos poucos.',
    ),
    j(
      'Disco Elysium',
      Plataforma.pc,
      'RPG',
      StatusJogo.queroJogar,
      observacoes: 'Recomendação de um amigo do grupo.',
    ),
    j(
      'Resident Evil 4',
      Plataforma.playstation,
      'Terror',
      StatusJogo.queroJogar,
    ),
    j(
      'Stardew Valley',
      Plataforma.mobile,
      'Simulação',
      StatusJogo.abandonado,
      nota: 3,
      horas: 9,
      observacoes: 'Perdi o ritmo depois do primeiro inverno.',
    ),
    j(
      'EA Sports FC 26',
      Plataforma.xbox,
      'Esporte',
      StatusJogo.jogando,
      nota: 3,
      horas: 120,
    ),
  ];
}
