import 'package:braga8_mobile/data/models/tenant_model.dart';
import 'package:braga8_mobile/views/detail_unit_screen.dart';
import 'package:flutter/material.dart';

class UnitMeterTableComponent extends StatelessWidget {
  final String tenantName;
  final Unit unit;

  const UnitMeterTableComponent({
    super.key,
    required this.tenantName,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ROW 1: Real Tenant Information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.person, size: 16, color: Colors.blue),
                ),
                const SizedBox(width: 10),
                Text(
                  tenantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "1 unit", // Since the API returns units individually here
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 28,
              headingRowHeight: 45,
              dataRowHeight: 60,
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
              columns: const [
                DataColumn(label: Text('Unit')),
                DataColumn(label: Text('Floor')),
                DataColumn(label: Text('Electricity')),
                DataColumn(label: Text('Water')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        unit.unitNumber,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(Text(unit.floor)),
                    DataCell(_buildStatusBadge(unit.isElecChecked)),
                    DataCell(_buildStatusBadge(unit.isWaterChecked)),
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailUnitScreen(
                                shopName:
                                    tenantName, // This is the Shop/Tenant name from your API loop
                                unit: unit, // The specific unit object
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF723CFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "View",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isChecked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isChecked ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isChecked ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.error_outline,
            size: 14,
            color: isChecked ? Colors.green.shade700 : Colors.red.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            isChecked ? "Checked" : "Unchecked",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isChecked ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
