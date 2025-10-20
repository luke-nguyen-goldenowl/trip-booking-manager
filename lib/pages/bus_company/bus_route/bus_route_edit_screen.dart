import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_cubit.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_state.dart';
import 'package:bus_ticket_app/core/user/cubit/user_cubit.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:bus_ticket_app/core/province/province_service.dart';
import 'package:bus_ticket_app/models/MRoute.dart';
import 'package:bus_ticket_app/models/MProvince.dart';

class BusRouteEditScreen extends StatefulWidget {
  final MRoute route;

  const BusRouteEditScreen({super.key, required this.route});

  @override
  State<BusRouteEditScreen> createState() => _BusRouteEditScreenState();
}

class _BusRouteEditScreenState extends State<BusRouteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _distanceController = TextEditingController();
  final _priceController = TextEditingController();
  final _provinceService = ProvinceService();

  Province? _selectedDeparture;
  Province? _selectedDestination;
  late BusRouteStatus _selectedStatus;
  List<Province> _provinces = [];
  bool _isLoadingProvinces = true;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.route.status;
    _distanceController.text = widget.route.distance?.toString() ?? '';
    _priceController.text = widget.route.price?.toString() ?? '';
    _loadProvinces();
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await _provinceService.getProvinces();
      setState(() {
        _provinces = provinces;
        _isLoadingProvinces = false;

        _selectedDeparture = provinces.firstWhere(
          (p) => p.name == widget.route.departure,
          orElse: () => provinces.first,
        );
        _selectedDestination = provinces.firstWhere(
          (p) => p.name == widget.route.destination,
          orElse: () => provinces.first,
        );
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

  void _swapLocations() {
    setState(() {
      final temp = _selectedDeparture;
      _selectedDeparture = _selectedDestination;
      _selectedDestination = temp;
    });
  }

  void _submitForm(int companyId) {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDeparture == null || _selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn điểm đi và điểm đến'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDeparture == _selectedDestination) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Điểm đi và điểm đến không được giống nhau'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedRoute = MRoute(
      id: widget.route.id,
      companyId: companyId,
      departure: _selectedDeparture!.name,
      destination: _selectedDestination!.name,
      distance: int.parse(_distanceController.text.trim()),
      price: int.parse(_priceController.text.trim()),
      status: _selectedStatus,
    );

    context.read<BusRouteCubit>().updateRoute(widget.route.id!, updatedRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chỉnh Sửa Tuyến Đường',
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
              Text('Cập nhật tuyến đường thành công!'),
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
          const Icon(Icons.error, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Không thể tải thông tin người dùng',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/home-bus-company'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
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
                const Icon(Icons.route, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Thông Tin Tuyến Đường',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLocationField(
              label: 'Điểm đi',
              value: _selectedDeparture?.name ?? 'Chọn điểm đi',
              onTap:
                  () => _showProvinceDialog(
                    title: 'Chọn điểm đi',
                    onSelect: (province) {
                      setState(() => _selectedDeparture = province);
                    },
                  ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: _swapLocations,
                  icon: const Icon(Icons.swap_vert, color: Colors.orange),
                  tooltip: 'Đổi điểm đi - điểm đến',
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildLocationField(
              label: 'Điểm đến',
              value: _selectedDestination?.name ?? 'Chọn điểm đến',
              onTap:
                  () => _showProvinceDialog(
                    title: 'Chọn điểm đến',
                    onSelect: (province) {
                      setState(() => _selectedDestination = province);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final isSelected = value != 'Chọn điểm đi' && value != 'Chọn điểm đến';

    return InkWell(
      onTap: _isLoadingProvinces ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.orange.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black87 : Colors.grey.shade400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: isSelected ? Colors.orange : Colors.grey,
            ),
          ],
        ),
      ),
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
                const Icon(Icons.local_atm, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Giá Vé & Khoảng Cách',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Khoảng cách',
                hintText: 'Nhập khoảng cách',
                prefixIcon: const Icon(
                  Icons.social_distance,
                  color: Colors.orange,
                ),
                suffixText: 'km',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập khoảng cách';
                }
                final distance = int.tryParse(value);
                if (distance == null || distance <= 0) {
                  return 'Khoảng cách phải lớn hơn 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Giá vé',
                hintText: 'Nhập giá vé',
                prefixIcon: const Icon(
                  Icons.attach_money,
                  color: Colors.orange,
                ),
                suffixText: 'đ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập giá vé';
                }
                final price = int.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Giá vé phải lớn hơn 0';
                }
                return null;
              },
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
                const Icon(Icons.toggle_on, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Trạng Thái Tuyến Đường',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...BusRouteStatus.values.map((status) {
              final isSelected = _selectedStatus == status;
              final color =
                  status == BusRouteStatus.active ? Colors.green : Colors.red;
              final icon =
                  status == BusRouteStatus.active
                      ? Icons.check_circle
                      : Icons.cancel;
              final label =
                  status == BusRouteStatus.active
                      ? 'Hoạt động'
                      : 'Ngưng hoạt động';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => _selectedStatus = status),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? color.withOpacity(0.1) : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: color, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color: isSelected ? color : Colors.black87,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check, color: color, size: 24),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(int companyId, BusRouteState routeState) {
    final isLoading = routeState is BusRouteLoading;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : () => _submitForm(companyId),
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'Cập Nhật Tuyến Đường',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'Đang cập nhật...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showProvinceDialog({
    required String title,
    required Function(Province) onSelect,
  }) async {
    final searchController = TextEditingController();
    List<Province> filteredProvinces = List.from(_provinces);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm tỉnh/thành phố...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredProvinces =
                              _provinces
                                  .where(
                                    (p) => p.name.toLowerCase().contains(
                                      value.toLowerCase(),
                                    ),
                                  )
                                  .toList();
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
                            leading: Icon(
                              Icons.location_city,
                              color: Colors.orange,
                            ),
                            title: Text(province.name),
                            onTap: () {
                              onSelect(province);
                              Navigator.pop(context);
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
