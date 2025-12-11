import 'dart:async';
import 'package:flutter/material.dart';
import 'package:valhalla_android/services/payment_service.dart';
import 'package:valhalla_android/utils/colors.dart';
import '../news/news_page.dart';

class PaymentVerificationPage extends StatefulWidget {
  final String reference;
  final VoidCallback onSuccess;
  final Function(String) onFailure;
  final VoidCallback onTimeout;

  const PaymentVerificationPage({
    super.key,
    required this.reference,
    required this.onSuccess,
    required this.onFailure,
    required this.onTimeout,
  });

  @override
  State<PaymentVerificationPage> createState() =>
      _PaymentVerificationPageState();
}

class _PaymentVerificationPageState extends State<PaymentVerificationPage> {
  final PaymentService _service = PaymentService();
  Timer? _pollingTimer;
  Timer? _timeoutTimer;

  String _status = 'PENDING';
  String _statusText = 'Verificando pago...';
  int _elapsedSeconds = 0;
  bool _isChecking = false;
  bool _hasFinalStatus = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
    _startTimeout();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Verificar inmediatamente
    _checkStatus();

    // Luego cada 5 segundos
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _checkStatus(),
    );
  }

  void _startTimeout() {
    // Timeout después de 5 minutos (300 segundos)
    _timeoutTimer = Timer(const Duration(minutes: 5), () {
      if (!_hasFinalStatus) {
        widget.onTimeout();
      }
    });
  }

  Future<void> _checkStatus() async {
    if (_isChecking || _hasFinalStatus) return;

    setState(() => _isChecking = true);

    try {
      final response = await _service.checkPaymentStatus(widget.reference);

      if (!mounted) return; // Verificar si está montado

      if (response['success'] == true) {
        final data = response['data'];
        final newStatus =
            data['status_text']?.toString().toUpperCase() ?? 'PENDING';

        setState(() {
          _status = newStatus;
          _statusText = _getStatusText(newStatus);
          _elapsedSeconds += 5;
        });

        // Verificar estados finales
        if (_isFinalStatus(newStatus)) {
          _hasFinalStatus = true;
          _pollingTimer?.cancel();
          _timeoutTimer?.cancel();

          // Pequeña espera para mostrar el estado final
          await Future.delayed(const Duration(seconds: 2));

          if (!mounted) return; // Verificar de nuevo después del delay

          if (newStatus == 'APPROVED' || newStatus == 'COMPLETED') {
            // Primero llamar al callback de éxito
            widget.onSuccess();

            // Esperar un momento y navegar 2 pasos atrás
            await Future.delayed(const Duration(seconds: 1));

            if (!mounted) return; // Verificar una vez más antes de navegar

            // Navegar 2 pantallas hacia atrás (pop 2 veces)
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NewsPage(),
              ),
              (route) => false,
            );
          } else {
            widget.onFailure('Estado: $newStatus');
          }
        }
      }
    } catch (e) {
      // Continuar intentando en el próximo ciclo
      print('Error checking status: $e');
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  bool _isFinalStatus(String status) {
    final finalStatuses = [
      'APPROVED',
      'COMPLETED',
      'REJECTED',
      'FAILED',
      'DECLINED',
    ];
    return finalStatuses.contains(status.toUpperCase());
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Esperando confirmación del pago...';
      case 'APPROVED':
        return '¡Pago aprobado!';
      case 'COMPLETED':
        return '¡Pago completado exitosamente!';
      case 'REJECTED':
        return 'Pago rechazado';
      case 'FAILED':
        return 'Pago fallido';
      case 'DECLINED':
        return 'Pago declinado';
      default:
        return 'Verificando estado...';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
      case 'COMPLETED':
        return Colors.green;
      case 'REJECTED':
      case 'FAILED':
      case 'DECLINED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.pending_actions;
      case 'APPROVED':
      case 'COMPLETED':
        return Icons.check_circle;
      case 'REJECTED':
      case 'FAILED':
      case 'DECLINED':
        return Icons.error_outline;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verificando Pago'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (!_hasFinalStatus) {
              _pollingTimer?.cancel();
              _timeoutTimer?.cancel();
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          // Contenedor principal centrado
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Agregado para centrar horizontalmente
                children: [
                  // Animación/Icono según estado
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _status == 'PENDING'
                        ? SizedBox(
                            key: const ValueKey('loading'),
                            width: 120,
                            height: 120,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  strokeWidth: 4,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.purple,
                                  ),
                                ),
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 40,
                                  color: AppColors.purple.withOpacity(0.7),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            key: ValueKey(_status),
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: _getStatusColor(_status).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getStatusIcon(_status),
                              size: 60,
                              color: _getStatusColor(_status),
                            ),
                          ),
                  ),

                  const SizedBox(height: 32),

                  // Estado del pago
                  Text(
                    _statusText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(_status),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Referencia
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Referencia',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.reference,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tiempo transcurrido
                  Text(
                    'Tiempo: ${_elapsedSeconds ~/ 60}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),

                  const SizedBox(height: 8),

                  // Información adicional
                  Text(
                    _status == 'PENDING'
                        ? 'Por favor, completa el pago en la app de NEQUI\nEsta ventana se cerrará automáticamente'
                        : 'Redirigiendo...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),

                  const SizedBox(height: 32),

                  // Botón para verificar manualmente
                  if (_status == 'PENDING')
                    OutlinedButton(
                      onPressed: _isChecking ? null : _checkStatus,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.purple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isChecking)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.purple,
                              ),
                            )
                          else
                            const Icon(Icons.refresh, size: 18),
                          const SizedBox(width: 8),
                          const Text('Verificar ahora'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
