import 'package:flutter/material.dart';
import 'package:odoo_flutter_extendrix/odoo_client.dart';

class NewContactScreen extends StatefulWidget {
  final OdooClient odooClient;

  NewContactScreen({required this.odooClient});

  @override
  _NewContactScreenState createState() => _NewContactScreenState();
}

class _NewContactScreenState extends State<NewContactScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final newContactId = await widget.odooClient.createContact({
          'name': _name,
          'phone': _phone,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Contacto creado con ID: $newContactId'),
        ));

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al crear contacto: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Contacto'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Teléfono'),
                onSaved: (value) => _phone = value ?? '',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
