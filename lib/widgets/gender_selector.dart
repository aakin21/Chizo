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
    
    return DropdownButtonFormField<String>(
      value: _selectedGenderCode != null && 
             genders.any((g) => g['code'] == _selectedGenderCode)
             ? _selectedGenderCode : null,
      decoration: InputDecoration(
        labelText: widget.label ?? 'Gender',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      hint: Text(
        _getSelectGenderText(),
        style: TextStyle(color: Colors.grey.shade600),
      ),
      items: genders.map((gender) {
        return DropdownMenuItem<String>(
          value: gender['code'],
          child: Text(
            gender['name']!,
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: widget.enabled
          ? (String? newValue) {
              setState(() {
                _selectedGenderCode = newValue;
              });
              widget.onGenderSelected(newValue);
            }
          : null,
    );
  }
}