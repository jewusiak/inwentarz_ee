import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inwentarz_ee/data_access/equipment_service.dart';
import 'package:inwentarz_ee/data_access/models/equipment.dart';
import 'package:inwentarz_ee/services/file_utils.dart';
import 'package:inwentarz_ee/services/utils.dart';

import 'equipment_details_page.dart';

// Edit or Create? - editedEquipment == null ? create : edit
class CreateOrEditEquipmentPage extends StatefulWidget {
  CreateOrEditEquipmentPage({this.editedEquipment, Key? key}) : super(key: key);

  Equipment? editedEquipment;
  bool preFilled = false;

  @override
  State<CreateOrEditEquipmentPage> createState() =>
      _CreateOrEditEquipmentPageState();
}

class _CreateOrEditEquipmentPageState extends State<CreateOrEditEquipmentPage> {
  final _nameController = TextEditingController();

  final _locationController = TextEditingController();

  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;

  final _calibrationDateController = TextEditingController();

  final List<String> _selectedFilePaths = [];
  final List<String> _selectedFileNames = [];

  final List<bool> _isFileRemote = [];
  late int _numberOfRemoteFiles = 0;

  @override
  Widget build(BuildContext context) {
    double separationHeight = 20;

    if (!widget.preFilled) {
      widget.preFilled = true;
      if (widget.editedEquipment != null) {
        _nameController.text = widget.editedEquipment!.name ?? "";
        _locationController.text = widget.editedEquipment!.location ?? "";
        _descriptionController.text = widget.editedEquipment!.description ?? "";
        if (widget.editedEquipment!.nextCalibration != null) {
          _selectedDate =
              DateTime.parse(widget.editedEquipment!.nextCalibration!);
        }
        _numberOfRemoteFiles = widget.editedEquipment!.attachments?.length ?? 0;
        for (int i = 0; i < _numberOfRemoteFiles; i++) {
          _isFileRemote.add(true);
          _selectedFilePaths.add("");
          _selectedFileNames.add(
              widget.editedEquipment!.attachments![i].originalFileName ??
                  "plik nr ${i + 1}");
        }
      }
    }
    _calibrationDateController.text = _selectedDate != null
        ? DateFormat('dd.MM.yyyy').format(_selectedDate!)
        : "";

    return Scaffold(
      appBar: AppBar(
        title: widget.editedEquipment == null
            ? Text("Dodaj nowy sprzęt")
            : Text("Edytuj sprzęt (id: ${widget.editedEquipment!.id})"),
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
              textInputAction: TextInputAction.next,
            ),
            SizedBox(
              height: separationHeight,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Lokalizacja"),
              controller: _locationController,
              textInputAction: TextInputAction.next,
              cursorHeight: 20,
            ),
            SizedBox(height: separationHeight),
            TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              cursorHeight: 20,
              decoration: InputDecoration(labelText: "Opis urządzenia"),
              controller: _descriptionController,
            ),
            SizedBox(
              height: separationHeight,
            ),
            TextFormField(
              controller: _calibrationDateController,
              decoration: InputDecoration(
                  labelText: "Data następnego wzorcowania",
                  border: OutlineInputBorder()),
              readOnly: true,
              onTap: () async {
                _selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(Duration(days: 1)),
                    firstDate: DateTime.now().add(Duration(days: 1)),
                    lastDate: DateTime.now().add(Duration(days: 36500)),
                    cancelText: "Usuń deklarację",
                    confirmText: "Wybierz datę");

                setState(() {});
              },
            ),
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Text("opcjonalnie"),
            ),
            SizedBox(
              height: separationHeight,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: _selectedFileNames.isEmpty
                        ? Text("Nie wybrano plików")
                        : Text(
                            "Wybrano ${_selectedFileNames.length} ${Utils.polishPlural("plik", "pliki", "plików", _selectedFileNames.length)}"),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () async {
                      bool ready =
                          await FileUtils.checkStoragePermissions(context);
                      if (!ready) return;

                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                              dialogTitle: "Wybierz załączniki",
                              type: FileType.any,
                              allowMultiple: true);

                      setState(() {
                        if (result != null) {
                          _selectedFilePaths.addAll(
                              result.paths.whereType<String>().toList());
                          _selectedFileNames.addAll(
                              result.names.whereType<String>().toList());
                          _isFileRemote
                              .addAll(_selectedFileNames.map((e) => false));
                        }
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
              height: 10,
            ),
            ListView.builder(
                itemCount: _selectedFileNames.length,
                itemBuilder: (context, index) => Card(
                      child: ListTile(
                        title: Text(_selectedFileNames[index],
                            overflow: TextOverflow.ellipsis),
                        dense: true,
                        trailing: _isFileRemote[index]
                            ? Icon(
                                Icons.cloud_outlined,
                                color: Colors.cyan,
                              )
                            : IconButton(
                                constraints:
                                    BoxConstraints.tight(Size.square(24)),
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.delete),
                                enableFeedback: true,
                                color: Colors.red.shade800,
                                onPressed: () {
                                  setState(() {
                                    _selectedFilePaths.removeAt(index);
                                    _selectedFileNames.removeAt(index);
                                    _isFileRemote.removeAt(index);
                                  });
                                },
                              ),
                      ),
                    ),
                shrinkWrap: true),
            SizedBox(
              height: separationHeight,
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  if (_nameController.value.text.isEmpty ||
                      _locationController.value.text.isEmpty ||
                      _descriptionController.value.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Uzupełnij nazwę, opis i lokalizację.')));
                    return;
                  }
                  if (widget.editedEquipment == null) {
                    int newEquipmentId = await EquipmentService.createEquipment(
                        _nameController.value.text,
                        _locationController.value.text,
                        _descriptionController.value.text,
                        _selectedDate,
                        _selectedFilePaths,
                        _selectedFileNames,
                        context);
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EquipmentDetailsPage(
                              EquipmentService.getEquipment(newEquipmentId)),
                        ));
                  } else {
                    await EquipmentService.updateEquipment(
                        widget.editedEquipment!.id,
                        _nameController.value.text,
                        _locationController.value.text,
                        _descriptionController.value.text,
                        _selectedDate,
                        _selectedFilePaths.sublist(_numberOfRemoteFiles),
                        _selectedFileNames.sublist(_numberOfRemoteFiles),
                        context);
                    Navigator.pop(context);
                  }
                },
                child: widget.editedEquipment == null
                    ? Text("Dodaj nowy sprzęt")
                    : Text("Zapisz sprzęt"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
