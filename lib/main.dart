import 'package:flutter/material.dart';
import 'package:odoo_flutter_extendrix/odoo_client.dart';
import 'package:odoo_flutter_extendrix/new_contact_screen.dart';
import 'package:odoo_flutter_extendrix/edit_contact_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final odooClient = OdooClient(
    url: 'http://10.0.2.2:8069',
    db: 'o16_com',
    username: 'default',
    password: '12345678',
  );

  await odooClient.authenticate();

  runApp(MyApp(odooClient: odooClient));
}

class MyApp extends StatelessWidget {
  final OdooClient odooClient;

  MyApp({required this.odooClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ContactListScreen(odooClient: odooClient),
    );
  }
}

class ContactListScreen extends StatefulWidget {
  final OdooClient odooClient;

  ContactListScreen({required this.odooClient});

  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<dynamic> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await widget.odooClient
          .searchRead('res.partner', [], ['name', 'phone', 'comment']);
      setState(() {
        contacts = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error al obtener contactos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _navigateToNewContactScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewContactScreen(odooClient: widget.odooClient),
      ),
    );
    _fetchContacts(); // Actualiza la lista de contactos al volver
  }

  Future<void> _navigateToEditContactScreen(int id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditContactScreen(
          odooClient: widget.odooClient,
          contactId: id,
        ),
      ),
    );
    _fetchContacts(); // Actualiza la lista de contactos al volver
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contactos de Odoo'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchContacts,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToNewContactScreen,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final id = contact['id'];
                final name = contact['name'] ?? 'Sin Nombre';
                final phone = contact['phone']?.toString() ?? 'Sin Teléfono';
                final hasComment = contact['comment']; //!= null;

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text(phone),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _navigateToEditContactScreen(id),
                        ),
                        hasComment ? Icon(Icons.check) : SizedBox.shrink(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
