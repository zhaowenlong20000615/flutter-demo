import 'package:contacts_service/contacts_service.dart' as cs;

class Contact {
  final String name;
  final String? phone;
  final String? email;
  final String? avatar;
  final String group;

  Contact({
    required this.name,
    this.phone,
    this.email,
    this.avatar,
    required this.group,
  });

  factory Contact.fromContact(cs.Contact contact, String group) {
    return Contact(
      name: contact.displayName ?? 'Unknown',
      phone:
          contact.phones?.isNotEmpty == true
              ? contact.phones!.first.value
              : null,
      email:
          contact.emails?.isNotEmpty == true
              ? contact.emails!.first.value
              : null,
      group: group,
    );
  }

  Contact copyWith({
    String? name,
    String? phone,
    String? email,
    String? avatar,
    String? group,
  }) {
    return Contact(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      group: group ?? this.group,
    );
  }
}

// 用于分组显示的数据结构
class ContactGroup {
  final String name;
  final List<Contact> contacts;

  const ContactGroup({required this.name, required this.contacts});

  ContactGroup copyWith({String? name, List<Contact>? contacts}) {
    return ContactGroup(
      name: name ?? this.name,
      contacts: contacts ?? this.contacts,
    );
  }
}
