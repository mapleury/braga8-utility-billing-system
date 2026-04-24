import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/data/models/tenant_model.dart';
import 'package:flutter/material.dart';
import 'package:braga8_mobile/components/unit_header_component.dart';
import 'package:braga8_mobile/components/unit_meter_table_component.dart';


class DaftarUnitScreen extends StatefulWidget {
  final ApiService api;
  const DaftarUnitScreen({super.key, required this.api});
  

  @override
  State<DaftarUnitScreen> createState() => _DaftarUnitScreenState();
}

class _DaftarUnitScreenState extends State<DaftarUnitScreen> {
  late Future<List<Tenant>> _tenantData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

 // Inside _DaftarUnitScreenState
void _loadData() {
  setState(() {
    // This will work because the Singleton holds the login token!
    _tenantData = ApiService().fetchUnitsSummary(); 
  });
}
  void _handleSearch(String query) {
    debugPrint("Searching for: $query");
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Filter Options", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            ListTile(title: const Text("Floor 1-5"), leading: const Icon(Icons.layers), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text("Unchecked Meter Only"), leading: const Icon(Icons.warning_amber), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Unit Management", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              UnitHeaderComponent(
                onSearch: _handleSearch,
                onFilterTap: _showFilterModal,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Tenant>>(
                  future: _tenantData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No units found."));
                    }

                    final tenants = snapshot.data!;

                    // We flatten the list to show every unit from every tenant
                    return ListView.builder(
                      itemCount: tenants.length,
                      itemBuilder: (context, tIndex) {
                        final tenant = tenants[tIndex];
                        return Column(
                          children: tenant.units.map((unit) => UnitMeterTableComponent(
                            tenantName: tenant.name,
                            unit: unit,
                          )).toList(),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}