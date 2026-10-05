import 'package:flutter/material.dart';

import 'jogo.dart';

/// Selos que o app libera conforme a coleção cresce. Não são gravados: são
/// recalculados a partir dos jogos, então nunca ficam fora de sincronia.
class Conquista {
  const Conquista({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.liberada,
  });

  final String titulo;
  final String descricao;
  final IconData icone;
  final bool Function(List<Jogo> jogos) liberada;
}

int _horas(List<Jogo> jogos) => jogos.fold(0, (soma, j) => soma + j.horas);

final conquistas = <Conquista>[
  Conquista(
    titulo: 'Primeiro save',
    descricao: 'Cadastre seu primeiro jogo.',
    icone: Icons.save_outlined,
    liberada: (jogos) => jogos.isNotEmpty,
  ),
  Conquista(
    titulo: 'Zerou!',
    descricao: 'Termine um jogo.',
    icone: Icons.flag_outlined,
    liberada: (jogos) => jogos.any((j) => j.status == StatusJogo.zerado),
  ),
  Conquista(
    titulo: 'Colecionador',
    descricao: 'Tenha 10 jogos no catálogo.',
    icone: Icons.inventory_2_outlined,
    liberada: (jogos) => jogos.length >= 10,
  ),
  Conquista(
    titulo: 'Crítico',
    descricao: 'Dê nota máxima para um jogo.',
    icone: Icons.star_outline,
    liberada: (jogos) => jogos.any((j) => j.nota == 5),
  ),
  Conquista(
    titulo: 'Multiplataforma',
    descricao: 'Tenha jogos em 3 plataformas diferentes.',
    icone: Icons.devices_outlined,
    liberada: (jogos) => jogos.map((j) => j.plataforma).toSet().length >= 3,
  ),
  Conquista(
    titulo: 'Sem vida social',
    descricao: 'Some 100 horas jogadas.',
    icone: Icons.timer_outlined,
    liberada: (jogos) => _horas(jogos) >= 100,
  ),
  Conquista(
    titulo: 'Persistente',
    descricao: 'Tenha 5 jogos zerados.',
    icone: Icons.emoji_events_outlined,
    liberada: (jogos) =>
        jogos.where((j) => j.status == StatusJogo.zerado).length >= 5,
  ),
  Conquista(
    titulo: 'Sem julgamentos',
    descricao: 'Assuma um jogo abandonado.',
    icone: Icons.sentiment_neutral_outlined,
    liberada: (jogos) => jogos.any((j) => j.status == StatusJogo.abandonado),
  ),
];
