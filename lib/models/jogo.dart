/// Situação de um jogo dentro do backlog.
enum StatusJogo {
  queroJogar('Quero jogar'),
  jogando('Jogando'),
  zerado('Zerado'),
  abandonado('Abandonado');

  const StatusJogo(this.rotulo);

  final String rotulo;

  static StatusJogo daChave(String? chave) => StatusJogo.values.firstWhere(
    (s) => s.name == chave,
    orElse: () => StatusJogo.queroJogar,
  );
}

enum Plataforma {
  pc('PC'),
  playstation('PlayStation'),
  xbox('Xbox'),
  nintendo('Nintendo'),
  mobile('Mobile');

  const Plataforma(this.rotulo);

  final String rotulo;

  static Plataforma daChave(String? chave) => Plataforma.values.firstWhere(
    (p) => p.name == chave,
    orElse: () => Plataforma.pc,
  );
}

const generos = <String>[
  'Ação',
  'Aventura',
  'RPG',
  'Estratégia',
  'Esporte',
  'Corrida',
  'Luta',
  'Terror',
  'Puzzle',
  'Indie',
  'Simulação',
];

int _contador = 0;

/// Um jogo do catálogo. O [id] é a identidade: editar um jogo gera uma cópia
/// com o mesmo id, nunca um item novo.
class Jogo {
  const Jogo({
    required this.id,
    required this.titulo,
    required this.plataforma,
    required this.genero,
    required this.status,
    required this.adicionadoEm,
    this.nota = 0,
    this.horas = 0,
    this.observacoes = '',
  });

  /// Cria um jogo novo, já com um id inédito.
  factory Jogo.novo({
    required String titulo,
    required Plataforma plataforma,
    required String genero,
    required StatusJogo status,
    int nota = 0,
    int horas = 0,
    String observacoes = '',
    DateTime? adicionadoEm,
  }) {
    final agora = DateTime.now();
    _contador++;
    return Jogo(
      id: '${agora.microsecondsSinceEpoch}-$_contador',
      titulo: titulo,
      plataforma: plataforma,
      genero: genero,
      status: status,
      adicionadoEm: adicionadoEm ?? agora,
      nota: nota,
      horas: horas,
      observacoes: observacoes,
    );
  }

  factory Jogo.deJson(Map<String, dynamic> json) => Jogo(
    id: json['id'] as String,
    titulo: json['titulo'] as String,
    plataforma: Plataforma.daChave(json['plataforma'] as String?),
    genero: (json['genero'] as String?) ?? generos.first,
    status: StatusJogo.daChave(json['status'] as String?),
    adicionadoEm:
        DateTime.tryParse((json['adicionadoEm'] as String?) ?? '') ??
        DateTime.now(),
    nota: (json['nota'] as num?)?.toInt() ?? 0,
    horas: (json['horas'] as num?)?.toInt() ?? 0,
    observacoes: (json['observacoes'] as String?) ?? '',
  );

  final String id;
  final String titulo;
  final Plataforma plataforma;
  final String genero;
  final StatusJogo status;
  final DateTime adicionadoEm;

  /// De 1 a 5; 0 significa "sem nota".
  final int nota;
  final int horas;
  final String observacoes;

  bool get temNota => nota > 0;

  Jogo copyWith({
    String? titulo,
    Plataforma? plataforma,
    String? genero,
    StatusJogo? status,
    int? nota,
    int? horas,
    String? observacoes,
  }) => Jogo(
    id: id,
    titulo: titulo ?? this.titulo,
    plataforma: plataforma ?? this.plataforma,
    genero: genero ?? this.genero,
    status: status ?? this.status,
    adicionadoEm: adicionadoEm,
    nota: nota ?? this.nota,
    horas: horas ?? this.horas,
    observacoes: observacoes ?? this.observacoes,
  );

  Map<String, dynamic> paraJson() => {
    'id': id,
    'titulo': titulo,
    'plataforma': plataforma.name,
    'genero': genero,
    'status': status.name,
    'adicionadoEm': adicionadoEm.toIso8601String(),
    'nota': nota,
    'horas': horas,
    'observacoes': observacoes,
  };

  /// Descrição falada por leitores de tela.
  String get descricaoFalada {
    final partes = [
      titulo,
      plataforma.rotulo,
      status.rotulo,
      if (temNota) 'nota $nota de 5',
      if (horas > 0) horas == 1 ? '1 hora jogada' : '$horas horas jogadas',
    ];
    return partes.join(', ');
  }
}
