# Minha Jogoteca

Coleção pessoal de jogos, feita em Flutter. Você cadastra os jogos que quer jogar,
está jogando ou já zerou, dá nota, anota o que achou e acompanha tudo num painel.

Trabalho final de **Desenvolvimento Mobile I** (Unilavras, 2º semestre de 2026).

**Autores da base:** Luiz Ragi, Israel Messias e Adalbert.

Esta variação do projeto Zerado preserva a estrutura e a lógica originais, com
personalização do nome e dos textos da interface. Alterações de apresentação
não representam uma implementação independente.

**Publicação:** esta variação ainda não tem endereço de implantação próprio.

## O que o app faz

- **Catálogo** em lista (celular) ou grade de duas colunas (tela larga), com busca por
  título, gênero ou plataforma, filtro por situação e quatro ordenações.
- **Estado vazio** com ação clara: cadastrar o primeiro jogo ou carregar uma coleção de exemplo.
- **Detalhe** do jogo tocado, com troca rápida de situação.
- **Formulário único** para cadastrar e editar, com validação (título obrigatório, sem
  título repetido na mesma plataforma, horas coerentes com a situação). Cancelar não altera nada.
- **Excluir** com confirmação no detalhe, ou deslizando o cartão, sempre com "Desfazer".

### Além do que o enunciado pede

- **Painel** com total de jogos, horas, nota média, taxa de conclusão, rosca por situação e
  horas por plataforma.
- **Roleta do backlog:** sorteia o próximo jogo entre os marcados como "Quero jogar".
- **Conquistas** liberadas conforme a coleção cresce (recalculadas, nunca gravadas).
- **Capas geradas** a partir do título: mesma entrada, mesma capa, sem baixar imagem nenhuma.
- **Persistência local:** os dados ficam no aparelho e sobrevivem ao fechar o app.
- **Tema escuro, claro ou do sistema**, e versão web instalável (PWA).
- **Copiar resumo** do backlog para colar numa conversa.

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

Algumas decisões:

- **A identidade de um jogo é o `id`, não o título.** Editar troca o item de mesmo id
  (`indexWhere` + substituição), então dois jogos com o mesmo nome em plataformas diferentes
  nunca se confundem e a edição nunca duplica.
- **Um formulário só** serve para criar e editar: recebe o jogo (ou não) e devolve o resultado
  pelo `pop`. Quem chamou decide o que fazer, e cancelar devolve `null`.
- **`EstadoVazio` e `JogoCard` são reutilizados**: o primeiro aparece no catálogo vazio e na busca
  sem resultado; o segundo na lista e na roleta do painel.
- **O estado é um `ChangeNotifier`** entregue por um `InheritedNotifier`, sem pacote de gerência
  de estado. O app é pequeno e isso deixa o fluxo fácil de acompanhar.

## Acessibilidade

Rótulos persistentes em todos os campos, tooltip em todo botão só com ícone, cartões lidos
como um botão com descrição completa ("Hades, PC, Jogando, nota 4 de 5, 31 horas jogadas"),
áreas de toque de pelo menos 48 px, informação nunca só por cor (ícone e texto repetem a
situação) e animações reduzidas quando o sistema pede. Os testes conferem as diretrizes de
área de toque, rótulo e contraste do Flutter nos dois temas, e verificam a razão de contraste
das paletas.

## Fontes e recursos externos

- Documentação oficial do Flutter e do Dart (formulários, layout, testes e acessibilidade).
- Pacotes: `shared_preferences`, `flutter_localizations` e `cupertino_icons`.
- Fontes **Chakra Petch** e **Barlow**, sob a SIL Open Font License 1.1.
- Ícones do Material Icons.
- As capas e a logo são desenhadas em código, sem imagens de terceiros.

## Alterações desta versão

- Nome visível: Minha Jogoteca (Flutter, Android e web).
- Textos de cadastro, pesquisa, estado vazio e escolha do próximo jogo.
- Nome do pacote Dart e imports dos testes atualizados em conjunto.
- Telas, modelos, regras, persistência e créditos mantidos.

## Verificação desta entrega

Foi conferida a integridade do ZIP, a correspondência dos imports locais e dos
imports do pacote renomeado, além da consistência do nome no manifesto web.
Flutter e Dart não estavam disponíveis no ambiente de preparação: os testes,
a análise estática e a compilação não foram executados nesta versão.

Para verificar no seu computador, com Flutter instalado:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

## Enviar ao GitHub

Extraia o ZIP, abra a pasta `minha_jogoteca` e envie seu conteúdo à raiz do
repositório (incluindo `lib`, `test`, `android`, `web` e os arquivos de
configuração). Pelo GitHub Desktop, selecione a pasta como repositório local,
faça o commit e use Publish repository. Enviar apenas o ZIP ao GitHub não
disponibiliza os arquivos como código navegável.
