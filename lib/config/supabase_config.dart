import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/network_utils.dart';

/// Supabase configuration class with enhanced error handling and debugging
class SupabaseConfig {
  // Supabase URL and anon key
  static const String supabaseUrl = 'https://auzxvvgsznrjnutovalr.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1enh2dmdzem5yam51dG92YWxyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgxNzc2NTQsImV4cCI6MjA2Mzc1MzY1NH0._bvMRDVgioG2BnyiHeaLvrlqyXMik_-QiRHjU31JnLg';

  // Singleton instance
  static final SupabaseConfig _instance = SupabaseConfig._internal();

  // Factory constructor to return the same instance
  factory SupabaseConfig() => _instance;

  // Private constructor
  SupabaseConfig._internal();

  // Flag to track initialization status
  static bool _isInitialized = false;

  // Getter for initialization status
  static bool get isInitialized => _isInitialized;

  // Getter for Supabase client
  static SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError(
          'Supabase client not initialized. Call initialize() first.');
    }
    return Supabase.instance.client;
  }

  /// Initialize Supabase with timeout and network checks
  static Future<void> initialize({
    Duration timeout = const Duration(seconds: 15),
    int maxRetries = 3,
  }) async {
    if (_isInitialized) {
      debugPrint('Supabase already initialized');
      return;
    }

    try {
      // Check if Supabase is already initialized globally
      try {
        Supabase.instance.client;
        _isInitialized = true;
        debugPrint('Using existing Supabase instance');
        return;
      } catch (e) {
        // Supabase is not initialized yet, continue with initialization
        debugPrint('No existing Supabase instance found, initializing...');
      }

      // Check network connectivity first
      final networkUtils = NetworkUtils();
      final hasInternet = await networkUtils.hasInternetConnection();

      if (!hasInternet) {
        throw Exception(networkUtils.getUserFriendlyErrorMessage(
            SocketException('Network is unreachable')));
      }

      // Check if Supabase host is reachable
      final isSupabaseReachable = await networkUtils
          .isHostReachable('auzxvvgsznrjnutovalr.supabase.co');

      if (!isSupabaseReachable) {
        throw Exception(networkUtils.getUserFriendlyErrorMessage(
            SocketException('Failed host lookup')));
      }

      // Initialize Supabase with retry mechanism
      Exception? lastError;
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          debugPrint('Attempt $attempt to initialize Supabase...');

          // Initialize Supabase with timeout
          await Supabase.initialize(
            url: supabaseUrl,
            anonKey: supabaseAnonKey,
            debug: kDebugMode,
          ).timeout(timeout, onTimeout: () {
            throw TimeoutException(
                'Supabase initialization timed out after ${timeout.inSeconds} seconds');
          });

          _isInitialized = true;
          debugPrint('Supabase initialized successfully on attempt $attempt');
          return;
        } catch (e) {
          lastError = e as Exception;
          debugPrint('Error initializing Supabase on attempt $attempt: $e');

          // If this is a network-related error, provide more specific guidance
          if (networkUtils.isNetworkError(e)) {
            debugPrint('Network error detected. Checking network status...');

            // Check if we have general internet connectivity
            final hasGeneralInternet =
                await networkUtils.hasInternetConnection();
            if (!hasGeneralInternet) {
              throw Exception(networkUtils.getUserFriendlyErrorMessage(e));
            } else {
              // We have internet but can't reach Supabase specifically
              debugPrint('Internet is available but cannot reach Supabase.');

              // If this is the last attempt, throw a more helpful error
              if (attempt == maxRetries) {
                throw Exception(
                    'Unable to connect to the application server. This may be due to network restrictions or server issues. '
                    'Please try again later or contact support if the problem persists.');
              }
            }
          }

          // Wait before retrying, with exponential backoff
          if (attempt < maxRetries) {
            final waitTime = Duration(milliseconds: 500 * attempt);
            debugPrint('Waiting ${waitTime.inMilliseconds}ms before retry...');
            await Future.delayed(waitTime);
          }
        }
      }

      // If we get here, all attempts failed
      throw lastError ??
          Exception(
              'Failed to initialize the application after $maxRetries attempts. Please try again later.');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
      rethrow;
    }
  }

  /// Check if the Supabase connection is healthy
  static Future<bool> checkConnection() async {
    if (!_isInitialized) {
      debugPrint('Supabase not initialized for connection check');
      return false;
    }

    try {
      // Try a simple query to check connection
      await client.from('users').select('id').limit(1);
      debugPrint('Supabase connection check successful');
      return true;
    } catch (e) {
      debugPrint('Supabase connection check failed: $e');
      return false;
    }
  }

  /// Reset the initialization state
  static void reset() {
    _isInitialized = false;
    debugPrint('Supabase initialization state reset');
  }
}
