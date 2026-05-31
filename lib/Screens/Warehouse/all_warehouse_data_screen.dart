import 'package:flutter/material.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_home/incharge_service.dart';
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
    ); // Small delay for dialog

    // Wait for district code to be loaded if not already
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

      if (!mounted) return;
      Navigator.pop(context);

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
          warehouseResponse?.error ?? "Failed to load warehouse data",
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  void _applyFilters() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      String selectedTab = statusTabs[_tabController.index].toLowerCase();

      filteredWarehouses = allWarehouses.where((item) {
        bool matchesSearch =
            item.wareHouseName?.toLowerCase().contains(query) ?? false;
        bool matchesStatus =
            selectedTab == "all" || item.status?.toLowerCase() == selectedTab;
        bool matchesDistrict =
            selectedDistrict == null || item.districTCODE == selectedDistrict;
        return matchesSearch && matchesStatus && matchesDistrict;
      }).toList();
    });
  }

  String _getTabLabel(String status) {
    int count = 0;
    if (status.toLowerCase() == "all") {
      count = allWarehouses.length;
    } else {
      count = allWarehouses
          .where((w) => w.status?.toLowerCase() == status.toLowerCase())
          .length;
    }
    return "$status ($count)";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text("All Warehouse Data"),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.green.shade800,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: statusTabs
                    .map((status) => Tab(text: _getTabLabel(status)))
                    .toList(),
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
                  tabs: statusTabs
                      .map((status) => Tab(text: _getTabLabel(status)))
                      .toList(),
                ),
              ),
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
                    hint: const Text("Select District"),
                    value: selectedDistrict,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text("All Districts"),
                      ),
                      ...districtList.where((d) => d.district != null).map((
                        district,
                      ) {
                        return DropdownMenuItem<String?>(
                          value: district.district,
                          child: Text(district.districtNameEN ?? "Unknown"),
                        );
                      }).toList(),
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
                    hintText: "Search by Name",
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
                  ? const Center(child: Text("No Data Found"))
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              "District",
              _getDistrictName(item.districTCODE),
            ),
            _buildDetailRow(
              Icons.pin_drop,
              "Coordinates",
              "${item.lat?.toStringAsFixed(5) ?? 'N/A'}, ${item.long?.toStringAsFixed(5) ?? 'N/A'}",
            ),
            _buildDetailRow(
              Icons.inventory_2,
              "Capacity",
              "${item.capacity ?? 'N/A'} MT",
            ),
            _buildDetailRow(
              Icons.badge,
              "Warehouse ID",
              "${item.wareHouseId ?? 'N/A'}",
            ),
            _buildDetailRow(
              Icons.calendar_today,
              "Construction Year",
              item.constructionYear ?? "N/A",
            ),
            _buildDetailRow(
              Icons.person,
              "Owner Name",
              item.ownerName ?? "N/A",
            ),
            _buildDetailRow(
              Icons.check_circle_outline,
              "Condition",
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
    if (status?.toLowerCase() == "updated") {
      badgeColor = Colors.green;
    } else if (status?.toLowerCase() == "pending") {
      badgeColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        status ?? "Unknown",
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
