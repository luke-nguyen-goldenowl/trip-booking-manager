import 'package:flutter/material.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/utils/helper/bus_helper.dart';

class BusRouteCard extends StatelessWidget {
  final MRoute route;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BusRouteCard({
    super.key,
    required this.route,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = route.status == BusRouteStatus.active;
    final Color statusColor = isActive ? Colors.green : Colors.red;
    final IconData statusIcon = isActive ? Icons.check_circle : Icons.cancel;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.directions_bus, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${route.departure} ➜ ${route.destination}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfo(
                    Icons.route,
                    'Khoảng cách',
                    '${route.distance ?? 0} km',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1.2),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          BusHelper.getRouteStatusName(route.status),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (onView != null) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: onView,
                          icon: const Icon(Icons.visibility),
                          color: Colors.blue,
                          tooltip: 'Xem',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.orange.withOpacity(0.1),
                          ),
                        ),
                      ],
                      if (onEdit != null) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit),
                          color: Colors.orange,
                          tooltip: 'Chỉnh sửa',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.orange.withOpacity(0.1),
                          ),
                        ),
                      ],
                      if (onDelete != null) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          tooltip: 'Xóa',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
