import 'package:flutter/material.dart';
import 'package:odoo_flutter_extendrix/odoo_client.dart';

class EditContactScreen extends StatefulWidget {
  final OdooClient odooClient;
  final int contactId;

  EditContactScreen({required this.odooClient, required this.contactId});

  @override
  _EditContactScreenState createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadContactData();
  }

  Future<void> _loadContactData() async {
    try {
      final contact = await widget.odooClient.searchRead(
        'res.partner',
        [
          ['id', '=', widget.contactId]
        ],
        ['name', 'phone'],
      );
      if (contact.isNotEmpty) {
        setState(() {
          _nameController.text = contact[0]['name'] ?? '';
          _phoneController.text = contact[0]['phone']?.toString() ?? '';
        });
      }
    } catch (e) {
      print('Error al obtener datos del contacto: $e');
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await widget.odooClient.updateContact(
          widget.contactId,
          {'name': _nameController.text, 'phone': _phoneController.text},
        );

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Contacto actualizado'),
        ));

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al actualizar contacto: $e'),
        ));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Contacto'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un teléfono';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
