import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Utility class for network-related operations
class NetworkUtils {
  /// Check if the device has an internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      return false;
    } catch (e) {
      debugPrint('Error checking internet connection: $e');
      return false;
    }
  }

  /// Check if a specific host is reachable
  Future<bool> isHostReachable(String host) async {
    try {
      final result = await InternetAddress.lookup(host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (e) {
      debugPrint('Host $host is not reachable: $e');
      return false;
    } catch (e) {
      debugPrint('Error checking host reachability: $e');
      return false;
    }
  }

  /// Get a user-friendly error message for network-related errors
  String getUserFriendlyErrorMessage(dynamic error) {
    if (error is SocketException) {
      if (error.message.contains('Failed host lookup')) {
        return 'Unable to connect to the server. Please check your internet connection and try again.';
      } else if (error.message.contains('Connection refused')) {
        return 'The server is currently unavailable. Please try again later.';
      } else if (error.message.contains('Network is unreachable')) {
        return 'No internet connection available. Please check your network settings.';
      } else if (error.message.contains('Connection timed out')) {
        return 'Connection timed out. Please check your internet speed and try again.';
      }
    } else if (error is TimeoutException) {
      return 'The request took too long to complete. Please check your internet connection and try again.';
    } else if (error is HttpException) {
      return 'Unable to connect to the server. Please try again later.';
    }

    return 'An unexpected network error occurred. Please try again.';
  }

  /// Check if the error is network-related
  bool isNetworkError(dynamic error) {
    return error is SocketException ||
        error is TimeoutException ||
        error is HttpException;
  }
}
