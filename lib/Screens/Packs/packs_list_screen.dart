import 'package:flutter/material.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_home/incharge_service.dart';
import 'package:rajfed_qr/Screens/Packs/packs_details_screen.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/district_model.dart';
import 'package:rajfed_qr/models/packs_model.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class PacksListScreen extends StatefulWidget {
  final bool showAppBar;
  const PacksListScreen({super.key, this.showAppBar = true});

  @override
  State<PacksListScreen> createState() => PacksListScreenState();
}

class PacksListScreenState extends State<PacksListScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  List<PacksModel> allPacks = [];
  List<PacksModel> filteredPacks = [];
  List<DistrictModel> districtList = [];
  String? selectedDistrict;
  int? userType;
  String? loginDistrictCode;

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
    await Future.delayed(const Duration(milliseconds: 100));
    String? dCode = await SharedPreferenceHelper.instance.getDistrictCode();
    if (!mounted) return;
    showLoadingDialog(context);
    try {
      final results = await Future.wait([
        InchargeService.instance.getDistrictList(),
        InchargeService.instance.getAllPacksData(districtCode: dCode),
      ]);

      final districtResponse = results[0];
      final packsResponse = results[1];

      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

      if (districtResponse?.status == true) {
        districtList = districtResponse?.data ?? [];
      }

      if (packsResponse?.status == true) {
        setState(() {
          allPacks = packsResponse?.data ?? [];
          _applyFilters();
        });
      } else {
        showErrorToast(packsResponse?.error ?? "Failed to load Pacs data");
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) showErrorToast("Something went wrong");
    }
  }

  void _applyFilters() {
    setState(() {
      String query = _searchController.text.toLowerCase().trim();
      int selectedIdx = _tabController.index;

      filteredPacks = allPacks.where((item) {
        bool matchesSearch =
            query.isEmpty ||
            (item.wareHouseName?.toLowerCase().contains(query) ?? false) ||
            (item.blocKENG?.toLowerCase().contains(query) ?? false) ||
            (item.inchargeName?.toLowerCase().contains(query) ?? false) ||
            (item.chairmanName?.toLowerCase().contains(query) ?? false);

        bool matchesStatus = true;
        if (selectedIdx == 1) {
          // Submitted tab: items with submitted details
          matchesStatus = item.isSubmitted;
        } else if (selectedIdx == 2) {
          // Pending tab: items without submitted details
          matchesStatus = !item.isSubmitted;
        }

        bool matchesDistrict =
            selectedDistrict == null ||
            item.districTCODE == selectedDistrict ||
            (item.districTCODE != null &&
                item.districTCODE!.trim() == selectedDistrict!.trim());
        return matchesSearch && matchesStatus && matchesDistrict;
      }).toList();
    });
  }

  String _getTabLabel(int index, String statusName) {
    int count = 0;
    if (index == 0) {
      count = allPacks.length;
    } else if (index == 1) {
      count = allPacks.where((p) => p.isSubmitted).length;
    } else if (index == 2) {
      count = allPacks.where((p) => !p.isSubmitted).length;
    }
    return "$statusName ($count)";
  }

  void _navigateToAddPacks() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PacksDetailsScreen(showAppBar: true),
      ),
    );
    if (result == true) {
      fetchData();
    }
  }

  void _navigateToEditPacks(PacksModel item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PacksDetailsScreen(showAppBar: true, packsModel: item),
      ),
    );
    if (result == true) {
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text("Pacs List"),
              actions: [
                IconButton(
                  onPressed: _navigateToAddPacks,
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: "Update Pacs Details",
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
                    (index) =>
                        Tab(text: _getTabLabel(index, statusTabs[index])),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPacks,
        backgroundColor: Colors.green.shade800,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Pacs Details",
          style: TextStyle(color: Colors.white),
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
                    hintText: "Search by Pacs Name / Block / Vyavasthapak...",
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
              child: filteredPacks.isEmpty
                  ? const Center(child: Text("No Pacs Data Found"))
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: filteredPacks.length,
                      itemBuilder: (context, index) {
                        final item = filteredPacks[index];
                        return _buildPacksCard(item);
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

  Widget _buildPacksCard(PacksModel item) {
    String chargeLabel = item.regular == "N" ? "अतिरिक्त प्रभार" : "नियमित";

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToEditPacks(item),
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
                  _buildStatusBadge(item),
                ],
              ),
              const Divider(height: 20),
              _buildDetailRow(
                Icons.location_city,
                "District",
                _getDistrictName(item.districTCODE),
              ),
              _buildDetailRow(Icons.map, "Block Name", item.blocKENG ?? "N/A"),
              _buildDetailRow(
                Icons.person,
                "Adhyax Name",
                item.chairmanName ?? "N/A",
              ),
              _buildDetailRow(
                Icons.badge,
                "Vyavasthapak Name",
                "${item.inchargeName ?? 'N/A'} ($chargeLabel)",
              ),
              _buildDetailRow(
                Icons.phone,
                "Vyavasthapak Mobile",
                item.mobileNo ?? "N/A",
              ),
              _buildDetailRow(
                Icons.person_outline,
                "Sah Vyavasthapak",
                item.coInchargeName ?? "N/A",
              ),
              _buildDetailRow(
                Icons.pin_drop,
                "Coordinates",
                "${item.lat ?? 'N/A'}, ${item.long ?? 'N/A'}",
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildTag("E-Pacs", item.ePacs == "Y"),
                  _buildTag("KSK", item.pmksk == "Y"),
                  _buildTag("CHC", item.chc == "Y"),
                  _buildTag("Office Building", item.officeBuilding == "Y"),
                  _buildTag("Shree Anna", item.sheeAnna == "Y"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildTag(String name, bool enabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: enabled ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: enabled ? Colors.green.shade400 : Colors.red.shade300,
        ),
      ),
      child: Text(
        "$name: ${enabled ? 'Yes' : 'No'}",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: enabled ? Colors.green.shade900 : Colors.red.shade900,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PacksModel item) {
    bool submitted = item.isSubmitted;
    Color badgeColor = submitted ? Colors.green : Colors.orange;
    String statusText = submitted ? "Updated" : "Pending";

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
