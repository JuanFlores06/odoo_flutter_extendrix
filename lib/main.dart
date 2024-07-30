import 'package:flutter/material.dart';
import 'package:odoo_flutter_extendrix/odoo_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final odooClient = OdooClient(
    url: 'http://10.0.2.2:8069', // Cambia la URL según tu configuración
    db: 'o16_com',
    username: 'default',
    password: '12345678',
  );

  try {
    await odooClient.authenticate();

    // Leer contactos
    final partners = await odooClient
        .searchRead('res.partner', [], ['name', 'country_id', 'comment']);

    runApp(MyApp(partners: partners));
  } catch (e) {
    print(e);
    runApp(MyApp(
        partners: [])); // Ejecuta la app con una lista vacía en caso de error
  }
}

class MyApp extends StatelessWidget {
  final List<dynamic> partners;

  MyApp({required this.partners});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ContactsScreen(partners: partners),
    );
  }
}

class ContactsScreen extends StatelessWidget {
  final List<dynamic> partners;

  ContactsScreen({required this.partners});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contactos de Odoo'),
      ),
      body: ListView.builder(
        itemCount: partners.length,
        itemBuilder: (context, index) {
          final partner = partners[index];
          final name = partner['name'] ?? 'No Name';
          final country = partner['country_id'] != null
              ? partner['country_id'][1]
              : 'Unknown';
          final comment = partner['comment'] ?? 'No Comment';

          return ListTile(
            title: Text(name),
            subtitle: Text('Country: $country\nComment: $comment'),
            contentPadding: EdgeInsets.all(8.0),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}
