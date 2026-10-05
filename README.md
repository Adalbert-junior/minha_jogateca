# Minha Jogoteca

Coleção pessoal de jogos, feita em Flutter. Você cadastra os jogos que quer jogar,
está jogando ou já zerou, dá nota, anota o que achou e acompanha tudo num painel.

Trabalho final de **Desenvolvimento Mobile I** (Unilavras, 2º semestre de 2026).

**Autor:**  Adalber Raczkovi Junior.



## O que o app faz

- **Catálogo** em lista (celular) ou grade de duas colunas (tela larga), com busca por
  título, gênero ou plataforma, filtro por situação e quatro ordenações.
 - **Detalhe** do jogo tocado, com troca rápida de situação.
- **Estado vazio** com ação clara: cadastrar o primeiro jogo ou carregar uma coleção de exemplo.
- **Formulário único** para cadastrar e editar, com validação (título obrigatório, sem
  título repetido na mesma plataforma, horas coerentes com a situação). Cancelar não altera nada.
- **Excluir** com confirmação no detalhe, ou deslizando o cartão, sempre com "Desfazer".

### Além do que o enunciado pede

-
- **Roleta do backlog:** sorteia o próximo jogo entre os marcados como "Quero jogar".
- **Conquistas** liberadas conforme a coleção cresce (recalculadas, nunca gravadas).
- **Capas geradas** a partir do título: mesma entrada, mesma capa, sem baixar imagem nenhuma.
- **Persistência local:** os dados ficam no aparelho e sobrevivem ao fechar o app.
-

Sincronização entre aparelhos, login e backend ficam como evolução para o Mobile II.

## Como rodar

Precisa do Flutter 3.47 ou mais novo (Dart 3.13). Não há chave de API nem serviço externo.

```bash
flutter pub get
flutter test
flutter run
```

APK de release:

```bash
flutter build apk --release
# saída: build/app/outputs/flutter-apk/app-release.apk
```

Versão web:

```bash
flutter build web --release
# saída: build/web
```

## Como o código está organizado

```
lib/
  models/     Jogo (com id), enums de situação/plataforma e as conquistas
  data/       Repositorio (interface), versão em memória e versão local, exemplos
  state/      Acervo (coleção + busca/filtro/ordem) e ModoTema
  pages/      lista, detalhe, formulário, painel e os fluxos de navegação
  widgets/    JogoCard, EstadoVazio, CapaJogo, NotaEstrelas, StatusTag, rosca...
  theme/      paleta clara/escura e temas dos componentes
test/         modelo, estado, telas, formulário, painel e acessibilidade
```


## Acessibilidade

Rótulos persistentes em todos os campos, tooltip em todo botão só com ícone, cartões lidos
como um botão com descrição completa ("Hades, PC, Jogando, nota 4 de 5, 31 horas jogadas"),
áreas de toque de pelo menos 48 px, informação nunca só por cor (ícone e texto repetem a
situação) e animações reduzidas quando o sistema pede. Os testes conferem as diretrizes de
área de toque, rótulo e contraste do Flutter nos dois temas, e verificam a razão de contraste
das paletas.


