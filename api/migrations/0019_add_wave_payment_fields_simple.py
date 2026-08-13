# Generated manually to add Wave payment fields

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0018_add_updated_at_to_order_simple'),
    ]

    operations = [
        # Ajouter les champs Wave au modèle Restaurant
        migrations.AddField(
            model_name='restaurant',
            name='wave_payment_link',
            field=models.URLField(blank=True, null=True, help_text='Lien de paiement Wave du restaurant'),
        ),
        migrations.AddField(
            model_name='restaurant',
            name='wave_merchant_id',
            field=models.CharField(blank=True, null=True, max_length=100, help_text='ID marchand Wave (si API disponible)'),
        ),
        migrations.AddField(
            model_name='restaurant',
            name='wave_api_key',
            field=models.CharField(blank=True, null=True, max_length=200, help_text='Clé API Wave (si API disponible)'),
        ),
        migrations.AddField(
            model_name='restaurant',
            name='wave_webhook_secret',
            field=models.CharField(blank=True, null=True, max_length=200, help_text='Secret pour valider les webhooks Wave'),
        ),
        
        # Ajouter les champs de paiement au modèle Order
        migrations.AddField(
            model_name='order',
            name='payment_status',
            field=models.CharField(
                choices=[
                    ('pending', 'En attente de paiement'),
                    ('paid', 'Payé'),
                    ('failed', 'Échec du paiement'),
                    ('cancelled', 'Paiement annulé'),
                    ('refunded', 'Remboursé'),
                ],
                default='pending',
                max_length=20,
                help_text='Statut du paiement'
            ),
        ),
        migrations.AddField(
            model_name='order',
            name='wave_payment_url',
            field=models.URLField(blank=True, null=True, help_text='URL de paiement Wave générée'),
        ),
        migrations.AddField(
            model_name='order',
            name='wave_transaction_id',
            field=models.CharField(blank=True, null=True, max_length=100, help_text='ID de transaction Wave'),
        ),
        migrations.AddField(
            model_name='order',
            name='wave_payment_reference',
            field=models.CharField(blank=True, null=True, max_length=100, help_text='Référence de paiement Wave'),
        ),
        migrations.AddField(
            model_name='order',
            name='payment_date',
            field=models.DateTimeField(blank=True, null=True, help_text='Date et heure du paiement'),
        ),
        migrations.AddField(
            model_name='order',
            name='payment_method',
            field=models.CharField(default='wave', max_length=50, help_text='Méthode de paiement utilisée'),
        ),
        
        # Créer le modèle WavePaymentLog
        migrations.CreateModel(
            name='WavePaymentLog',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('event_type', models.CharField(help_text="Type d'événement: payment_initiated, payment_success, payment_failed, webhook_received", max_length=50)),
                ('wave_transaction_id', models.CharField(blank=True, max_length=100, null=True)),
                ('wave_reference', models.CharField(blank=True, max_length=100, null=True)),
                ('amount', models.DecimalField(blank=True, decimal_places=2, max_digits=10, null=True)),
                ('status', models.CharField(blank=True, max_length=50, null=True)),
                ('raw_data', models.JSONField(default=dict, help_text='Données brutes reçues de Wave')),
                ('error_message', models.TextField(blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('order', models.ForeignKey(on_delete=models.deletion.CASCADE, related_name='wave_logs', to='api.order')),
            ],
            options={
                'ordering': ['-created_at'],
            },
        ),
    ]
