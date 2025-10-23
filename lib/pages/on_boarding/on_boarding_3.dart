import 'package:flutter/material.dart';

class OnBoarding3Page extends StatelessWidget {
  const OnBoarding3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Dễ dàng theo dõi vị trí hiện tại và trạng thái chuyến đi của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không cần lo lắng về việc bỏ lỡ xe buýt của bạn. Ứng dụng của chúng tôi cung cấp các tính năng theo dõi trực tiếp.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Live Tracking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      _buildTrackingPoint(
                        'Lagos Terminal',
                        'Departure: 8:00 AM',
                        Icons.radio_button_checked,
                        Colors.green,
                        true,
                      ),
                      _buildTrackingLine(Colors.green),
                      _buildTrackingPoint(
                        'Ibadan Junction',
                        'ETA: 10:30 AM',
                        Icons.radio_button_checked,
                        Colors.orange,
                        true,
                      ),
                      _buildTrackingLine(Colors.orange),
                      _buildTrackingPoint(
                        'Oyo State',
                        'ETA: 12:00 PM',
                        Icons.radio_button_unchecked,
                        Colors.grey,
                        false,
                      ),
                      _buildTrackingLine(Colors.grey.shade300),
                      _buildTrackingPoint(
                        'Abuja Terminal',
                        'Arrival: 2:00 PM',
                        Icons.radio_button_unchecked,
                        Colors.grey,
                        false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bus is currently 5 minutes ahead of schedule',
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingPoint(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isActive,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingLine(Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
      width: 2,
      height: 20,
      color: color,
    );
  }
}
