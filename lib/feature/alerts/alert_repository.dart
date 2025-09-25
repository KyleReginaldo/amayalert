import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/alerts/alert_model.dart';
import 'package:amayalert/feature/alerts/alert_provider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlertRepository extends ChangeNotifier {
  final AlertProvider _alertProvider;

  AlertRepository({AlertProvider? provider})
    : _alertProvider = provider ?? AlertProvider();

  List<Alert> _alerts = [];
  List<Alert> _activeAlerts = [];
  bool _isLoading = false;
  String? _errorMessage;
  RealtimeChannel? _alertSubscription;

  List<Alert> get alerts => _alerts;
  List<Alert> get activeAlerts => _activeAlerts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<Result<String>> createAlert({
    required CreateAlertRequest request,
  }) async {
    _setLoading(true);

    final result = await _alertProvider.createAlert(request: request);

    if (result.isSuccess) {
      // Refresh alerts after successful creation
      await loadAlerts();
      await loadActiveAlerts();
    } else {
      _errorMessage = result.error;
      notifyListeners();
    }

    _setLoading(false);
    return result;
  }

  Future<void> loadAlerts() async {
    _setLoading(true);

    final result = await _alertProvider.getAlerts();

    if (result.isSuccess) {
      _alerts = result.value;
      _errorMessage = null;
    } else {
      _errorMessage = result.error;
    }

    _setLoading(false);
  }

  Future<void> loadActiveAlerts() async {
    final result = await _alertProvider.getActiveAlerts();

    if (result.isSuccess) {
      _activeAlerts = result.value;
      _errorMessage = null;
      notifyListeners();
    } else {
      _errorMessage = result.error;
      notifyListeners();
    }
  }

  Future<Result<Alert>> getAlert(int alertId) async {
    return await _alertProvider.getAlert(alertId);
  }

  Future<Result<String>> updateAlert({
    required int alertId,
    required UpdateAlertRequest request,
  }) async {
    _setLoading(true);

    final result = await _alertProvider.updateAlert(
      alertId: alertId,
      request: request,
    );

    if (result.isSuccess) {
      // Refresh alerts after successful update
      await loadAlerts();
      await loadActiveAlerts();
    } else {
      _errorMessage = result.error;
      notifyListeners();
    }

    _setLoading(false);
    return result;
  }

  Future<Result<String>> deleteAlert(int alertId) async {
    _setLoading(true);

    final result = await _alertProvider.deleteAlert(alertId);

    if (result.isSuccess) {
      // Remove alert from local lists
      _alerts.removeWhere((alert) => alert.id == alertId);
      _activeAlerts.removeWhere((alert) => alert.id == alertId);
      _errorMessage = null;
    } else {
      _errorMessage = result.error;
    }

    _setLoading(false);
    return result;
  }

  void subscribeToRealTimeAlerts() {
    _alertSubscription = _alertProvider.subscribeToAlerts(
      onNewAlert: (alert) {
        _activeAlerts.insert(0, alert);
        _alerts.insert(0, alert);
        notifyListeners();
      },
      onAlertUpdated: (alert) {
        // Update alert in lists
        final alertIndex = _alerts.indexWhere((a) => a.id == alert.id);
        if (alertIndex != -1) {
          _alerts[alertIndex] = alert;
        }

        final activeAlertIndex = _activeAlerts.indexWhere(
          (a) => a.id == alert.id,
        );
        if (activeAlertIndex != -1) {
          _activeAlerts[activeAlertIndex] = alert;
        }

        notifyListeners();
      },
      onAlertDeleted: (alertId) {
        _alerts.removeWhere((alert) => alert.id == alertId);
        _activeAlerts.removeWhere((alert) => alert.id == alertId);
        notifyListeners();
      },
    );
  }

  void unsubscribeFromRealTimeAlerts() {
    _alertSubscription?.unsubscribe();
    _alertSubscription = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    unsubscribeFromRealTimeAlerts();
    super.dispose();
  }
}
