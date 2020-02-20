import 'package:flutter/material.dart';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'dart:io';

class ContactPage extends StatefulWidget {
  // Contato declarado
  final Contact contact;

  // Construtor para passar os dados do contato que eu quero editar
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  // Controllers do formulario
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();

  // Indica que o usuario ainda não editou nada
  bool _userEdited = false;

  // ira receber o contato depois de editado
  Contact _editedContact;

  // Quando a pagina iniciar
  @override
  void initState() {
    super.initState();

    // Se não foi passado um contato para editar ira ser criado um novo contato
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      // Coloca os dados do contato passado no formulario para edição
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          // Sera mostrado "novo contato" caso o contato não tenho um nome
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Colocará o foco no campo de nome se tentar inserir um contato sem nome
            if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          // Ira ser retornado um avatar padrão, caso o contato não tenha uma foto
                          image: _editedContact.img != null
                              ? FileImage(File(_editedContact.img))
                              : AssetImage("images/person.png"))),
                ),
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "Phone"),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact.phone = text;
                  },
                  keyboardType: TextInputType.phone)
            ],
          ),
        ),
      ),
    );
  }

  // Dialog de confirmação para descartar alterações e sair da tela
  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair as alterações serão perdidas"),
              actions: <Widget>[
                FlatButton(
                    child: Text("Cancelar"),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                FlatButton(
                    child: Text("Sim"),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    })
              ],
            );
          });
      // Se o usuario
      return Future.value(false);
    } else {
      // Se o usuario não alterou nada irá sair da tela automaticamente
      return Future.value(true);
    }
  }
}
