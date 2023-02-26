import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inwentarz_ee/services/file_utils.dart';

class CreateEquipmentPage extends StatefulWidget {
  CreateEquipmentPage({Key? key}) : super(key: key);

  @override
  State<CreateEquipmentPage> createState() => _CreateEquipmentPageState();
}

class _CreateEquipmentPageState extends State<CreateEquipmentPage> {
  final _nameController = TextEditingController();

  final _locationController = TextEditingController();

  bool _declaredNextCalibration = false;

  DateTime? _selectedDate = null;

  final _calibrationDateController = TextEditingController();

  List<String> _selectedFilePaths = [];

  @override
  Widget build(BuildContext context) {
    double _separationHeight = 20;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dodaj nowy sprzęt"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
        child: ListView(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: "Nazwa"),
              controller: _nameController,
              cursorHeight: 20,
              autofocus: true,
            ),
            SizedBox(
              height: _separationHeight,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Lokalizacja"),
              controller: _locationController,
              cursorHeight: 20,
            ),
            SizedBox(height: _separationHeight),
            TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              cursorHeight: 20,
              decoration: InputDecoration(labelText: "Opis urządzenia"),
            ),
            SizedBox(
              height: _separationHeight,
            ),
            TextFormField(
              controller: _calibrationDateController,
              decoration: InputDecoration(labelText: "Data następnego wzorcowania", border: OutlineInputBorder()),
              readOnly: true,
              onTap: () async {
                _selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(Duration(days: 1)),
                    firstDate: DateTime.now().add(Duration(days: 1)),
                    lastDate: DateTime.now().add(Duration(days: 36500)),
                    cancelText: "Usuń deklarację",
                    confirmText: "Wybierz datę");
                _calibrationDateController.text = _selectedDate != null ? DateFormat('dd.MM.yyyy').format(_selectedDate!) : "";
                setState(() {});
              },
            ),
            SizedBox(
              height: _separationHeight,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(_selectedFilePaths.isEmpty ? "Nie wybrano plików" : "Wybrano ${_selectedFilePaths.length} plików"),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () async {
                      bool ready = await FileUtils.checkStoragePermissions(context);
                      if (!ready) return;

                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                          dialogTitle: "Wybierz załączniki",
                          allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'pdf', 'docx', 'xlsx', 'doc', 'xls'],
                          type: FileType.custom,
                          allowMultiple: true);

                      setState(() {
                        _selectedFilePaths = result == null ? [] : result.paths.whereType<String>().toList();
                      });
                    },
                    child: Text("Dodaj pliki"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
