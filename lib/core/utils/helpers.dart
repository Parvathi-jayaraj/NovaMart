// General utility/helper functions used across the app
class Helpers {
  static String formatPrice(double price) {
    return '₹${price.toStringAsFixed(2)}';
  }
}