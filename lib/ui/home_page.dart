import 'package:flutter/material.dart';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'dart:io';

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
        _showContactPage(contact: contacts[index]);
      },
    );
  }

  // Função para ir para a pagina de editar ou adicionar contato
  void _showContactPage({Contact, contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
        _getAllContacts();
      } else {
        await helper.saveContact(recContact);
      }
    }
  }
  void _getAllContacts() {
    helper.getAllContacts().then.((list) {
      setState(() {
        contacts = list;
      });
    });
  }
}


