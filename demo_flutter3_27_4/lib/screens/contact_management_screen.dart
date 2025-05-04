import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/media_service.dart';
import 'contact_cleanup_screen.dart';
import '../models/contact_info.dart';

class ContactManagementScreen extends StatefulWidget {
  @override
  _ContactManagementScreenState createState() =>
      _ContactManagementScreenState();
}

class _ContactManagementScreenState extends State<ContactManagementScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final mediaService = Provider.of<MediaService>(context, listen: false);
    await mediaService.loadContacts();
  }

  // Find duplicated contacts (with same name)
  List<ContactInfo> _findDuplicateContacts(List<ContactInfo> contacts) {
    final Map<String, List<ContactInfo>> nameGroups = {};

    // Group by name
    for (final contact in contacts) {
      final name = contact.displayName;
      if (name != null && name.isNotEmpty) {
        if (!nameGroups.containsKey(name)) {
          nameGroups[name] = [];
        }
        nameGroups[name]!.add(contact);
      }
    }

    // Only keep groups with multiple contacts
    final List<ContactInfo> result = [];
    nameGroups.forEach((key, contactList) {
      if (contactList.length > 1) {
        result.addAll(contactList);
      }
    });

    return result;
  }

  // Find contacts without phone numbers
  List<ContactInfo> _findContactsWithoutPhone(List<ContactInfo> contacts) {
    return contacts
        .where((contact) => contact.phones == null || contact.phones!.isEmpty)
        .toList();
  }

  // Find contacts without email
  List<ContactInfo> _findContactsWithoutEmail(List<ContactInfo> contacts) {
    return contacts
        .where((contact) => contact.emails == null || contact.emails!.isEmpty)
        .toList();
  }

  // Find contacts never contacted (simplified implementation, no actual call/sms data check)
  List<ContactInfo> _findRarelyUsedContacts(List<ContactInfo> contacts) {
    // In a real app, you would check call/message history
    // For this example, we'll return a subset of contacts (20%)
    final result = List<ContactInfo>.from(contacts);
    result.sort((a, b) => a.displayName?.compareTo(b.displayName ?? '') ?? 0);

    // Return bottom 20% of contacts (sorted alphabetically)
    // This is just for demonstration purposes
    if (result.length <= 5) return [];
    return result.sublist(0, (result.length * 0.2).round());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '联系人',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<MediaService>(
        builder: (context, mediaService, _) {
          final allContacts = mediaService.contacts;
          final duplicateContacts = _findDuplicateContacts(allContacts);
          final contactsWithoutPhone = _findContactsWithoutPhone(allContacts);
          final contactsWithoutEmail = _findContactsWithoutEmail(allContacts);
          final rarelyUsedContacts = _findRarelyUsedContacts(allContacts);

          return ListView(
            children: [
              _buildCategoryItem(
                icon: Icons.contacts_outlined,
                title: '所有联系人',
                count: allContacts.length,
                description: '管理所有联系人',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactCleanupScreen(
                        title: '所有联系人',
                        contacts: allContacts,
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildCategoryItem(
                icon: Icons.people_outlined,
                title: '重复联系人',
                count: duplicateContacts.length,
                description: '名称相同的联系人',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactCleanupScreen(
                        title: '重复联系人',
                        contacts: duplicateContacts,
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildCategoryItem(
                icon: Icons.phone_disabled_outlined,
                title: '无电话号码联系人',
                count: contactsWithoutPhone.length,
                description: '没有电话号码的联系人',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactCleanupScreen(
                        title: '无电话号码联系人',
                        contacts: contactsWithoutPhone,
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildCategoryItem(
                icon: Icons.email_outlined,
                title: '无邮箱联系人',
                count: contactsWithoutEmail.length,
                description: '没有电子邮箱的联系人',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactCleanupScreen(
                        title: '无邮箱联系人',
                        contacts: contactsWithoutEmail,
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildCategoryItem(
                icon: Icons.access_time_outlined,
                title: '不常用联系人',
                count: rarelyUsedContacts.length,
                description: '很少联系的联系人',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactCleanupScreen(
                        title: '不常用联系人',
                        contacts: rarelyUsedContacts,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required int count,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.blue,
                size: 22,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$count 个联系人 • $description',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[200],
      height: 1,
      thickness: 1,
      indent: 76,
      endIndent: 0,
    );
  }
}
