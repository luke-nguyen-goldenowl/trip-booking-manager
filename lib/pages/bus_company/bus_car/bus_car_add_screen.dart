import 'package:bus_ticket_app/utils/ui/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:bus_ticket_app/models/MBus.dart';
import 'package:go_router/go_router.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_cubit.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_state.dart';
import 'package:bus_ticket_app/core/user/cubit/user_cubit.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bus_ticket_app/utils/helper/bus_helper.dart';

class BusCarAddScreen extends StatefulWidget {
  const BusCarAddScreen({super.key});

  @override
  State<BusCarAddScreen> createState() => _BusCarAddScreenState();
}

class _BusCarAddScreenState extends State<BusCarAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _licensePlateController = TextEditingController();
  BusType? _selectedBusType;
  BusStatus _selectedStatus = BusStatus.active;
  int? _selectedSeatCount;
  final Map<BusType, List<int>> _seatCountByType = {
    BusType.sleeper: [40, 34, 24, 22],
    BusType.seater: [45, 29, 16],
    BusType.limousine: [16],
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && firebaseUser.email != null) {
      context.read<UserCubit>().loadUser(firebaseUser.email!);
    }
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    super.dispose();
  }

  List<int> _getAvailableSeatCounts() {
    if (_selectedBusType == null) {
      return [];
    }
    return _seatCountByType[_selectedBusType] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm Xe Mới',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            context.pop();
          },
        ),
        backgroundColor: Colors.orange,
      ),
      body: BlocConsumer<BusCubit, BusState>(
        listener: (context, busState) {
          if (busState is BusLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Thêm xe thành công!'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }

          if (busState is BusError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 12),
                    Text("Thêm xe thất bại"),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, busState) {
          return Stack(
            children: [
              BlocBuilder<UserCubit, UserState>(
                builder: (context, userState) {
                  if (userState is UserLoading) {
                    return buildSkeletonLoading();
                  }
                  if (userState is! UserLoaded) {
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

                  final user = userState.user;

                  return Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    user.avatarUrl != null &&
                                            user.avatarUrl!.isNotEmpty
                                        ? NetworkImage(user.avatarUrl!)
                                        : const AssetImage(
                                              'assets/images/user.png',
                                            )
                                            as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName ?? 'Người dùng',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      user.email ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  user.role ?? '',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Thông tin cơ bản',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00424B),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _licensePlateController,
                                  decoration: InputDecoration(
                                    labelText: 'Biển số xe *',
                                    prefixIcon: const Icon(
                                      Icons.confirmation_number,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập biển số xe';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                DropdownButtonFormField<BusType>(
                                  value: _selectedBusType,
                                  decoration: InputDecoration(
                                    labelText: 'Loại xe *',
                                    prefixIcon: const Icon(
                                      Icons.directions_bus,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  items:
                                      BusType.values.map((type) {
                                        return DropdownMenuItem(
                                          value: type,
                                          child: Row(
                                            children: [
                                              Icon(
                                                BusHelper.getBusTypeIcon(type),
                                                size: 20,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                BusHelper.getBusTypeName(type),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedBusType = value;
                                        _selectedSeatCount = null;
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Vui lòng chọn loại xe';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                DropdownButtonFormField<int>(
                                  value: _selectedSeatCount,
                                  decoration: InputDecoration(
                                    labelText: 'Số chỗ ngồi *',
                                    prefixIcon: const Icon(Icons.event_seat),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    helperText:
                                        _selectedBusType == null
                                            ? 'Vui lòng chọn loại xe trước'
                                            : null,
                                    helperStyle: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                  items:
                                      _getAvailableSeatCounts().map((count) {
                                        return DropdownMenuItem(
                                          value: count,
                                          child: Text('$count chỗ'),
                                        );
                                      }).toList(),
                                  onChanged:
                                      _selectedBusType == null
                                          ? null
                                          : (value) {
                                            if (value != null) {
                                              setState(() {
                                                _selectedSeatCount = value;
                                              });
                                            }
                                          },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Vui lòng chọn số chỗ ngồi';
                                    }
                                    return null;
                                  },
                                  disabledHint: Text(
                                    'Chọn loại xe trước',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                if (_selectedBusType != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            BusHelper.getSeatCountInfo(
                                              _selectedBusType!,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 16),

                                DropdownButtonFormField<BusStatus>(
                                  value: _selectedStatus,
                                  decoration: InputDecoration(
                                    labelText: 'Trạng thái *',
                                    prefixIcon: const Icon(Icons.info),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  items:
                                      BusStatus.values.map((status) {
                                        return DropdownMenuItem(
                                          value: status,
                                          child: Row(
                                            children: [
                                              Icon(
                                                BusHelper.getStatusIcon(status),
                                                size: 20,
                                                color: BusHelper.getStatusColor(
                                                  status,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                BusHelper.getStatusName(status),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedStatus = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                    busState is BusLoading
                                        ? null
                                        : () {
                                          _licensePlateController.clear();
                                          setState(() {
                                            _selectedBusType = null;
                                            _selectedSeatCount = null;
                                            _selectedStatus = BusStatus.active;
                                          });
                                        },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: const BorderSide(color: Colors.grey),
                                ),
                                child: const Text(
                                  'Hủy',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    busState is BusLoading
                                        ? null
                                        : () => _submitForm(user.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child:
                                    busState is BusLoading
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : const Text(
                                          'Thêm xe',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (busState is BusLoading)
                Container(
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
                              'Đang thêm xe...',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _submitForm(int companyId) {
    if (_formKey.currentState!.validate()) {
      final bus = MBus(
        busNumber: _licensePlateController.text.trim(),
        type: _selectedBusType!,
        seatCount: _selectedSeatCount!,
        status: _selectedStatus,
        companyId: companyId,
      );
      context.read<BusCubit>().createBus(bus);
    }
  }
}
