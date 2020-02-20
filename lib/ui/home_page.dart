import 'package:flutter/material.dart';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  // Lista vazia do tipo Contact, que ira receber todos os contatos
  List<Contact> contacts = List();

  // Quando a tela é iniciada
  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Contatos"),
            backgroundColor: Colors.red,
            centerTitle: true),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showContactPage();
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.red,
        ),
        // Lista de contatos
        body: ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return _contactCard(context, index);
            }));
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      // Card de contato
      child: Card(
          // Padding para espaçamento
          child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  // Avatar do contato
                  Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            // Ira ser retornado um avatar padrão, caso o contato não tenha uma foto
                            image: contacts[index].img != null
                                ? FileImage(File(contacts[index].img))
                                : AssetImage("images/person.png"))),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          contacts[index].name ?? "",
                          style: TextStyle(
                              fontSize: 22.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          contacts[index].email ?? "",
                          style: TextStyle(fontSize: 18.0),
                        ),
                        Text(
                          contacts[index].phone ?? "",
                          style: TextStyle(fontSize: 18.0),
                        )
                      ],
                    ),
                  )
                ],
              ))),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                          child: Text(
                            "Ligar",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                          onPressed: () {
                            launch("tel:${contacts[index].phone}");
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                          child: Text(
                            "Editar",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _showContactPage(contact: contacts[index]);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                          child: Text(
                            "Excluir",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                          onPressed: () {
                            helper.deleteContact(contacts[index].id);
                            setState() {
                              contacts.removeAt(index);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      )
                    ],
                  ));
            },
          );
        });
  }

  // Ir para tela de editar ou criar contato (pode ou não receber um contato como parametro)
  void _showContactPage({Contact contact}) async {
    // recebe o contato editado na proxima pagina
    final recContact = await Navigator.push(
        context,
        // Ira para a proxima pagina em branco ou com um contato para ser editado
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));
    // verifica se a pagina retornou um contato
    if (recContact != null) {
      // verifica se foi enviado um contato a ser editado, não clicado no botão novo
      if (contact != null) {
        // Atualiza o contato
        await helper.updateContact(recContact);
      } else {
        // Insere o contato novo
        await helper.saveContact(recContact);
      }
      // recarrega todos os contatos da pagina
      _getAllContacts();
    }
  }

  // carrega todos os contatos salvos
  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
      print(list);
    });
  }
}
