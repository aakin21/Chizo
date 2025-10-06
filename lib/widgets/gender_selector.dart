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
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label ?? 'Gender',
          labelStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.person, color: Color(0xFFFF6B35)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        child: Text(
          _selectedGenderCode != null ? selectedGender['name']! : _getSelectGenderText(),
          style: TextStyle(
            color: _selectedGenderCode != null ? Colors.white : Colors.white60,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _showGenderPicker(BuildContext context, List<Map<String, String>> genders) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E), // Koyu arka plan
        title: Text(
          _getSelectGenderText(),
          style: const TextStyle(color: Colors.white),
        ),
        content: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2D2D2D), // Koyu gri
                Color(0xFF1E1E1E), // Daha koyu gri
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: genders.map((gender) {
              final isSelected = _selectedGenderCode == gender['code'];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFFFF6B35).withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected 
                      ? Border.all(color: const Color(0xFFFF6B35), width: 1)
                      : null,
                ),
                child: ListTile(
                  title: Text(
                    gender['name']!,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  leading: Icon(
                    Icons.person,
                    color: isSelected ? const Color(0xFFFF6B35) : Colors.white70,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedGenderCode = gender['code'];
                    });
                    widget.onGenderSelected(gender['code']);
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B35),
            ),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }
}
