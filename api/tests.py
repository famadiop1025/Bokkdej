from django.test import TestCase
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from django.urls import reverse
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


class PinLoginAuthenticationTest(TestCase):
    def test_phone_username_and_pin_password_are_valid_credentials(self):
        phone = '771234567'
        pin = '4582'

        user = User.objects.create_user(username=phone, password=pin)
        UserProfile.objects.create(user=user, phone=phone)

        authenticated_user = authenticate(username=phone, password=pin)

        self.assertIsNotNone(authenticated_user)
        self.assertEqual(authenticated_user.username, phone)

    def test_pin_login_endpoint_uses_username_and_password_not_suffix_match(self):
        phone = '771234567'
        pin = '4582'

        user = User.objects.create_user(username=phone, password=pin)
        UserProfile.objects.create(user=user, phone=phone)

        response = self.client.post(reverse('pin_login'), {'phone': phone, 'pin': pin}, format='json')

        self.assertEqual(response.status_code, 200)
        self.assertIn('access', response.data)
        self.assertEqual(response.data['user']['username'], phone)
