import 'package:flutter_test/flutter_test.dart';
import 'package:minha_jogoteca/data/repositorio.dart';
import 'package:minha_jogoteca/models/jogo.dart';
import 'package:minha_jogoteca/state/acervo.dart';

import 'ajudante.dart';

void main() {
  group('Jogo', () {
    test('cada jogo novo recebe um id diferente', () {
      final ids = {for (var i = 0; i < 200; i++) jogoDe('Jogo').id};
      expect(ids.length, 200);
    });

    test('copyWith mantém o id e a data de criação', () {
      final original = jogoDe('Celeste', horas: 5);
      final copia = original.copyWith(titulo: 'Celeste 2', horas: 9);
      expect(copia.id, original.id);
      expect(copia.adicionadoEm, original.adicionadoEm);
      expect(copia.titulo, 'Celeste 2');
      expect(copia.horas, 9);
    });

    test('vai para JSON e volta sem perder nada', () {
      final original = jogoDe(
        'Hades',
        plataforma: Plataforma.nintendo,
        status: StatusJogo.zerado,
        genero: 'Indie',
        nota: 4,
        horas: 31,
        observacoes: 'Ótimo',
      );
      final volta = Jogo.deJson(original.paraJson());
      expect(volta.id, original.id);
      expect(volta.titulo, 'Hades');
      expect(volta.plataforma, Plataforma.nintendo);
      expect(volta.status, StatusJogo.zerado);
      expect(volta.nota, 4);
      expect(volta.horas, 31);
      expect(volta.observacoes, 'Ótimo');
    });

    test('a descrição falada resume o que aparece no cartão', () {
      final j = jogoDe('Hades', status: StatusJogo.jogando, nota: 4, horas: 1);
      expect(
        j.descricaoFalada,
        'Hades, PC, Jogando, nota 4 de 5, 1 hora jogada',
      );
    });
  });

  group('Acervo', () {
    late Acervo acervo;
    late RepositorioMemoria repositorio;

    setUp(() async {
      repositorio = RepositorioMemoria();
      acervo = Acervo(repositorio);
      await acervo.carregar();
    });

    test('começa vazio depois de carregar', () {
      expect(acervo.carregado, isTrue);
      expect(acervo.vazio, isTrue);
    });

    test('adicionar coloca o jogo e grava no repositório', () async {
      acervo.adicionar(jogoDe('Duna'));
      expect(acervo.todos.map((j) => j.titulo), ['Duna']);
      expect((await repositorio.carregar()).length, 1);
    });

    test('atualizar troca só o jogo de mesmo id, sem duplicar', () {
      final a = jogoDe('Doom', plataforma: Plataforma.pc);
      final b = jogoDe('Doom', plataforma: Plataforma.xbox);
      acervo
        ..adicionar(a)
        ..adicionar(b);

      acervo.atualizar(b.copyWith(status: StatusJogo.zerado, horas: 12));

      expect(acervo.todos.length, 2);
      expect(acervo.porId(a.id)!.status, StatusJogo.queroJogar);
      expect(acervo.porId(b.id)!.status, StatusJogo.zerado);
    });

    test('atualizar um id que não existe não faz nada', () {
      acervo.adicionar(jogoDe('Doom'));
      acervo.atualizar(jogoDe('Outro'));
      expect(acervo.todos.length, 1);
    });

    test('remover devolve a posição e restaurar recoloca no mesmo lugar', () {
      final a = jogoDe('A');
      final b = jogoDe('B');
      final c = jogoDe('C');
      acervo.adicionarVarios([a, b, c]);

      final removido = acervo.remover(b.id)!;
      expect(acervo.todos.map((j) => j.titulo), ['A', 'C']);

      acervo.restaurar(removido.jogo, removido.indice);
      expect(acervo.todos.map((j) => j.titulo), ['A', 'B', 'C']);
    });

    test('jaExiste considera a plataforma e ignora o próprio item', () {
      final a = jogoDe('Doom', plataforma: Plataforma.pc);
      acervo.adicionar(a);

      expect(acervo.jaExiste('  doom ', Plataforma.pc), isTrue);
      expect(acervo.jaExiste('Doom', Plataforma.xbox), isFalse);
      expect(acervo.jaExiste('Doom', Plataforma.pc, ignorarId: a.id), isFalse);
    });

    test(
      'a busca ignora acento e caixa e olha título, gênero e plataforma',
      () {
        acervo.adicionarVarios([
          jogoDe('Ação Máxima', genero: 'Esporte'),
          jogoDe('Zelda', genero: 'Aventura', plataforma: Plataforma.nintendo),
        ]);

        acervo.definirBusca('acao');
        expect(acervo.visiveis.map((j) => j.titulo), ['Ação Máxima']);

        acervo.definirBusca('nintendo');
        expect(acervo.visiveis.map((j) => j.titulo), ['Zelda']);

        acervo.definirBusca('AVENTURA');
        expect(acervo.visiveis.map((j) => j.titulo), ['Zelda']);
      },
    );

    test('o filtro de situação e a ordenação funcionam juntos', () {
      acervo.adicionarVarios([
        jogoDe('B', status: StatusJogo.zerado, nota: 3, horas: 10),
        jogoDe('A', status: StatusJogo.zerado, nota: 5, horas: 2),
        jogoDe('C', status: StatusJogo.jogando, nota: 4, horas: 40),
      ]);

      acervo.definirFiltro(StatusJogo.zerado);
      acervo.definirOrdenacao(Ordenacao.titulo);
      expect(acervo.visiveis.map((j) => j.titulo), ['A', 'B']);

      acervo.definirOrdenacao(Ordenacao.nota);
      expect(acervo.visiveis.map((j) => j.titulo), ['A', 'B']);

      acervo.definirOrdenacao(Ordenacao.horas);
      expect(acervo.visiveis.map((j) => j.titulo), ['B', 'A']);
    });

    test('o resumo soma horas, conta situações e tira a média das notas', () {
      acervo.adicionarVarios([
        jogoDe('A', status: StatusJogo.zerado, nota: 5, horas: 10),
        jogoDe('B', status: StatusJogo.zerado, nota: 3, horas: 20),
        jogoDe('C', status: StatusJogo.jogando, horas: 5),
        jogoDe('D'),
      ]);

      final r = acervo.resumo;
      expect(r.total, 4);
      expect(r.horas, 35);
      expect(r.quantos(StatusJogo.zerado), 2);
      expect(r.mediaNota, 4);
      // 2 zerados entre 3 que foram iniciados (o "quero jogar" não conta).
      expect(r.taxaDeConclusao, closeTo(2 / 3, 1e-9));
    });

    test('sem nenhuma nota a média é nula em vez de zero', () {
      acervo.adicionar(jogoDe('A'));
      expect(acervo.resumo.mediaNota, isNull);
    });
  });
}
