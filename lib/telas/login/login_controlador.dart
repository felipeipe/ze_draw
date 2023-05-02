import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:ze_draw/api/autenticacao.dart';
import 'package:ze_draw/telas/login/login_tela.dart';

import '../rotas.dart';

class LoginControlador extends StatefulWidget {
  final TextEditingController usuario = TextEditingController();
  final TextEditingController senha = TextEditingController();

  LoginControlador({super.key});

  @override
  State<LoginControlador> createState() => _LoginControladorState();

  void logar(BuildContext context) async {
    try {
      await Autenticacao.logar(usuario.text, senha.text);
      Navigator.of(context).pushNamed(Rotas.feed);
      // TODO: Ir para tela de feed.
    } catch (e) {
      log(e.toString());
      // TODO: Checar erros e mostrar na tela.
    }
  }
}

class _LoginControladorState extends State<LoginControlador> {
  @override
  Widget build(BuildContext context) {
    return LoginTela(widget);
  }
}