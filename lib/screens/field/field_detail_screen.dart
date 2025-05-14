import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bitirme/models/field_model.dart';
import 'package:flutter_bitirme/models/sensor_model.dart';
import 'package:flutter_bitirme/screens/sensor/sensor_graph_screen.dart';
import 'package:flutter_bitirme/theme/app_theme.dart';

import 'field_screen.dart';

class FieldDetailScreen extends StatefulWidget {
  final String fieldId;

  const FieldDetailScreen({Key? key, required this.fieldId}) : super(key: key);

  @override
  _FieldDetailScreenState createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  bool _isLoading = false;
  FieldModel? _fieldData;

  @override
  void initState() {
    super.initState();
    _loadFieldData();
  }

  Future<void> _loadFieldData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Tarlalar')
          .doc(widget.fieldId)
          .get();

      if (doc.exists) {
        setState(() {
          _fieldData = FieldModel.fromJson(doc.data()!);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarla bulunamadı')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarla bilgileri yüklenirken hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarla Detayları'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _fieldData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Tarla bilgileri yüklenemedi',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: AppTheme.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldScreen(
                                  fieldId: widget.fieldId,
                                ),
                              ),
                            ).then((_) => _loadFieldData());
                          },
                          child: Padding(
                            padding: AppTheme.cardPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tarla Bilgileri',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    Icon(Icons.edit,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ],
                                ),
                                SizedBox(height: 16),
                                _buildInfoRow(
                                    'Tarla Adı', _fieldData!.tarlaIsmi),
                                _buildInfoRow('Konum', '${_fieldData!.konum}'),
                                _buildInfoRow(
                                    'Alan', '${_fieldData!.boyut} hektar'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: AppTheme.cardPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sensör Verileri',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Sensör eklemek için yönetici ile iletişime geçin.'),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.add),
                                      label: Text('Sensör Ekle'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Sensorler')
                                    .where('Tarla_id',
                                        isEqualTo: widget.fieldId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.sensors,
                                            size: 48,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.5),
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Henüz sensör bulunmuyor',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Sensör eklemek için yönetici ile iletişime geçin',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      final doc = snapshot.data!.docs[index];
                                      final sensor = SensorModel.fromJson(
                                          doc.data() as Map<String, dynamic>);

                                      return ListTile(
                                        leading: Icon(Icons.sensors),
                                        title: Text(sensor.sensorAdi),
                                        subtitle: Text(sensor.sensorTipi),
                                        trailing: Icon(Icons.arrow_forward_ios),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SensorGraphScreen(
                                                sensorId: doc.id,
                                                sensorName: "",
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
