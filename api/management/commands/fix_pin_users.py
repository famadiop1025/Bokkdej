from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from api.models import UserProfile

class Command(BaseCommand):
    help = 'Diagnostiquer et corriger les utilisateurs pour la connexion PIN'

    def handle(self, *args, **options):
        self.stdout.write("🔍 Diagnostic des utilisateurs pour connexion PIN...\n")
        
        # 1. Vérifier tous les utilisateurs existants
        self.stdout.write("=== UTILISATEURS EXISTANTS ===")
        users = User.objects.all()
        if not users:
            self.stdout.write(self.style.ERROR("❌ Aucun utilisateur trouvé!"))
            return
        
        for user in users:
            self.stdout.write(f"\n👤 User: {user.username}")
            self.stdout.write(f"   - Actif: {user.is_active}")
            self.stdout.write(f"   - Superuser: {user.is_superuser}")
            
            try:
                profile = user.userprofile
                self.stdout.write(f"   - Rôle: {profile.role}")
                self.stdout.write(f"   - Téléphone: {profile.phone}")
                if profile.phone:
                    pin = profile.phone[-4:] if len(profile.phone) >= 4 else "TROP COURT"
                    self.stdout.write(f"   - PIN calculé: {pin}")
                else:
                    self.stdout.write(self.style.WARNING("   - ⚠️  PAS DE TÉLÉPHONE!"))
            except UserProfile.DoesNotExist:
                self.stdout.write(self.style.ERROR("   - ❌ PAS DE PROFIL!"))
        
        self.stdout.write("\n" + "="*50)
        
        # 2. Créer/corriger les utilisateurs de test
        self.stdout.write("\n🔧 Création/correction des utilisateurs de test...")
        
        # Admin user
        try:
            admin_user = User.objects.get(username='admin')
            self.stdout.write(self.style.SUCCESS("✅ Utilisateur admin existe"))
        except User.DoesNotExist:
            admin_user = User.objects.create_user(
                username='admin',
                password='admin123',
                is_staff=True,
                is_superuser=True
            )
            self.stdout.write(self.style.SUCCESS("✅ Utilisateur admin créé"))
        
        # Profil admin
        try:
            admin_profile = UserProfile.objects.get(user=admin_user)
            self.stdout.write(self.style.SUCCESS("✅ Profil admin existe"))
        except UserProfile.DoesNotExist:
            admin_profile = UserProfile.objects.create(user=admin_user, role='admin')
            self.stdout.write(self.style.SUCCESS("✅ Profil admin créé"))
        
        # Mettre à jour le téléphone admin
        admin_profile.phone = '33123456781234'  # PIN: 1234
        admin_profile.role = 'admin'
        admin_profile.save()
        self.stdout.write(self.style.SUCCESS(f"✅ Admin - Téléphone: {admin_profile.phone}, PIN: {admin_profile.phone[-4:]}"))
        
        # Staff user
        try:
            staff_user = User.objects.get(username='staff')
            self.stdout.write(self.style.SUCCESS("✅ Utilisateur staff existe"))
        except User.DoesNotExist:
            staff_user = User.objects.create_user(
                username='staff',
                password='staff123',
                is_staff=True,
            )
            self.stdout.write(self.style.SUCCESS("✅ Utilisateur staff créé"))
        
        # Profil staff
        try:
            staff_profile = UserProfile.objects.get(user=staff_user)
            self.stdout.write(self.style.SUCCESS("✅ Profil staff existe"))
        except UserProfile.DoesNotExist:
            staff_profile = UserProfile.objects.create(user=staff_user, role='admin')
            self.stdout.write(self.style.SUCCESS("✅ Profil staff créé"))
        
        # Mettre à jour le téléphone staff
        staff_profile.phone = '33123456785678'  # PIN: 5678
        staff_profile.role = 'admin'  # Changé en admin pour tester
        staff_profile.save()
        self.stdout.write(self.style.SUCCESS(f"✅ Staff - Téléphone: {staff_profile.phone}, PIN: {staff_profile.phone[-4:]}"))
        
        # 3. Vérification finale
        self.stdout.write("\n📋 VÉRIFICATION FINALE...")
        self.stdout.write("=== UTILISATEURS POUR CONNEXION PIN ===")
        
        staff_profiles = UserProfile.objects.filter(role__in=['admin', 'personnel', 'chef'])
        for profile in staff_profiles:
            if profile.phone:
                pin = profile.phone[-4:]
                self.stdout.write(self.style.SUCCESS(f"✅ {profile.user.username}: PIN {pin} (rôle: {profile.role})"))
            else:
                self.stdout.write(self.style.ERROR(f"❌ {profile.user.username}: PAS DE TÉLÉPHONE (rôle: {profile.role})"))
        
        self.stdout.write("\n🎯 PINS DE TEST:")
        self.stdout.write("   - Admin: 1234")
        self.stdout.write("   - Staff: 5678")
        self.stdout.write(self.style.SUCCESS("\n✅ Configuration terminée!"))