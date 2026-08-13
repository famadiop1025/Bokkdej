import 'package:flutter/material.dart';
import '../services/wave_payment_service.dart';
import 'wave_official_icon.dart';
import 'wave_test_icon.dart';
import 'wave_simple_text_icon.dart';
import 'wave_debug_icon.dart';
import 'simple_red_box.dart';
import 'wave_new_image.dart';

class WavePaymentButton extends StatefulWidget {
  final int orderId;
  final double amount;
  final String restaurantName;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailed;
  final VoidCallback? onPaymentCancelled;

  const WavePaymentButton({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.restaurantName,
    this.onPaymentSuccess,
    this.onPaymentFailed,
    this.onPaymentCancelled,
  }) : super(key: key);

  @override
  State<WavePaymentButton> createState() => _WavePaymentButtonState();
}

class _WavePaymentButtonState extends State<WavePaymentButton> {
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _currentStatus;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bouton principal de paiement
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading || _isProcessing ? null : _handlePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4AA), // Couleur Wave
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _buildButtonContent(),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Statut du paiement
        if (_currentStatus != null || _errorMessage != null)
          _buildStatusWidget(),
        
        const SizedBox(height: 8),
        
        // Informations sur le paiement
        _buildPaymentInfo(),
      ],
    );
  }

  Widget _buildButtonContent() {
    if (_isLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Création du paiement...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }
    
    if (_isProcessing) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Vérification du paiement...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WaveNewImage(width: 24, height: 24),
        const SizedBox(width: 12),
        const Text(
          'Payer avec Wave',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildStatusWidget() {
    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    if (_currentStatus != null) {
      final icon = WavePaymentService.getStatusIcon(_currentStatus!);
      final message = WavePaymentService.getStatusMessage(_currentStatus!);
      final color = _getStatusColor(_currentStatus!);
      
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Montant:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                WavePaymentService.formatAmount(widget.amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Restaurant:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Expanded(
                child: Text(
                  widget.restaurantName,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentStatus = null;
    });

    try {
      // Créer le paiement Wave
      final paymentResult = await WavePaymentService.createWavePayment(widget.orderId);
      
      if (!paymentResult['success']) {
        setState(() {
          _errorMessage = paymentResult['error'];
          _isLoading = false;
        });
        return;
      }

      final paymentData = paymentResult['data'];
      final paymentUrl = paymentData['payment_url'];

      setState(() {
        _isLoading = false;
        _isProcessing = true;
      });

      // Ouvrir l'URL de paiement
      final urlOpened = await WavePaymentService.openWavePayment(paymentUrl);
      
      if (!urlOpened) {
        setState(() {
          _errorMessage = 'Impossible d\'ouvrir l\'application Wave';
          _isProcessing = false;
        });
        return;
      }

      // Démarrer le polling pour vérifier le statut
      _startPaymentPolling();
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la création du paiement: $e';
        _isLoading = false;
      });
    }
  }

  void _startPaymentPolling() {
    WavePaymentService.pollPaymentStatus(widget.orderId).listen(
      (result) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            if (result['success']) {
              _currentStatus = result['status'];
              _errorMessage = null;
              
              // Appeler les callbacks appropriés
              switch (result['status']) {
                case 'paid':
                  widget.onPaymentSuccess?.call();
                  break;
                case 'failed':
                  widget.onPaymentFailed?.call();
                  break;
                case 'cancelled':
                  widget.onPaymentCancelled?.call();
                  break;
              }
            } else {
              _errorMessage = result['error'];
            }
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _errorMessage = 'Erreur lors de la vérification du paiement: $error';
          });
        }
      },
    );
  }
}
