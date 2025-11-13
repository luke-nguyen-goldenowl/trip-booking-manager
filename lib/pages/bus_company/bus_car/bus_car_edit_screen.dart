import 'package:bus_ticket_app/utils/ui/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:bus_ticket_app/models/bus_model.dart';
import 'package:go_router/go_router.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_cubit.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_state.dart';
import 'package:bus_ticket_app/core/user/cubit/user_cubit.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/utils/helper/bus_helper.dart';
import 'package:bus_ticket_app/utils/helper/dialog_helper.dart';

class BusCarEditScreen extends StatefulWidget {
  final MBus bus;

  const BusCarEditScreen({super.key, required this.bus});

  @override
  State<BusCarEditScreen> createState() => _BusCarEditScreenState();
}

class _BusCarEditScreenState extends State<BusCarEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _licensePlateController;

  late BusType _selectedBusType;
  late BusStatus _selectedStatus;
  late int _selectedSeatCount;

  final Map<BusType, List<int>> _seatCountByType = {
    BusType.sleeper: [40, 34, 24, 22],
    BusType.seater: [45, 29, 16],
    BusType.limousine: [16],
  };

  @override
  void initState() {
    super.initState();
    _licensePlateController = TextEditingController(text: widget.bus.busNumber);
    _selectedBusType = widget.bus.type;
    _selectedStatus = widget.bus.status;
    _selectedSeatCount = widget.bus.seatCount ?? 16;
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    super.dispose();
  }

  List<int> _getAvailableSeatCounts() {
    return _seatCountByType[_selectedBusType] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chỉnh Sửa Xe',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            final confirmed = await DialogHelper.showConfirmation(
              context,
              title: 'Huỷ thay đổi',
              message:
                  'Bạn có chắc muốn huỷ thay đổi và quay lại trang trước không?',
              icon: Icons.cancel,
              iconColor: Colors.red,
              confirmColor: Colors.red,
            );
            if (confirmed && mounted) {
              context.pop();
            }
          },
        ),
        backgroundColor: Colors.orange[300],
      ),
      body: BlocConsumer<BusCubit, BusState>(
        listener: _handleBusStateChanges,
        builder: (context, busState) => _buildBody(busState),
      ),
    );
  }

  void _handleBusStateChanges(BuildContext context, BusState state) {
    if (state is BusLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Cập nhật xe thành công!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.pop();
      });
    }

    if (state is BusError) {
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

  Widget _buildBody(BusState busState) {
    return Stack(
      children: [
        BlocBuilder<UserCubit, UserState>(
          builder: (context, userState) {
            if (userState is UserLoading) {
              return buildSkeletonLoading();
            }

            if (userState is! UserLoaded) {
              return _buildErrorState();
            }

            return _buildForm(userState.user, busState);
          },
        ),
        if (busState is BusLoading) _buildLoadingOverlay(),
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
            'Không thể lấy thông tin người dùng',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(user, BusState busState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBusInfoCard(),
            const SizedBox(height: 24),
            _buildActionButtons(user.id, busState),
          ],
        ),
      ),
    );
  }

  Widget _buildBusInfoCard() {
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
                const Icon(
                  Icons.directions_bus,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Thông Tin Xe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLicensePlateField(),
            const SizedBox(height: 16),
            _buildBusTypeDropdown(),
            const SizedBox(height: 16),
            _buildSeatCountDropdown(),
            const SizedBox(height: 16),
            _buildSeatCountInfo(),
            const SizedBox(height: 16),
            _buildStatusDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildLicensePlateField() {
    return TextFormField(
      controller: _licensePlateController,
      decoration: InputDecoration(
        labelText: 'Biển số xe *',
        prefixIcon: const Icon(Icons.confirmation_number, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      textCapitalization: TextCapitalization.characters,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập biển số xe';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _licensePlateController.value = TextEditingValue(
            text: value.toUpperCase(),
            selection: _licensePlateController.selection,
          );
        });
      },
    );
  }

  Widget _buildBusTypeDropdown() {
    return DropdownButtonFormField<BusType>(
      value: _selectedBusType,
      decoration: InputDecoration(
        labelText: 'Loại xe *',
        prefixIcon: const Icon(Icons.directions_bus, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
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
                  Text(BusHelper.getBusTypeName(type)),
                ],
              ),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedBusType = value;
            final availableSeats = _getAvailableSeatCounts();
            if (availableSeats.isNotEmpty &&
                !availableSeats.contains(_selectedSeatCount)) {
              _selectedSeatCount = availableSeats.first;
            }
          });
        }
      },
    );
  }

  Widget _buildSeatCountDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedSeatCount,
      decoration: InputDecoration(
        labelText: 'Số chỗ ngồi *',
        prefixIcon: const Icon(Icons.event_seat, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items:
          _getAvailableSeatCounts().map((count) {
            return DropdownMenuItem(value: count, child: Text('$count chỗ'));
          }).toList(),
      onChanged: (value) {
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
    );
  }

  Widget _buildSeatCountInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              BusHelper.getSeatCountInfo(_selectedBusType),
              style: const TextStyle(fontSize: 13, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<BusStatus>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Trạng thái *',
        prefixIcon: const Icon(Icons.info, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
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
                    color: BusHelper.getStatusColor(status),
                  ),
                  const SizedBox(width: 8),
                  Text(BusHelper.getStatusName(status)),
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
    );
  }

  Widget _buildActionButtons(int companyId, BusState busState) {
    final isLoading = busState is BusLoading;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : () => _submitForm(companyId),
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text(
          'Cập Nhật Xe',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
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
                  'Đang cập nhật xe...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _checkValidation(int companyId) async {
    if (!_formKey.currentState!.validate()) return false;
    if (_licensePlateController.text != widget.bus.busNumber) {
      final busNumber = _licensePlateController.text.trim();
      final isDuplicate = await context
          .read<BusCubit>()
          .checkDuplicateLicensePlate(busNumber, companyId);
      if (isDuplicate) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Biển số xe đã tồn tại. Vui lòng kiểm tra lại.'),
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
    return true;
  }

  void _submitForm(int companyId) async {
    final isValid = await _checkValidation(companyId);
    if (!isValid) return;
    final updatedBus = MBus(
      id: widget.bus.id,
      busNumber: _licensePlateController.text.trim(),
      type: _selectedBusType,
      seatCount: _selectedSeatCount,
      status: _selectedStatus,
      companyId: companyId,
    );
    if (!mounted) return;
    context.read<BusCubit>().updateBus(widget.bus.id!, updatedBus);
  }
}
