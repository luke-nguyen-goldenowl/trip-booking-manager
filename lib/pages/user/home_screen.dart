import 'package:flutter/material.dart';
import 'package:bus_ticket_app/core/user/cubit/user_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:bus_ticket_app/models/province_model.dart';
import 'package:bus_ticket_app/core/province/province_service.dart';
import 'package:diacritic/diacritic.dart';
import 'package:bus_ticket_app/core/bus_trip/cubit/bus_trip_cubit.dart';
import 'package:bus_ticket_app/core/bus_trip/cubit/bus_trip_state.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_cubit.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_cubit.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/widgets/trip_popular_card.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _provinceService = ProvinceService();

  Province? _selectedDeparture;
  Province? _selectedDestination;
  bool _isLoadingProvinces = true;
  List<Province> _provinces = [];
  DateTime? _selectedDate;
  int _passengerCount = 0;
  List<MTrip> _popularTrips = [];
  @override
  void initState() {
    super.initState();
    _fetchPopularTrips();
    _loadProvinces();
  }

  void _fetchPopularTrips() {
    try {
      context.read<BusTripCubit>().getRandomTrips(5);
      context.read<BusCubit>().loadAllBuses();
      context.read<BusRouteCubit>().loadAllRoutes();
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await _provinceService.getProvinces();
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildSearchSection(),
              const SizedBox(height: 10),
              _buildPopularDestinationsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00424B), Color(0xFF013E46)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) {
                    String userName = '';

                    if (state is UserLoaded) {
                      userName = state.user.fullName!;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Xin chào! 👋',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chào mừng bạn đến với GOBUS!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildProvinceSelector(
              label: 'Điểm Đi',
              icon: Icons.location_on,
              selectedProvince: _selectedDeparture,
              onSelect: (province) {
                setState(() {
                  _selectedDeparture = province;
                });
              },
            ),

            const SizedBox(height: 10),

            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.swap_vert, color: Colors.orange),
                  onPressed: () {
                    setState(() {
                      final temp = _selectedDeparture;
                      _selectedDeparture = _selectedDestination;
                      _selectedDestination = temp;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            _buildProvinceSelector(
              label: 'Điểm Đến',
              icon: Icons.location_on,
              selectedProvince: _selectedDestination,
              onSelect: (province) {
                setState(() {
                  _selectedDestination = province;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDatePicker(
              label: 'Chọn ngày đi',
              icon: Icons.date_range,
              selectedDate: _selectedDate,
              onSelect: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.people, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Số hành khách',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              _passengerCount > 0 ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_passengerCount > 0) {
                                  _passengerCount--;
                                }
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color:
                                    _passengerCount > 0
                                        ? Colors.orange
                                        : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.remove,
                                color:
                                    _passengerCount > 0
                                        ? Colors.white
                                        : Colors.grey,
                                size: 18,
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 32,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '$_passengerCount',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _passengerCount++;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.3),
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 18,
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _handleSearch();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tìm chuyến xe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProvinceDialog(Function(Province) onSelect) {
    if (_isLoadingProvinces) {
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
                      autofocus: true,
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

  Widget _buildProvinceSelector({
    required String label,
    required IconData icon,
    required Province? selectedProvince,
    required Function(Province) onSelect,
  }) {
    return InkWell(
      onTap: () => _showProvinceDialog(onSelect),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: label == 'Điểm Đi' ? Colors.green : Colors.red,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon:
              selectedProvince != null
                  ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        if (label == 'Điểm Đi') {
                          _selectedDeparture = null;
                        } else {
                          _selectedDestination = null;
                        }
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

  void _showDatePicker(Function(DateTime) onSelect) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      onSelect(picked);
    }
  }

  Widget _buildDatePicker({
    required String label,
    required IconData icon,
    required DateTime? selectedDate,
    required Function(DateTime) onSelect,
  }) {
    return InkWell(
      onTap: () => _showDatePicker(onSelect),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: label == 'Điểm đi' ? Colors.green : Colors.red,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon:
              selectedDate != null
                  ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                      });
                    },
                  )
                  : const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          selectedDate != null
              ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
              : 'dd/mm/yyyy',
          style: TextStyle(
            fontSize: 16,
            color: selectedDate != null ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularDestinationsSection() {
    return BlocBuilder<BusTripCubit, BusTripState>(
      builder: (context, state) {
        if (state is BusTripLoading) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          );
        }
        if (state is BusTripLoaded) {
          _popularTrips = state.trips;
        }
        return Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tuyến đường phổ biến',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _popularTrips.length,
                  itemBuilder: (context, index) {
                    final trip = _popularTrips[index];
                    return PopularTripCard(trip: trip);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _checkValidation() async {
    if (_selectedDeparture == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn điểm đi'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn điểm đến'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_selectedDeparture!.code == _selectedDestination!.code) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Điểm đi và điểm đến không được trùng nhau'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày đi'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_passengerCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn số hành khách'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _handleSearch() async {
    final isValid = await _checkValidation();
    if (!isValid) return;
    context.push(
      '/user/trip-search',
      extra: {
        'departure': _selectedDeparture!.name,
        'destination': _selectedDestination!.name,
        'date': _selectedDate!,
        'passengers': _passengerCount,
      },
    );
  }
}
