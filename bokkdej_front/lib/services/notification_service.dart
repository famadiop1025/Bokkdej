import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> showOrderStatusNotification({
    required int orderId,
    required String status,
    required String message,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'order_status',
      'Statut des commandes',
      channelDescription: 'Notifications pour les changements de statut de commande',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF5A3C1A),
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      orderId,
      'Commande #$orderId',
      message,
      details,
    );
  }

  Future<void> showMenuUpdateNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'menu_update',
      'Mise à jour du menu',
      channelDescription: 'Notifications pour les mises à jour du menu',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      color: Color(0xFFE7D3A1),
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999,
      'Menu du jour',
      'Le menu du jour a été mis à jour !',
      details,
    );
  }

  Future<void> showPreparationNotification(int orderId) async {
    await showOrderStatusNotification(
      orderId: orderId,
      status: 'en_preparation',
      message: 'Votre commande est en cours de préparation 👨‍🍳',
    );
  }

  Future<void> showReadyNotification(int orderId) async {
    await showOrderStatusNotification(
      orderId: orderId,
      status: 'pret',
      message: 'Votre commande est prête ! 🎉',
    );
  }

  Future<void> showCompletedNotification(int orderId) async {
    await showOrderStatusNotification(
      orderId: orderId,
      status: 'termine',
      message: 'Votre commande a été livrée. Bon appétit ! 🍽️',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
} 
