import 'package:flutter/material.dart';

import 'models/contact_models.dart';

class ContactDetailPage extends StatelessWidget {
  final List<Contact> contacts;
  final String title;

  const ContactDetailPage({
    super.key,
    required this.contacts,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  title.startsWith('重复')
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              child: Icon(
                contact.phone == null
                    ? Icons.person_outline
                    : Icons.phone_outlined,
                color: title.startsWith('重复') ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              contact.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle:
                contact.phone != null
                    ? Text(
                      contact.phone!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    )
                    : null,
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black26,
              size: 16,
            ),
          );
        },
      ),
    );
  }
}
