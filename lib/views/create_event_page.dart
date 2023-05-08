import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inwentarz_ee/data_access/event_service.dart';
import 'package:inwentarz_ee/data_access/models/event.dart';
import 'package:inwentarz_ee/services/file_utils.dart';
import 'package:inwentarz_ee/services/utils.dart';

class CreateEventPage extends StatefulWidget {
  CreateEventPage(this.equipmentId, {Key? key}) : super(key: key);

  final int equipmentId;

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _descriptionController = TextEditingController();

  List<String> _selectedFilePaths = [];
  List<String> _selectedFileNames = [];
  EventType _dropdownValue = EventType.values.first;

  @override
  Widget build(BuildContext context) {
    double _separationHeight = 20;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dodaj nowe zdarzenie"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
        child: ListView(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: DropdownButton<EventType>(
                value: _dropdownValue,
                items: EventType.values
                    .map((e) => DropdownMenuItem<EventType>(
                          value: e,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(e.icon),
                              SizedBox(
                                width: 7,
                              ),
                              Text(e.polishName),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _dropdownValue = value!;
                }),
              ),
            ),
            SizedBox(
              height: _separationHeight,
            ),
            TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              cursorHeight: 20,
              decoration: InputDecoration(labelText: "Komentarz do zdarzenia"),
              controller: _descriptionController,
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
                        trailing: IconButton(
                          constraints: BoxConstraints.tight(Size.square(24)),
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.delete),
                          enableFeedback: true,
                          color: Colors.red.shade800,
                          onPressed: () {
                            setState(() {
                              _selectedFilePaths.removeAt(index);
                              _selectedFileNames.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ),
                shrinkWrap: true),
            SizedBox(
              height: _separationHeight,
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  if (_descriptionController.value.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Uzupełnij opis.')));
                    return;
                  }
                  await EventService.createEvent(
                      widget.equipmentId,
                      _descriptionController.value.text,
                      _dropdownValue,
                      _selectedFilePaths,
                      _selectedFileNames,
                      context);
                  Navigator.pop(context);
                },
                child: Text("Dodaj zdarzenie"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
