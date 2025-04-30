import 'package:contacts_service/contacts_service.dart' as cs;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'contact_detail_page.dart';
import 'models/contact_models.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _duplicateNameContacts = [];
  List<Contact> _duplicatePhoneContacts = [];
  List<Contact> _noPhoneContacts = [];
  List<Contact> _noNameContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      final contacts = await cs.ContactsService.getContacts();
      _analyzeContacts(contacts);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('需要通讯录权限才能使用此功能')));
      }
    }
    setState(() => _isLoading = false);
  }

  void _analyzeContacts(Iterable<cs.Contact> contacts) {
    final nameMap = <String, List<cs.Contact>>{};
    final phoneMap = <String, List<cs.Contact>>{};

    for (final contact in contacts) {
      // Analyze duplicate names
      if (contact.displayName != null) {
        nameMap.putIfAbsent(contact.displayName!, () => []).add(contact);
      }

      // Analyze duplicate phones
      if (contact.phones?.isNotEmpty == true) {
        for (final phone in contact.phones!) {
          if (phone.value != null) {
            phoneMap.putIfAbsent(phone.value!, () => []).add(contact);
          }
        }
      }

      // Analyze incomplete contacts
      if (contact.displayName == null || contact.displayName!.isEmpty) {
        _noNameContacts.add(Contact.fromContact(contact, '不完整'));
      }
      if (contact.phones == null || contact.phones!.isEmpty) {
        _noPhoneContacts.add(Contact.fromContact(contact, '不完整'));
      }
    }

    // Find duplicates
    for (final entry in nameMap.entries) {
      if (entry.value.length > 1) {
        _duplicateNameContacts.addAll(
          entry.value.map((c) => Contact.fromContact(c, '重复')),
        );
      }
    }

    for (final entry in phoneMap.entries) {
      if (entry.value.length > 1) {
        _duplicatePhoneContacts.addAll(
          entry.value.map((c) => Contact.fromContact(c, '重复')),
        );
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '通讯录',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue, size: 24),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadContacts();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                children: [
                  _buildSection('重复', [
                    _buildContactGroup(
                      '重复名字',
                      _duplicateNameContacts.length,
                      Icons.person_outline,
                      Colors.green,
                      context,
                      _duplicateNameContacts,
                    ),
                    _buildContactGroup(
                      '重复号码',
                      _duplicatePhoneContacts.length,
                      Icons.phone_outlined,
                      Colors.green,
                      context,
                      _duplicatePhoneContacts,
                    ),
                  ]),
                  _buildSection('不完整', [
                    _buildContactGroup(
                      '无号码',
                      _noPhoneContacts.length,
                      Icons.person_outline,
                      Colors.red,
                      context,
                      _noPhoneContacts,
                    ),
                    _buildContactGroup(
                      '无名字',
                      _noNameContacts.length,
                      Icons.phone_outlined,
                      Colors.red,
                      context,
                      _noNameContacts,
                    ),
                  ]),
                ],
              ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildContactGroup(
    String title,
    int count,
    IconData icon,
    Color iconColor,
    BuildContext context,
    List<Contact> contacts,
  ) {
    return InkWell(
      onTap: () {
        if (contacts.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ContactDetailPage(contacts: contacts, title: title),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 16, color: Colors.black45),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black26,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
