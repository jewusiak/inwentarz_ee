import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inwentarz_ee/services/db_utils.dart';
import 'package:inwentarz_ee/services/file_utils.dart';
import 'package:inwentarz_ee/widgets/circular_indicator_dialog.dart';

class CreateEquipmentPage extends StatefulWidget {
  CreateEquipmentPage({Key? key}) : super(key: key);

  @override
  State<CreateEquipmentPage> createState() => _CreateEquipmentPageState();
}

class _CreateEquipmentPageState extends State<CreateEquipmentPage> {
  final _nameController = TextEditingController();

  final _locationController = TextEditingController();

  final _descriptionController = TextEditingController();

  bool _declaredNextCalibration = false;

  DateTime? _selectedDate = null;

  final _calibrationDateController = TextEditingController();

  List<String> _selectedFilePaths = [];
  List<String> _selectedFileNames = [];

  String? _mainImagePath = null;

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
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Nazwa"),
                    controller: _nameController,
                    cursorHeight: 20,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  flex: 1,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () async {
                          bool ready = await FileUtils.checkStoragePermissions(context);
                          if (!ready) return;

                          FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, dialogTitle: "Główne zdjęcie");
                          if (result != null) {
                            _mainImagePath = result.paths[0]!;
                          } else {
                            _mainImagePath = null;
                          }
                          setState(() {});
                        },
                        child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(1000),
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: _mainImagePath!=null ? Image.file(File(_mainImagePath!)) :Image.asset("assets/images/default-camera.jpeg"),
                                  ),
                                ),
                              ),
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: _separationHeight,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Lokalizacja"),
              controller: _locationController,
              textInputAction: TextInputAction.next,
              cursorHeight: 20,
            ),
            SizedBox(height: _separationHeight),
            TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              cursorHeight: 20,
              decoration: InputDecoration(labelText: "Opis urządzenia"),
              controller: _descriptionController,
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
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Text("opcjonalnie"),
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
                    child: _selectedFileNames.isEmpty
                        ? Text("Nie wybrano plików")
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _selectedFileNames.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) => Center(
                                child: Text(
                                  _selectedFileNames[index],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
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
                        _selectedFileNames = result == null ? [] : result.names.whereType<String>().toList();
                      });
                    },
                    child: Text(
                      "Dodaj pliki",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: _separationHeight,
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  showCircularProgressIndicatorDialog(context, dismissable: true);
                  await DBUtils.createEquipmentAndUploadAttachments(_nameController.value.text, _locationController.value.text,
                      _descriptionController.value.text, _selectedDate, _selectedFilePaths, _mainImagePath);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("Dodaj nowy sprzęt"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
