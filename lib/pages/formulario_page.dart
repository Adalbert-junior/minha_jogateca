import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/jogo.dart';
import '../state/acervo.dart';
import '../widgets/capa_jogo.dart';
import '../widgets/nota_estrelas.dart';

/// Formulário único para cadastrar e editar. Com [jogo] ele abre preenchido e
/// preserva o id; sem [jogo] cria um jogo novo. Ao salvar devolve o [Jogo] pelo
/// `pop`; ao cancelar devolve null e quem chamou não altera nada.
class FormularioPage extends StatefulWidget {
  const FormularioPage({super.key, this.jogo});

  final Jogo? jogo;

  bool get edicao => jogo != null;

  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _chave = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _horas;
  late final TextEditingController _observacoes;

  late Plataforma _plataforma;
  late String _genero;
  late StatusJogo _status;
  late int _nota;

  @override
  void initState() {
    super.initState();
    final j = widget.jogo;
    _titulo = TextEditingController(text: j?.titulo ?? '');
    _horas = TextEditingController(
      text: j == null || j.horas == 0 ? '' : '${j.horas}',
    );
    _observacoes = TextEditingController(text: j?.observacoes ?? '');
    _plataforma = j?.plataforma ?? Plataforma.pc;
    _genero = j?.genero ?? generos.first;
    _status = j?.status ?? StatusJogo.queroJogar;
    _nota = j?.nota ?? 0;
    // O PopScope precisa saber, a cada tecla, se já existe algo a perder.
    for (final c in [_titulo, _horas, _observacoes]) {
      c.addListener(_reconstruir);
    }
  }

  void _reconstruir() => setState(() {});

  @override
  void dispose() {
    _titulo.dispose();
    _horas.dispose();
    _observacoes.dispose();
    super.dispose();
  }

  int get _horasDigitadas => int.tryParse(_horas.text.trim()) ?? 0;

  /// Algo mudou em relação ao que o formulário abriu?
  bool get _alterado {
    final j = widget.jogo;
    if (j == null) {
      return _titulo.text.trim().isNotEmpty ||
          _horas.text.trim().isNotEmpty ||
          _observacoes.text.trim().isNotEmpty ||
          _nota != 0 ||
          _status != StatusJogo.queroJogar ||
          _plataforma != Plataforma.pc ||
          _genero != generos.first;
    }
    return _titulo.text.trim() != j.titulo ||
        _horasDigitadas != j.horas ||
        _observacoes.text.trim() != j.observacoes ||
        _nota != j.nota ||
        _status != j.status ||
        _plataforma != j.plataforma ||
        _genero != j.genero;
  }

  String? _validarTitulo(String? valor) {
    final titulo = (valor ?? '').trim();
    if (titulo.isEmpty) return 'Informe o título';
    if (titulo.length > 60) return 'Use no máximo 60 caracteres';
    final acervo = AcervoScope.of(context);
    if (acervo.jaExiste(titulo, _plataforma, ignorarId: widget.jogo?.id)) {
      return 'Você já tem “$titulo” no ${_plataforma.rotulo}';
    }
    return null;
  }

  String? _validarHoras(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isNotEmpty) {
      final n = int.tryParse(texto);
      if (n == null || n < 0 || n > 9999) {
        return 'Digite as horas como número inteiro, de 0 a 9999';
      }
    }
    final n = int.tryParse(texto) ?? 0;
    if (_status == StatusJogo.queroJogar && n > 0) {
      return 'Quem ainda não começou não tem horas. Mude a situação.';
    }
    if (_status == StatusJogo.zerado && n == 0) {
      return 'Um jogo zerado tem pelo menos 1 hora';
    }
    return null;
  }

  void _salvar() {
    if (!_chave.currentState!.validate()) return;

    final titulo = _titulo.text.trim();
    final horas = _horasDigitadas;
    final observacoes = _observacoes.text.trim();
    // Quem ainda não jogou não tem o que avaliar.
    final nota = _status == StatusJogo.queroJogar ? 0 : _nota;

    final jogo = widget.jogo == null
        ? Jogo.novo(
            titulo: titulo,
            plataforma: _plataforma,
            genero: _genero,
            status: _status,
            nota: nota,
            horas: horas,
            observacoes: observacoes,
          )
        : widget.jogo!.copyWith(
            titulo: titulo,
            plataforma: _plataforma,
            genero: _genero,
            status: _status,
            nota: nota,
            horas: horas,
            observacoes: observacoes,
          );
    Navigator.of(context).pop(jogo);
  }

  Future<void> _cancelar() async {
    if (!_alterado) {
      Navigator.of(context).pop();
      return;
    }
    final descartar = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('O que você digitou nesta tela será perdido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogo).pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(96, 48)),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (descartar == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;

    return PopScope(
      // Se há algo digitado, o botão voltar também pergunta antes de sair.
      canPop: !_alterado,
      onPopInvokedWithResult: (jaSaiu, _) {
        if (!jaSaiu) _cancelar();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.edicao ? 'Editar jogo' : 'Adicionar jogo'),
          leading: IconButton(
            tooltip: 'Cancelar',
            icon: const Icon(Icons.close),
            onPressed: _cancelar,
          ),
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Form(
                key: _chave,
                // Depois do primeiro toque no campo, o erro some assim que for corrigido.
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    Center(
                      child: ListenableBuilder(
                        listenable: _titulo,
                        builder: (_, _) => SizedBox(
                          width: 110,
                          height: 146,
                          child: CapaJogo(titulo: _titulo.text, raio: 18),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        child: Text(
                          'A capa é gerada a partir do título',
                          style: texto.bodyMedium?.copyWith(
                            color: cores.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _titulo,
                      autofocus: !widget.edicao,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 60,
                      decoration: const InputDecoration(
                        labelText: 'Título do jogo',
                        hintText: 'Ex.: Hollow Knight',
                        counterText: '',
                      ),
                      validator: _validarTitulo,
                    ),
                    const SizedBox(height: 20),
                    _Grupo(
                      titulo: 'Plataforma',
                      filhos: [
                        for (final p in Plataforma.values)
                          ChoiceChip(
                            label: Text(p.rotulo),
                            selected: _plataforma == p,
                            onSelected: (_) => setState(() => _plataforma = p),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _genero,
                      decoration: const InputDecoration(labelText: 'Gênero'),
                      items: [
                        for (final g in generos)
                          DropdownMenuItem(value: g, child: Text(g)),
                      ],
                      onChanged: (g) => setState(() => _genero = g ?? _genero),
                    ),
                    const SizedBox(height: 20),
                    _Grupo(
                      titulo: 'Situação',
                      filhos: [
                        for (final s in StatusJogo.values)
                          ChoiceChip(
                            label: Text(s.rotulo),
                            selected: _status == s,
                            onSelected: (_) => setState(() {
                              _status = s;
                              if (s == StatusJogo.queroJogar) _nota = 0;
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _horas,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Horas jogadas',
                        hintText: '0',
                        suffixText: 'h',
                      ),
                      validator: _validarHoras,
                    ),
                    const SizedBox(height: 20),
                    Text('Nota', style: texto.titleSmall),
                    const SizedBox(height: 4),
                    if (_status == StatusJogo.queroJogar)
                      Text(
                        'Disponível depois que você começar a jogar.',
                        style: texto.bodyMedium?.copyWith(
                          color: cores.onSurfaceVariant,
                        ),
                      )
                    else
                      NotaEstrelas(
                        nota: _nota,
                        aoMudar: (n) => setState(() => _nota = n),
                      ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _observacoes,
                      maxLines: 4,
                      maxLength: 280,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Anotações (opcional)',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _cancelar,
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: _salvar,
                            icon: const Icon(Icons.check),
                            label: Text(
                              widget.edicao ? 'Salvar alterações' : 'Adicionar',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo({required this.titulo, required this.filhos});

  final String titulo;
  final List<Widget> filhos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: filhos),
      ],
    );
  }
}
