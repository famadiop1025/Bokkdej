import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/device_id_service.dart';

String getApiBaseUrl() {
  return 'http://localhost:8000';
}

class OrderTrackingPage extends StatefulWidget {
	final int orderId;
	final String token;
	final String? phone;

	const OrderTrackingPage({Key? key, required this.orderId, required this.token, this.phone}) : super(key: key);

  @override
	State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
	bool _loading = true;
	String? _error;
	Map<String, dynamic>? _suivi;
	int? _rating;
	final TextEditingController _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
		_fetchSuivi();
	}

	Future<void> _fetchSuivi() async {
		setState(() {
			_loading = true;
			_error = null;
		});
		try {
			final uri = Uri.parse('${getApiBaseUrl()}/api/orders/${widget.orderId}/suivi/').replace(queryParameters: {
				if ((widget.phone ?? '').isNotEmpty) 'phone': widget.phone!,
			});
			final resp = await http.get(uri, headers: {
				if (widget.token.isNotEmpty) 'Authorization': 'Bearer ${widget.token}',
			});
			if (resp.statusCode == 200) {
        setState(() {
					_suivi = json.decode(resp.body) as Map<String, dynamic>;
					_loading = false;
        });
      } else {
				throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() {
				_error = e.toString();
				_loading = false;
			});
		}
	}

	Color _statusColor(String status) {
		switch (status) {
			case 'en_attente':
				return Colors.orange;
			case 'en_preparation':
				return Colors.blue;
			case 'pret':
				return Colors.green;
			case 'termine':
				return Colors.grey;
			default:
				return Colors.grey;
		}
	}

	String _statusText(String status) {
		switch (status) {
			case 'en_attente':
				return 'En attente';
			case 'en_preparation':
				return 'En préparation';
			case 'pret':
				return 'Prêt';
			case 'termine':
				return 'Terminé';
			default:
				return status;
		}
	}

	Future<void> _sendFeedback() async {
		final rating = _rating;
		final comment = _commentCtrl.text.trim();
		if (rating == null && comment.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ajoutez une note ou un commentaire.')));
			return;
		}
		try {
			final uri = Uri.parse('${getApiBaseUrl()}/api/orders/${widget.orderId}/feedback/');
			final resp = await http.post(
				uri,
				headers: {
					'Content-Type': 'application/json',
					if (widget.token.isNotEmpty) 'Authorization': 'Bearer ${widget.token}',
				},
				body: json.encode({
					if (rating != null) 'rating': rating,
					if (comment.isNotEmpty) 'comment': comment,
					if ((widget.phone ?? '').isNotEmpty) 'phone': widget.phone,
					'device_id': await DeviceIdService.getOrCreate(),
				}),
			);
			if (resp.statusCode == 200 || resp.statusCode == 201) {
				_commentCtrl.clear();
				setState(() {
					_rating = null;
				});
				ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Merci pour votre retour !'), backgroundColor: Colors.green));
			} else {
				String msg = 'Erreur: ${resp.statusCode}';
				try { msg = json.decode(resp.body).toString(); } catch (_) {}
				ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
			}
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
		}
  }

  @override
  Widget build(BuildContext context) {
		if (_loading) {
			return Scaffold(
				appBar: AppBar(title: Text('Suivi commande #${widget.orderId}'), backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
				body: Center(child: CircularProgressIndicator()),
			);
		}
		if (_error != null) {
    return Scaffold(
				appBar: AppBar(title: Text('Suivi commande #${widget.orderId}'), backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
				body: Center(
                    child: Column(
						mainAxisSize: MainAxisSize.min,
                      children: [
							Icon(Icons.error, color: Colors.red),
                                  SizedBox(height: 8),
							Text(_error!),
                                    SizedBox(height: 8),
							ElevatedButton(onPressed: _fetchSuivi, child: Text('Réessayer')),
                                ],
                              ),
                            ),
			);
		}

		final order = _suivi?['order'] as Map<String, dynamic>? ?? {};
		final statusHistory = _suivi?['status_history'] as List<dynamic>? ?? [];
		final currentStatus = order['status']?.toString() ?? 'en_attente';
		final est = _suivi?['estimated_time'];

		return Scaffold(
			appBar: AppBar(title: Text('Suivi commande #${widget.orderId}'), backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C), actions: [
				IconButton(onPressed: _fetchSuivi, icon: Icon(Icons.refresh)),
			]),
			body: SingleChildScrollView(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
						Row(children: [
							Container(
								padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
								decoration: BoxDecoration(color: _statusColor(currentStatus), borderRadius: BorderRadius.circular(12)),
								child: Text(_statusText(currentStatus), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
							),
							SizedBox(width: 8),
							if (est != null) Text('Temps estimé: ${est.toString()} min'),
						]),
                                  SizedBox(height: 16),
						Text('Historique', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
						SizedBox(height: 8),
						...statusHistory.map((h) {
							final st = (h['status'] ?? '').toString();
							final ts = (h['timestamp'] ?? '').toString();
							final msg = (h['message'] ?? '').toString();
							return Container(
								margin: EdgeInsets.only(bottom: 8),
								child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
									Icon(Icons.check_circle, size: 18, color: _statusColor(st)),
									SizedBox(width: 8),
									Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
										Text(_statusText(st), style: TextStyle(fontWeight: FontWeight.bold)),
										if (msg.isNotEmpty) Text(msg),
										if (ts.isNotEmpty) Text(ts, style: TextStyle(color: Colors.grey, fontSize: 12)),
									]))
								]),
                                    );
                                  }).toList(),

						SizedBox(height: 24),
						Text('Votre avis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
						SizedBox(height: 8),
						Row(children: [
							Text('Note: '),
							DropdownButton<int>(
								value: _rating,
								items: [1,2,3,4,5].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
								onChanged: (v) => setState(() => _rating = v),
							),
						]),
						TextField(
							controller: _commentCtrl,
							maxLines: 3,
							decoration: InputDecoration(
								border: OutlineInputBorder(),
								hintText: 'Votre commentaire...'
							),
						),
						SizedBox(height: 8),
						Align(
							alignment: Alignment.centerRight,
							child: ElevatedButton(
								onPressed: _sendFeedback,
								child: Text('Envoyer le retour'),
                            ),
                          ),
                        ],
                  ),
      ),
    );
  }
}
