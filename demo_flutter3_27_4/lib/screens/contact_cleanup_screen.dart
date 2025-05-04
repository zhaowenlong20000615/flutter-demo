import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/media_service.dart';
import '../models/contact_info.dart';

class ContactCleanupScreen extends StatefulWidget {
  final String title;
  final List<ContactInfo> contacts;

  ContactCleanupScreen({
    required this.title,
    required this.contacts,
  });

  @override
  _ContactCleanupScreenState createState() => _ContactCleanupScreenState();
}

class _ContactCleanupScreenState extends State<ContactCleanupScreen> {
  Set<ContactInfo> _selectedContacts = {};
  bool _isSelectMode = false;

  @override
  Widget build(BuildContext context) {
    final mediaService = Provider.of<MediaService>(context);
    final hasContacts = widget.contacts.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          if (hasContacts && _isSelectMode)
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedContacts.length == widget.contacts.length) {
                    _selectedContacts.clear();
                  } else {
                    _selectedContacts = Set.from(widget.contacts);
                  }
                });
              },
              child: Text(
                _selectedContacts.length == widget.contacts.length
                    ? '全不选'
                    : '全选',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (hasContacts && !_isSelectMode)
            IconButton(
              icon: Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  _isSelectMode = true;
                });
              },
            ),
        ],
      ),
      body: !hasContacts
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.contacts.length,
              itemBuilder: (context, index) {
                final contact = widget.contacts[index];
                final isSelected = _selectedContacts.contains(contact);
                final hasPhone =
                    contact.phones != null && contact.phones!.isNotEmpty;
                final hasEmail =
                    contact.emails != null && contact.emails!.isNotEmpty;

                return ListTile(
                  onTap: () {
                    if (_isSelectMode) {
                      setState(() {
                        if (isSelected) {
                          _selectedContacts.remove(contact);
                        } else {
                          _selectedContacts.add(contact);
                        }
                      });
                    } else {
                      // View contact detail (not implemented)
                    }
                  },
                  onLongPress: () {
                    if (!_isSelectMode) {
                      setState(() {
                        _isSelectMode = true;
                        _selectedContacts.add(contact);
                      });
                    }
                  },
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          (contact.displayName?.isNotEmpty == true)
                              ? contact.displayName![0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_isSelectMode)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? Colors.blue : Colors.white,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 12,
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    contact.displayName ?? '未命名联系人',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasPhone)
                        Text(
                          contact.phones!.first.value ?? '',
                          style: TextStyle(fontSize: 13),
                        ),
                      if (hasEmail && !hasPhone)
                        Text(
                          contact.emails!.first.value ?? '',
                          style: TextStyle(fontSize: 13),
                        ),
                      if (!hasPhone && !hasEmail)
                        Text(
                          '无联系方式',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                  trailing: _isSelectMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedContacts.add(contact);
                              } else {
                                _selectedContacts.remove(contact);
                              }
                            });
                          },
                        )
                      : Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey[400]),
                );
              },
            ),
      bottomNavigationBar: _isSelectMode && _selectedContacts.isNotEmpty
          ? SafeArea(
              child: Container(
                height: 64,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '已选择 ${_selectedContacts.length} 项',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('确认删除'),
                            content: Text(
                                '是否确认删除选中的 ${_selectedContacts.length} 个联系人？'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('取消'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  // Delete selected contacts
                                  for (var contact in _selectedContacts) {
                                    await mediaService.deleteContact(contact);
                                  }
                                  setState(() {
                                    _selectedContacts.clear();
                                    _isSelectMode = false;
                                  });
                                },
                                child: Text('确认'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        '删除',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            '没有${widget.title}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '此类别中没有找到联系人',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
