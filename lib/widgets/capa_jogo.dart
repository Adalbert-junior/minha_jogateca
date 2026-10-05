import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Capa gerada a partir do título: o mesmo nome sempre produz as mesmas cores
/// e o mesmo desenho. Assim o catálogo tem "arte" sem baixar imagem nenhuma.
class CapaJogo extends StatelessWidget {
  const CapaJogo({super.key, required this.titulo, this.raio = 16});

  final String titulo;
  final double raio;

  static int _hash(String texto) {
    // Mantido abaixo de 2^31 para o resultado ser idêntico na web, onde
    // inteiros grandes perdem precisão.
    var h = 7;
    for (final unidade in texto.trim().toLowerCase().codeUnits) {
      h = (h * 31 + unidade) & 0x7FFFFFFF;
    }
    return h;
  }

  static String iniciais(String titulo) {
    final palavras = titulo
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (palavras.isEmpty) return '?';
    if (palavras.length == 1) {
      final p = palavras.first;
      return p.substring(0, math.min(2, p.length)).toUpperCase();
    }
    return (palavras[0][0] + palavras[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(raio),
        child: CustomPaint(
          painter: _CapaPainter(_hash(titulo)),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  iniciais(titulo),
                  style: TextStyle(
                    fontFamily: 'ChakraPetch',
                    fontWeight: FontWeight.w700,
                    fontSize: 44,
                    letterSpacing: 2,
                    color: Colors.white.withValues(alpha: 0.92),
                    shadows: const [
                      Shadow(color: Color(0x66000000), blurRadius: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CapaPainter extends CustomPainter {
  _CapaPainter(this.hash);

  final int hash;

  @override
  void paint(Canvas canvas, Size size) {
    final matizA = (hash % 360).toDouble();
    final matizB = (matizA + 50 + (hash >> 9) % 110) % 360;
    final area = Offset.zero & size;

    canvas.drawRect(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, matizA, 0.72, 0.40).toColor(),
            HSLColor.fromAHSL(1, matizB, 0.78, 0.15).toColor(),
          ],
        ).createShader(area),
    );

    final lado = size.shortestSide;
    final traco = Paint()
      ..color = Colors.white.withValues(alpha: 0.11)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lado * 0.04;

    switch ((hash >> 4) % 4) {
      case 0:
        // Faixas diagonais.
        final passo = lado * 0.22;
        for (var x = -size.height; x < size.width + size.height; x += passo) {
          canvas.drawLine(
            Offset(x, size.height),
            Offset(x + size.height, 0),
            traco,
          );
        }
      case 1:
        // Anéis saindo do canto inferior direito.
        final centro = Offset(size.width * 0.9, size.height * 0.95);
        for (
          var r = lado * 0.25;
          r < size.longestSide * 1.4;
          r += lado * 0.25
        ) {
          canvas.drawCircle(centro, r, traco);
        }
      case 2:
        // Grade de pontos.
        final ponto = Paint()..color = Colors.white.withValues(alpha: 0.13);
        final passo = lado * 0.16;
        for (var y = passo / 2; y < size.height; y += passo) {
          for (var x = passo / 2; x < size.width; x += passo) {
            canvas.drawCircle(Offset(x, y), lado * 0.028, ponto);
          }
        }
      default:
        // Losangos concêntricos.
        final centro = Offset(size.width / 2, size.height / 2);
        for (var r = lado * 0.2; r < size.longestSide; r += lado * 0.2) {
          final caminho = Path()
            ..moveTo(centro.dx, centro.dy - r)
            ..lineTo(centro.dx + r, centro.dy)
            ..lineTo(centro.dx, centro.dy + r)
            ..lineTo(centro.dx - r, centro.dy)
            ..close();
          canvas.drawPath(caminho, traco);
        }
    }
  }

  @override
  bool shouldRepaint(_CapaPainter antigo) => antigo.hash != hash;
}
