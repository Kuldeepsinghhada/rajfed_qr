import 'package:flutter/material.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_home/incharge_service.dart';
import 'package:rajfed_qr/Screens/Warehouse/warehouse_capacity_screen.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/district_model.dart';
import 'package:rajfed_qr/models/warehouse_model.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class AllWareHouseDataScreen extends StatefulWidget {
  final bool showAppBar;
  const AllWareHouseDataScreen({super.key, this.showAppBar = true});

  @override
  State<AllWareHouseDataScreen> createState() => AllWareHouseDataScreenState();
}

class AllWareHouseDataScreenState extends State<AllWareHouseDataScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  List<WareHouseModel> allWarehouses = [];
  List<WareHouseModel> filteredWarehouses = [];
  List<DistrictModel> districtList = [];
  String? selectedDistrict;
  int? userType;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  final List<String> statusTabs = ["All", "Updated", "Pending"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: statusTabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadUserType();
    fetchData();
  }

  String? loginDistrictCode;

  void _loadUserType() async {
    int? type = await SharedPreferenceHelper.instance.getUserType();
    String? dCode = await SharedPreferenceHelper.instance.getDistrictCode();
    if (mounted) {
      setState(() {
        userType = type;
        loginDistrictCode = dCode;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchData();
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    _applyFilters();
  }

  void fetchData() async {
    await Future.delayed(
      const Duration(milliseconds: 100),
    );

    String? dCode = await SharedPreferenceHelper.instance.getDistrictCode();
    if (!mounted) return;
    showLoadingDialog(context);
    try {
      final results = await Future.wait([
        InchargeService.instance.getDistrictList(),
        InchargeService.instance.getAllWarehouseData(districtCode: dCode),
      ]);

      final districtResponse = results[0];
      final warehouseResponse = results[1];

      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

      if (districtResponse?.status == true) {
        districtList = districtResponse?.data ?? [];
      }

      if (warehouseResponse?.status == true) {
        setState(() {
          allWarehouses = warehouseResponse?.data ?? [];
          _applyFilters();
        });
      } else {
        showErrorToast(
          warehouseResponse?.error ?? "वेयरहाउस डेटा लोड करने में विफलता",
        );
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) showErrorToast("कुछ गलत हो गया");
    }
  }

  void _applyFilters() {
    setState(() {
      String query = _searchController.text.toLowerCase().trim();
      int selectedIdx = _tabController.index;

      filteredWarehouses = allWarehouses.where((item) {
        bool matchesSearch = query.isEmpty ||
            (item.wareHouseName?.toLowerCase().contains(query) ?? false);
        
        bool matchesStatus = true;
        if (selectedIdx == 1) { // Updated
          matchesStatus = item.status?.toLowerCase() == "updated";
        } else if (selectedIdx == 2) { // Pending
          matchesStatus = item.status?.toLowerCase() == "pending";
        }

        bool matchesDistrict =
            selectedDistrict == null || item.districTCODE == selectedDistrict;
        return matchesSearch && matchesStatus && matchesDistrict;
      }).toList();
    });
  }

  String _getTabLabel(int index, String statusName) {
    int count = 0;
    if (index == 0) {
      count = allWarehouses.length;
    } else if (index == 1) {
      count = allWarehouses
          .where((w) => w.status?.toLowerCase() == "updated")
          .length;
    } else if (index == 2) {
      count = allWarehouses
          .where((w) => w.status?.toLowerCase() == "pending")
          .length;
    }
    return "$statusName ($count)";
  }

  void _navigateToAddWarehouseDetails() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WarehouseCapacityScreen(showAppBar: true),
      ),
    );
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text("सभी वेयरहाउस डेटा"),
              actions: [
                IconButton(
                  onPressed: _navigateToAddWarehouseDetails,
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: "वेयरहाउस विवरण जोड़ें",
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.green.shade800,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: List.generate(
                  statusTabs.length,
                  (index) => Tab(text: _getTabLabel(index, statusTabs[index])),
                ),
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.green.shade800,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black54,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: List.generate(
                    statusTabs.length,
                    (index) => Tab(text: _getTabLabel(index, statusTabs[index])),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddWarehouseDetails,
        backgroundColor: Colors.green.shade800,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("वेयरहाउस विवरण जोड़ें", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (userType == 8 && loginDistrictCode == null) ...[
                  DropdownButtonFormField<String?>(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    hint: const Text("जिला चुनें"),
                    value: selectedDistrict,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text("सभी जिले"),
                      ),
                      ...districtList.where((d) => d.district != null).map((
                        district,
                      ) {
                        return DropdownMenuItem<String?>(
                          value: district.district,
                          child: Text(district.districtNameEN ?? "Unknown"),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedDistrict = value;
                        _applyFilters();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: "नाम से खोजें...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                fetchData();
              },
              child: filteredWarehouses.isEmpty
                  ? const Center(child: Text("कोई वेयरहाउस डेटा नहीं मिला"))
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: filteredWarehouses.length,
                      itemBuilder: (context, index) {
                        final item = filteredWarehouses[index];
                        return _buildWarehouseCard(item);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDistrictName(String? districtCode) {
    if (districtCode == null || districtCode.isEmpty) return "N/A";
    try {
      final district = districtList.firstWhere(
        (d) => d.district == districtCode,
      );
      return "${district.districtNameEN ?? 'Unknown'} ($districtCode)";
    } catch (e) {
      return districtCode;
    }
  }

  Widget _buildWarehouseCard(WareHouseModel item) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.wareHouseName ?? "N/A",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                _buildStatusBadge(item.status),
              ],
            ),
            const Divider(height: 20),
            _buildDetailRow(
              Icons.location_city,
              "जिला",
              _getDistrictName(item.districTCODE),
            ),
            _buildDetailRow(
              Icons.pin_drop,
              "स्थान निर्देशांक",
              "${item.lat?.toStringAsFixed(5) ?? 'N/A'}, ${item.long?.toStringAsFixed(5) ?? 'N/A'}",
            ),
            _buildDetailRow(
              Icons.inventory_2,
              "क्षमता",
              "${item.capacity ?? 'N/A'} मीट्रिक टन (MT)",
            ),
            _buildDetailRow(
              Icons.store,
              "अतिरिक्त गोदाम",
              "${item.extraGodam ?? 'N/A'}",
            ),
            _buildDetailRow(
              Icons.badge,
              "वेयरहाउस आईडी",
              "${item.wareHouseId ?? 'N/A'}",
            ),
            _buildDetailRow(
              Icons.calendar_today,
              "निर्माण का वर्ष",
              item.constructionYear ?? "N/A",
            ),
            _buildDetailRow(
              Icons.person,
              "मालिक का नाम",
              item.ownerName ?? "N/A",
            ),
            _buildDetailRow(
              Icons.check_circle_outline,
              "स्थिति",
              item.warehouseCondtion ?? "N/A",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color badgeColor = Colors.grey;
    String statusText = "अज्ञात";
    if (status?.toLowerCase() == "updated") {
      badgeColor = Colors.green;
      statusText = "अद्यतन (Updated)";
    } else if (status?.toLowerCase() == "pending") {
      badgeColor = Colors.orange;
      statusText = "लंबित (Pending)";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
