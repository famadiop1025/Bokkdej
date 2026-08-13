# Generated manually to fix the updated_at field issue

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0017_restore_original_state'),
    ]

    operations = [
        migrations.AddField(
            model_name='order',
            name='updated_at',
            field=models.DateTimeField(auto_now=True),
        ),
    ]
