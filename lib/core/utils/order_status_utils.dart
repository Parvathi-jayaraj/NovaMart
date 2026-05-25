import 'package:flutter/material.dart';

class OrderStatusUtils {
  static Color getColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;

      case 'confirmed':
        return Colors.blue;

      case 'shipped':
        return Colors.purple;

      case 'delivered':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  static IconData getIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;

      case 'confirmed':
        return Icons.check_circle_outline;

      case 'shipped':
        return Icons.local_shipping_outlined;

      case 'delivered':
        return Icons.task_alt;

      case 'rejected':
        return Icons.cancel_outlined;

      default:
        return Icons.help_outline;
    }
  }
}