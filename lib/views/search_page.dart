import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inwentarz_ee/data_access/equipment_service.dart';
import 'package:inwentarz_ee/data_access/models/equipment.dart';
import 'package:inwentarz_ee/views/equipment_details_page.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  bool _isfirstBuild = true;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _searchInDescriptionController = false;

  Future<List<Equipment>> _searchResultFuture = Future(() => []);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Szukaj"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: "ID",
                        border: OutlineInputBorder(),
                      ),
                      controller: _idController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.search,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onFieldSubmitted: (value) => setState(() {
                        _searchResultFuture = EquipmentService.doSearch(
                            _idController.text,
                            _locationController.text,
                            _nameController.text,
                            _searchInDescriptionController);
                      }),
                      cursorHeight: 20,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: "Lokalizacja (np. GE)",
                        border: OutlineInputBorder(),
                      ),
                      controller: _locationController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (value) => setState(() {
                        _searchResultFuture = EquipmentService.doSearch(
                            _idController.text,
                            _locationController.text,
                            _nameController.text,
                            _searchInDescriptionController);
                      }),
                      cursorHeight: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: "Nazwa" +
                      (_searchInDescriptionController ? " lub opis" : ""),
                  border: OutlineInputBorder(),
                ),
                controller: _nameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                cursorHeight: 20,
                onFieldSubmitted: (value) => setState(() {
                  _searchResultFuture = EquipmentService.doSearch(
                      _idController.text,
                      _locationController.text,
                      _nameController.text,
                      _searchInDescriptionController);
                }),
              ),
              SizedBox(
                height: 15,
              ),
              CheckboxListTile(
                value: _searchInDescriptionController,
                controlAffinity: ListTileControlAffinity.leading,
                visualDensity: VisualDensity.compact,
                title: Text("Szukaj również w opisie"),
                onChanged: (value) => setState(() {
                  _searchInDescriptionController = value ?? false;
                }),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Text("Pokaż wszystkie"),
                    onPressed: () => setState(() {
                      _searchResultFuture = EquipmentService.getAll();
                    }),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    child: Text("Szukaj"),
                    onPressed: () => setState(() {
                      _searchResultFuture = EquipmentService.doSearch(
                          _idController.text,
                          _locationController.text,
                          _nameController.text,
                          _searchInDescriptionController);
                    }),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                child: FutureBuilder(
                  future: _searchResultFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done ||
                        !snapshot.hasData)
                      return Container(
                          height: 300,
                          child: Center(child: CircularProgressIndicator()));

                    return Column(
                      children: snapshot.data!
                          .map((e) => Padding(
                                padding: EdgeInsets.only(bottom: 15),
                                child: EquipmentTile(e),
                              ))
                          .toList(),
                      mainAxisSize: MainAxisSize.min,
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EquipmentTile extends StatelessWidget {
  const EquipmentTile(
    this.equipment, {
    super.key,
  });

  final Equipment equipment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async => await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            EquipmentDetailsPage(EquipmentService.getEquipment(equipment.id)),
      )),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 50),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 7)
              ],
              borderRadius: BorderRadius.circular(5)),
          child: Row(
            children: [
              SizedBox(
                width: 20,
              ),
              Container(
                width: 20,
                child: Center(
                  child: Text(
                    equipment.id.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(equipment.name ?? "Brak nazwy",
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1),
                    Text(equipment.location ?? "Lokalizacja nieznana",
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                  ],
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Icon(Icons.keyboard_arrow_right),
              SizedBox(width: 20)
            ],
          ),
        ),
      ),
    );
  }
}
