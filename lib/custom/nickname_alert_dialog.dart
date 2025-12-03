import 'package:flutter/material.dart';

class NicknameAlertDialog extends StatefulWidget {
  final String title;
  final String message;
  final String nickname;
  final ValueChanged<String> onNicknameChanged;

  const NicknameAlertDialog({
    required this.title,
    required this.message,
    required this.nickname,
    required this.onNicknameChanged,
    super.key,
  });

  @override
  State<NicknameAlertDialog> createState() => _NicknameAlertDialogState();
}

class _NicknameAlertDialogState extends State<NicknameAlertDialog> {

  late TextEditingController _nickname;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nickname = TextEditingController(text: widget.nickname);
  }

  @override
  void dispose() {
    super.dispose();
    _nickname.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: Text(widget.title, style: const TextStyle(color: Colors.white),),
      content: SizedBox(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextFormField(
              controller: _nickname,
              validator: (text) {
                if (text == null || text.trim().isEmpty) {
                  return 'Nickname is empty';
                }
                return null;
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: "Nuovo nickname",
                  hintStyle: const TextStyle(color: Colors.white60)),
              obscureText: false,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        )
      ),
      actions: <Widget>[
        Container(
          decoration: BoxDecoration(
            // color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Annulla', style: TextStyle(color: Colors.white)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            // color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onNicknameChanged(_nickname.text);
                Navigator.pop(context, 'confirm');
              }
            },
            child: const Text('Conferma', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
