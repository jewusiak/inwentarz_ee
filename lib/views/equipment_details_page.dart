import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inwentarz_ee/data_access/equipment_service.dart';
import 'package:inwentarz_ee/data_access/models/base_url.dart';
import 'package:inwentarz_ee/data_access/models/event.dart';
import 'package:inwentarz_ee/data_access/session_data.dart';
import 'package:inwentarz_ee/views/create_equipment_page.dart';
import 'package:inwentarz_ee/views/create_event_page.dart';
import 'package:inwentarz_ee/views/event_details_page.dart';
import 'package:inwentarz_ee/widgets/circular_indicator_dialog.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:photo_view/photo_view.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../data_access/models/equipment.dart';

class EquipmentDetailsPage extends StatefulWidget {
  EquipmentDetailsPage(this._equipmentProvider, {Key? key}) : super(key: key);

  Future<Equipment> _equipmentProvider;

  @override
  State<EquipmentDetailsPage> createState() =>
      _EquipmentDetailsPageState(_equipmentProvider);
}

class _EquipmentDetailsPageState extends State<EquipmentDetailsPage> {
  late Equipment equipment;
  Future<Equipment> _provider;
  bool _errorOccured = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Szczegóły aparatury"),
        actions: !SessionData().authenticated
            ? null
            : [
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 0,
                      child: Text("Edytuj"),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Text("Wygeneruj kod QR"),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text("Dodaj zdarzenie"),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: Text("Usuń"),
                    ),
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 0:
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateOrEditEquipmentPage(
                                editedEquipment: equipment,
                              ),
                            ));
                        setState(() {
                          _provider =
                              EquipmentService.getEquipment(equipment.id);
                        });
                        break;
                      case 1:
                        final doc = pw.Document();
                        showCircularProgressIndicatorDialog(context);
                        var qrCodeAsBytes =
                            await EquipmentService.generateQrCodeAsBytes(
                                equipment.id);
                        doc.addPage(pw.Page(
                            pageFormat: PdfPageFormat.a4,
                            build: (context) => pw.Align(
                                alignment: pw.Alignment(-1, 1),
                                child: pw.Image(pw.MemoryImage(qrCodeAsBytes),
                                    height: 150))));
                        Printing.layoutPdf(
                          onLayout: (format) async => await doc.save(),
                        );
                        Navigator.pop(context);
                        break;
                      case 2:
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CreateEventPage(equipment.id),
                            ));
                        setState(() {
                          _provider =
                              EquipmentService.getEquipment(equipment.id);
                        });
                        break;
                      case 3:
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                              title: Text("Uwaga"),
                              content: Text(
                                  "Czy na pewno chcesz usunąć to urządzenie?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Anuluj"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    showCircularProgressIndicatorDialog(
                                        context);
                                    await EquipmentService.removeEquipment(
                                        equipment.id);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Text("Usuń",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w900)),
                                ),
                              ]),
                        );
                        break;
                    }
                  },
                )
              ],
      ),
      body: FutureBuilder(
        future: _provider,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Błąd",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    "Nie znaleziono tego urządzenia.",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            equipment = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _provider = EquipmentService.getEquipment(equipment.id);
                });
              },
              child: ListView(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                shrinkWrap: true,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    child: equipment.attachments!.length > 0
                        ? CarouselSlider.builder(
                            options: CarouselOptions(),
                            itemCount: equipment.attachments!.length,
                            itemBuilder: (context, index, realIndex) =>
                                Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              margin: EdgeInsets.fromLTRB(5, 0, 5, 20),
                              //padding: EdgeInsets.all(10),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ['JPEG', 'PNG'].contains(snapshot
                                          .data!
                                          .attachments![index]
                                          .viewableAttachmentType)
                                      ? GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => PhotoView(
                                                  maxScale: 5.0,
                                                  loadingBuilder: (context,
                                                          event) =>
                                                      Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                  imageProvider: NetworkImage(
                                                      BaseUrl.baseHttpsUrl +
                                                          snapshot
                                                              .data!
                                                              .attachments![
                                                                  index]
                                                              .downloadUrl!)),
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            child: Image.network(
                                              BaseUrl.baseHttpsUrl +
                                                  snapshot
                                                      .data!
                                                      .attachments![index]
                                                      .downloadUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.attach_file, size: 40),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15.0),
                                                child: Text(
                                                  snapshot
                                                      .data!
                                                      .attachments![index]
                                                      .originalFileName!,
                                                  softWrap: false,
                                                  overflow: TextOverflow.fade,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  Positioned(
                                    bottom: 10,
                                    right: 0,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await launchUrlString(
                                            BaseUrl.baseHttpsUrl +
                                                snapshot
                                                    .data!
                                                    .attachments![index]
                                                    .downloadUrl!,
                                            mode:
                                                LaunchMode.externalApplication);
                                      },
                                      child: Icon(Icons.file_download),
                                      style: ElevatedButton.styleFrom(
                                          shape: CircleBorder()),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              "Brak załączników",
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              equipment.name ?? "Nazwa nieznana",
                              style: Theme.of(context).textTheme.headlineSmall,
                              softWrap: true,
                            ),
                            Text(
                              equipment.location ?? "Lokalizacja nieznana",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    equipment.description ?? "Brak opisu",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Następne wzorcowanie: ${equipment.nextCalibration != null ? DateFormat('dd.MM.yyyy').format(DateTime.parse(equipment.nextCalibration!)) : "nie ustawiono"}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  (equipment.events?.length ?? 0) > 0
                      ? Stack(
                          children: [
                            //timeline end dots
                            ...[0, 1, 2].map(
                              (index) => Positioned(
                                left: 25,
                                bottom: 6.0 * index,
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                            ),

                            //timeline start arrows
                            Positioned(
                              left: 12,
                              top: 0,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.keyboard_double_arrow_down,
                                  size: 30,
                                ),
                                onPressed: () => {},
                                color: Colors.blueGrey,
                              ),
                            ),

                            //timeline main line
                            Positioned(
                              top: 30,
                              left: 25,
                              bottom: 18,
                              child: Container(
                                width: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),

                            //timeline elements
                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.only(top: 40, bottom: 28),
                              itemCount: equipment.events?.length ?? 0,
                              shrinkWrap: true,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 20,
                              ),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () async {
                                    if (await Navigator.push(
                                            context,
                                            MaterialPageRoute<bool>(
                                                builder: (context) =>
                                                    EventDetailsPage(
                                                        snapshot.data!
                                                            .events![index],
                                                        equipment.id))) ??
                                        false)
                                      setState(() {
                                        _provider =
                                            EquipmentService.getEquipment(
                                                equipment.id);
                                      });
                                  },
                                  child: EventRow(
                                    equipment.events![index],
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : Container(),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "id: ${equipment.id}",
                    style: TextStyle(color: Colors.black38),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }

  _EquipmentDetailsPageState(this._provider);
}

class EventRow extends StatelessWidget {
  const EventRow(this.timelineEvent, {super.key});

  final Event timelineEvent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(width: 15, color: Colors.grey)),
          child: Icon(
            timelineEvent.eventType?.icon ?? Icons.question_mark,
            color: Colors.black,
            size: 24,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timelineEvent.comment ?? "Brak opisu",
                softWrap: false,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                timelineEvent.createdBy! != null
                    ? "Utworzony przez: " +
                        (timelineEvent.createdBy!.displayName ??
                            timelineEvent.createdBy!.email)
                    : "Brak autora.",
              ),
              Text(
                DateFormat("dd.MM.y o HH:mm").format(
                    DateTime.parse(timelineEvent.dateCreated!).toLocal()),
              ),
            ],
          ),
        ),
        const Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.chevron_right, size: 30),
        )
      ],
    );
  }
}
