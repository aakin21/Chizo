import 'package:flutter/material.dart';

class GenderSelector extends StatefulWidget {
  final String? selectedGenderCode;
  final Function(String?) onGenderSelected;
  final String? label;
  final bool enabled;

  const GenderSelector({
    super.key,
    this.selectedGenderCode,
    required this.onGenderSelected,
    this.label,
    this.enabled = true,
  });

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  String? _selectedGenderCode;

  @override
  void initState() {
    super.initState();
    _selectedGenderCode = widget.selectedGenderCode;
  }

  @override
  void didUpdateWidget(GenderSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedGenderCode != oldWidget.selectedGenderCode) {
      _selectedGenderCode = widget.selectedGenderCode;
    }
  }

  List<Map<String, String>> _getGenders() {
    final language = Localizations.localeOf(context).languageCode;
    
    if (language == 'tr') {
      return [
        {'code': 'M', 'name': 'Erkek'},
        {'code': 'F', 'name': 'Kadın'},
        {'code': 'O', 'name': 'Diğer'},
      ];
    } else if (language == 'de') {
      return [
        {'code': 'M', 'name': 'Männlich'},
        {'code': 'F', 'name': 'Weiblich'},
        {'code': 'O', 'name': 'Andere'},
      ];
    } else if (language == 'es') {
      return [
        {'code': 'M', 'name': 'Masculino'},
        {'code': 'F', 'name': 'Femenino'},
        {'code': 'O', 'name': 'Otro'},
      ];
    } else {
      // English
      return [
        {'code': 'M', 'name': 'Male'},
        {'code': 'F', 'name': 'Female'},
        {'code': 'O', 'name': 'Other'},
      ];
    }
  }

  String _getSelectGenderText() {
    final language = Localizations.localeOf(context).languageCode;
    
    switch (language) {
      case 'tr':
        return 'Cinsiyet Seç';
      case 'de':
        return 'Geschlecht Wählen';
      case 'es':
        return 'Seleccionar Género';
      default:
        return 'Select Gender';
    }
  }

  @override
  Widget build(BuildContext context) {
    final genders = _getGenders();
    final selectedGender = genders.firstWhere(
      (gender) => gender['code'] == _selectedGenderCode,
      orElse: () => {'code': '', 'name': ''},
    );
    
    return GestureDetector(
      onTap: widget.enabled ? () => _showGenderPicker(context, genders) : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label ?? 'Gender',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.person),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          child: Text(
            _selectedGenderCode != null ? selectedGender['name']! : _getSelectGenderText(),
            style: TextStyle(
              color: _selectedGenderCode != null ? Colors.black : Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _showGenderPicker(BuildContext context, List<Map<String, String>> genders) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getSelectGenderText()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: genders.map((gender) {
            return ListTile(
              title: Text(gender['name']!),
              onTap: () {
                setState(() {
                  _selectedGenderCode = gender['code'];
                });
                widget.onGenderSelected(gender['code']);
                Navigator.pop(context);
              },
              selected: _selectedGenderCode == gender['code'],
            );
          }).toList(),
        ),
      ),
    );
  }
}
