# Generated manually for restaurant registration fields

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0019_add_wave_payment_fields_simple'),
    ]

    operations = [
        migrations.AddField(
            model_name='restaurant',
            name='capacite',
            field=models.PositiveIntegerField(default=0, help_text="Capacité d'accueil du restaurant"),
        ),
        migrations.AddField(
            model_name='restaurant',
            name='documents_legaux',
            field=models.BooleanField(default=False, help_text='Documents légaux fournis'),
        ),
        migrations.AddField(
            model_name='restaurant',
            name='horaires',
            field=models.TextField(blank=True, help_text="Horaires d'ouverture", null=True),
        ),
        migrations.AddField(
            model_name='restaurant',
            name='nom_gerant',
            field=models.CharField(blank=True, help_text='Nom du gérant responsable', max_length=100, null=True),
        ),
        migrations.AddField(
            model_name='restaurant',
            name='telephone_gerant',
            field=models.CharField(blank=True, help_text='Téléphone du gérant', max_length=20, null=True),
        ),
        migrations.AddField(
            model_name='restaurant',
            name='type_cuisine',
            field=models.CharField(blank=True, help_text='Type de cuisine (sénégalaise, française, etc.)', max_length=100, null=True),
        ),
    ]
