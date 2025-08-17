from django.test import TestCase
from django.contrib.auth.models import User
from .models import Order, UserProfile
from unittest.mock import patch

# Create your tests here.

class NotificationSignalTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='testuser', password='testpass')
        self.user_profile = self.user.userprofile
        self.user_profile.fcm_token = 'fake_token'
        self.user_profile.save()
        self.order = Order.objects.create(user=self.user, prix_total=1000, status='panier')

    @patch('api.models.FCMNotification')
    def test_notification_sent_on_status_change(self, mock_fcm):
        # Passe le statut à en_attente
        self.order.status = 'en_attente'
        self.order.save()
        # Vérifie que notify_single_device a été appelé
        self.assertTrue(mock_fcm.return_value.notify_single_device.called)
        args, kwargs = mock_fcm.return_value.notify_single_device.call_args
        self.assertEqual(kwargs['registration_id'], 'fake_token')
        self.assertIn('Commande', kwargs['message_title'])
