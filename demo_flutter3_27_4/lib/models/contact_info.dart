import 'package:flutter_contacts_service/flutter_contacts_service.dart' as fcs;

class ContactInfo {
  final String? identifier;
  final String? displayName;
  final List<PhoneNumber>? phones;
  final List<EmailAddress>? emails;
  final String? company;
  final String? jobTitle;
  final String? note;
  final ContactAvatar? avatar;
  final fcs.ContactInfo? originalContact;

  ContactInfo({
    this.identifier,
    this.displayName,
    this.phones,
    this.emails,
    this.company,
    this.jobTitle,
    this.note,
    this.avatar,
    this.originalContact,
  });

  factory ContactInfo.fromFcsContact(fcs.ContactInfo contact) {
    return ContactInfo(
      identifier: contact.identifier,
      displayName: contact.displayName,
      phones: contact.phones
          ?.map((p) => PhoneNumber(label: p.label, value: p.value))
          .toList(),
      emails: contact.emails
          ?.map((e) => EmailAddress(label: e.label, value: e.value))
          .toList(),
      company: contact.company,
      jobTitle: contact.jobTitle,
      note: contact.note,
      avatar:
          contact.avatar != null ? ContactAvatar(bytes: contact.avatar) : null,
      originalContact: contact,
    );
  }
}

class PhoneNumber {
  final String? label;
  final String? value;

  PhoneNumber({this.label, this.value});
}

class EmailAddress {
  final String? label;
  final String? value;

  EmailAddress({this.label, this.value});
}

class ContactAvatar {
  final dynamic bytes;

  ContactAvatar({this.bytes});
}
