import 'package:bus_ticket_app/core/province/list_province_service.dart';
import 'package:bus_ticket_app/utils/helper/distance_caculator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_cubit.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_state.dart';
import 'package:bus_ticket_app/core/user/cubit/user_cubit.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diacritic/diacritic.dart';

class BusRouteAddScreen extends StatefulWidget {
  const BusRouteAddScreen({super.key});

  @override
  State<BusRouteAddScreen> createState() => _BusRouteAddScreenState();
}

class _BusRouteAddScreenState extends State<BusRouteAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _distanceController = TextEditingController();
  final _listProvinceService = ListProvinceService();

  ListProvince? _selectedDeparture;
  ListProvince? _selectedDestination;
  BusRouteStatus _selectedStatus = BusRouteStatus.active;
  List<ListProvince> _provinces = [];
  bool _isLoadingProvinces = true;
  int? distance;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await _listProvinceService.getProvinces();
      setState(() {
        _provinces = provinces;
        _isLoadingProvinces = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProvinces = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh sách tỉnh thành: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm Tuyến Đường',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.orange[300],
      ),
      body: BlocConsumer<BusRouteCubit, BusRouteState>(
        listener: _handleRouteStateChanges,
        builder: (context, routeState) => _buildBody(routeState),
      ),
    );
  }

  void _handleRouteStateChanges(BuildContext context, BusRouteState state) {
    if (state is BusRouteLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Thêm tuyến đường thành công!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }

    if (state is BusRouteError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(state.message)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildBody(BusRouteState routeState) {
    return Stack(
      children: [
        BlocBuilder<UserCubit, UserState>(
          builder: (context, userState) {
            if (userState is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (userState is! UserLoaded) {
              return _buildErrorState();
            }
            return _buildForm(userState.user, routeState);
          },
        ),
        if (routeState is BusRouteLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(user, BusRouteState routeState) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRouteInfoCard(),
          const SizedBox(height: 16),
          _buildPriceDistanceCard(),
          const SizedBox(height: 16),
          _buildStatusCard(),
          const SizedBox(height: 24),
          _buildActionButtons(user.id, routeState),
        ],
      ),
    );
  }

  Widget _buildRouteInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Thông tin tuyến đường',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00424B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildProvinceSelector(
              label: 'Điểm đi',
              icon: Icons.trip_origin,
              selectedProvince: _selectedDeparture,
              onSelect: (province) {
                setState(() {
                  _selectedDeparture = province;
                });
                _updateDistance();
              },
            ),

            const SizedBox(height: 16),

            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.swap_vert, color: Colors.orange),
                  onPressed: _swapLocations,
                ),
              ),
            ),

            const SizedBox(height: 16),

            _buildProvinceSelector(
              label: 'Điểm đến',
              icon: Icons.location_on,
              selectedProvince: _selectedDestination,
              onSelect: (province) {
                setState(() {
                  _selectedDestination = province;
                });
                _updateDistance();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvinceSelector({
    required String label,
    required IconData icon,
    required ListProvince? selectedProvince,
    required Function(ListProvince) onSelect,
  }) {
    return InkWell(
      onTap: () => _showProvinceDialog(onSelect),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.orange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon:
              selectedProvince != null
                  ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        if (label == 'Điểm đi') {
                          _selectedDeparture = null;
                        } else {
                          _selectedDestination = null;
                        }
                        _distanceController.clear();
                        distance = null;
                      });
                    },
                  )
                  : const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          selectedProvince?.name ?? 'Chọn $label',
          style: TextStyle(
            fontSize: 16,
            color: selectedProvince != null ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  void _showProvinceDialog(Function(ListProvince) onSelect) {
    if (_isLoadingProvinces) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang tải danh sách tỉnh thành...'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredProvinces =
                _provinces.where((p) {
                  final normalizedName = removeDiacritics(p.name.toLowerCase());
                  final normalizedQuery = removeDiacritics(
                    searchQuery.toLowerCase(),
                  );
                  return normalizedName.contains(normalizedQuery);
                }).toList();
            return AlertDialog(
              title: const Text('Chọn tỉnh/thành phố'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredProvinces.length,
                        itemBuilder: (context, index) {
                          final province = filteredProvinces[index];
                          return ListTile(
                            leading: const Icon(
                              Icons.location_city,
                              color: Colors.orange,
                            ),
                            title: Text(province.name),
                            onTap: () {
                              onSelect(province);
                              Navigator.of(dialogContext).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPriceDistanceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Thông tin chi tiết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00424B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Khoảng cách',
                helperText: 'Khoảng cách tính theo đường chim bay',
                helperStyle: TextStyle(color: Colors.blue[700], fontSize: 12),
                prefixIcon: const Icon(Icons.straighten),
                suffixText: 'km',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              child: Text(
                distance != null ? distance.toString() : '',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.toggle_on, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Trạng thái tuyến đường',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00424B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatusOption(
                    status: BusRouteStatus.active,
                    icon: Icons.check_circle,
                    color: Colors.green,
                    label: 'Hoạt động',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusOption(
                    status: BusRouteStatus.inactive,
                    icon: Icons.cancel,
                    color: Colors.red,
                    label: 'Ngưng',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption({
    required BusRouteStatus status,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    final isSelected = _selectedStatus == status;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(int companyId, BusRouteState routeState) {
    final isLoading = routeState is BusRouteLoading;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed:
                isLoading
                    ? null
                    : () {
                      _resetForm();
                    },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text('Hủy', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _submitForm(companyId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'Thêm tuyến đường',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Đang thêm tuyến đường...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateDistance() {
    if (_selectedDeparture != null && _selectedDestination != null) {
      final calculatedDistance = DistanceCalculator.calculateDistance(
        _selectedDeparture!.lat,
        _selectedDeparture!.lon,
        _selectedDestination!.lat,
        _selectedDestination!.lon,
      );

      setState(() {
        distance = calculatedDistance.round();
        _distanceController.text = distance.toString();
      });
    }
  }

  void _swapLocations() {
    setState(() {
      final temp = _selectedDeparture;
      _selectedDeparture = _selectedDestination;
      _selectedDestination = temp;
    });
    _updateDistance();
  }

  void _resetForm() {
    _distanceController.clear();
    setState(() {
      _selectedDeparture = null;
      _selectedDestination = null;
      _selectedStatus = BusRouteStatus.active;
      distance = null;
    });
  }

  Future<bool> _checkValidation(int companyId) async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    if (_selectedDeparture == null || _selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn điểm đi và điểm đến'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_selectedDeparture == _selectedDestination) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Điểm đi và điểm đến không được giống nhau'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final departureName = _selectedDeparture!.name.trim();
    final destinationName = _selectedDestination!.name.trim();
    final isDuplicateRoute = await context
        .read<BusRouteCubit>()
        .checkDuplicateRouteName(departureName, destinationName, companyId);
    if (isDuplicateRoute) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Tuyến đường đã tồn tại. Vui lòng kiểm tra lại.'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  void _submitForm(int companyId) async {
    final isValid = await _checkValidation(companyId);
    if (!isValid) return;
    final route = MRoute(
      companyId: companyId,
      departure: _selectedDeparture!.name,
      destination: _selectedDestination!.name,
      distance: distance!,
      status: _selectedStatus,
    );
    if (!mounted) return;
    context.read<BusRouteCubit>().createRoute(route);
  }
}
