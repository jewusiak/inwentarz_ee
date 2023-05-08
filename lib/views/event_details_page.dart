import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inwentarz_ee/data_access/event_service.dart';
import 'package:inwentarz_ee/data_access/models/base_url.dart';
import 'package:inwentarz_ee/data_access/models/event.dart';
import 'package:inwentarz_ee/data_access/session_data.dart';
import 'package:inwentarz_ee/widgets/circular_indicator_dialog.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher_string.dart';

class EventDetailsPage extends StatelessWidget {
  EventDetailsPage(this.event, this.equipmentId, {Key? key}) : super(key: key);

  Event event;
  int equipmentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Szczegóły zdarzenia"),
        actions: !SessionData().authenticated
            ? null
            : [
                IconButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                            title: Text("Uwaga"),
                            content: Text(
                                "Czy na pewno chcesz usunąć to zdarzenie?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Anuluj"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  showCircularProgressIndicatorDialog(context);
                                  await EventService.removeEvent(event.id);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.pop(context, true);
                                },
                                child: Text("Usuń",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w900)),
                              ),
                            ]),
                      );
                    },
                    icon: Icon(Icons.delete)),
              ],
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
        shrinkWrap: true,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            child: event.attachments!.length > 0
                ? CarouselSlider.builder(
                    options: CarouselOptions(),
                    itemCount: event.attachments!.length,
                    itemBuilder: (context, index, realIndex) => Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 20),
                      //padding: EdgeInsets.all(10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ['JPEG', 'PNG'].contains(event
                                  .attachments![index].viewableAttachmentType)
                              ? GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => PhotoView(
                                          loadingBuilder: (context, event) =>
                                              Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                          imageProvider: NetworkImage(
                                              BaseUrl.baseHttpsUrl +
                                                  event.attachments![index]
                                                      .downloadUrl!)),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    child: Image.network(
                                      BaseUrl.baseHttpsUrl +
                                          event
                                              .attachments![index].downloadUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.attach_file, size: 40),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Text(
                                          event.attachments![index]
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
                                        event.attachments![index].downloadUrl!,
                                    mode: LaunchMode.externalApplication);
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
                    Row(
                      children: [
                        Icon(event.eventType?.icon ?? Icons.question_mark),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          event.eventType?.polishName ?? "Nieznany",
                          style: Theme.of(context).textTheme.headlineSmall,
                          softWrap: true,
                        ),
                      ],
                      mainAxisSize: MainAxisSize.min,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      (event.createdBy! != null
                          ? "Utworzony przez: " +
                              (event.createdBy!.displayName ??
                                  event.createdBy!.email)
                          : "Brak autora."),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      DateFormat("dd.MM.y o HH:mm")
                          .format(DateTime.parse(event.dateCreated!).toLocal()),
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
            event.comment ?? "Brak opisu",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "id: ${event.id}",
            style: TextStyle(color: Colors.black38),
          )
        ],
      ),
    );
  }
}
