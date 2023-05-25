import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:badges/badges.dart' as badges;
import 'package:uuid/uuid.dart';

import '../feed/feed_inicial.dart';

import '../../api/api.dart';
import '../../api/api_arq_post.dart';
import '../../api/api_post.dart';
import '../../models/models.dart';
import '../../widgets/botao_default.dart';
import '../../widgets/campo_pesquisa.dart';
import 'novo_post_controlador.dart';

class NovoPostTela extends StatefulWidget {
  const NovoPostTela({Key? key}): super(key: key);

  @override
  State<NovoPostTela> createState() => _NovoPostTela();
}
class _NovoPostTela extends State<NovoPostTela>{
  NovoPostControlador controlador = NovoPostControlador();

  ApiPost criarPost = ApiPost();
  ApiArquivoPost criarArquivoPost = ApiArquivoPost();
  
  List<File> imagensSelecionadas = [];

  Future<void> selecionarImagens() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'svg', 'jpeg']
      );

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      setState(() {
        imagensSelecionadas.addAll(files);
      });
    }
  }

  void removerImagem(int index) {
    setState(() {
      imagensSelecionadas.removeAt(index);
    });
  }

  bool _isBadgeTapped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CampoPesquisa(label: 'Pesquisar'),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(FontAwesomeIcons.ellipsisVertical), color: const Color(0xFF679C8A)),
        ],
        shadowColor: Colors.black12,
        elevation: 10,
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        children:[
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                GestureDetector(
                  onTap: selecionarImagens,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: DottedBorder(
                        color: const Color(0XFF679C8A),
                        strokeWidth: 1,
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(15),
                        dashPattern: const [10, 10],
                        child: Center(
                          child:
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child:
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child:
                                          SvgPicture.asset(
                                          'assets/images/photo_film.svg',
                                          height: 45,
                                        ),
                                      ),
                                      const Text('Adicionar novo arquivo',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), ),
                                      const Text('Somente imagens ou vídeos'),
                                    ],
                                )
                            )
                        )
                    )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:15, bottom: 5),
                  child:
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child:
                    Row(
                      children: List.generate(imagensSelecionadas.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            if (_isBadgeTapped) {
                              removerImagem(index);
                            }
                          },
                          child: Badge(
                            alignment: AlignmentDirectional.topEnd,
                            largeSize: 20,
                            label: Icon(FontAwesomeIcons.xmark, color: Colors.white, size: 12),
                            backgroundColor: Color(0xFF679C8A),
                            child: GestureDetector(
                              onTap: () {
                                  setState(() {
                                    _isBadgeTapped = true;
                                  });
                                },
                              child:
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0XFFF1F1F1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: EdgeInsets.all(4),
                                  width: MediaQuery.of(context).size.width * 0.18,
                                  height: MediaQuery.of(context).size.width * 0.18,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      imagensSelecionadas[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              )
                            )
                          )
                        );
                      }),
                    ),
                  )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical:10),
                  child:
                    TextFormField(
                      controller: controlador.titulo,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0XFFF1F1F1),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
                          hintText: "Título",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 22),
                      ),
                  )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical:10),
                  child:
                    TextFormField(
                      controller: controlador.descricao,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0XFFF1F1F1),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                          hintText: "Descrição",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 70),
                      ),
                    )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical:8),
                  child:
                    BotaoPadrao(
                      texto: 'Publicar novo post',
                      aoClicar: _createData,
                    ),
                )
              ]
            )
          )
        ]
      )
    );
  }


  Future _createData() async {
    List data = await api.from('usuario').select('id').eq('user_id', api.auth.currentUser?.id);
    int usuario = data[0]['id'];

    PostagemCreate postagem = PostagemCreate(titulo: controlador.titulo.text, descricao: controlador.descricao.text, usuario_id: usuario);
  
    List<dynamic> res = await criarPost.createData(postagem);

    for(var file in imagensSelecionadas) {
      final uuid = Uuid();
      final new_uuid = uuid.v4();

      await api.storage.from("arquivos_postagem").upload('${res[0]['id']}/${new_uuid+path.extension(file.path)}', file);
      Arquivo arquivo = Arquivo(arquivo: new_uuid+path.extension(file.path), postagem: res[0]['id']);

      criarArquivoPost.createData(arquivo);
    }
    
    // if (res.error != null) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.error!.message)));
    // }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Arte publicada! :)", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FeedTela()),
    );

  }
  
}