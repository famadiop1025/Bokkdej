from rest_framework import routers
from django.urls import path
from .views import (
    MenuItemViewSet, IngredientViewSet, CustomDishViewSet, OrderViewSet, 
    UserViewSet, register, CustomTokenObtainPairView, RestaurantViewSet, 
    BaseViewSet, pin_login, upload_image, user_profile
)
from .views_admin import (
    AdminMenuViewSet, AdminIngredientViewSet, AdminPersonnelViewSet,
    AdminCategoryViewSet, AdminRestaurantViewSet, admin_statistics, 
    admin_settings, admin_reports, admin_dashboard_data
)

# Router principal pour les endpoints publics/clients
router = routers.DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'menu', MenuItemViewSet)
router.register(r'ingredients', IngredientViewSet)
router.register(r'bases', BaseViewSet)
router.register(r'custom-dishes', CustomDishViewSet)
router.register(r'orders', OrderViewSet)
router.register(r'restaurants', RestaurantViewSet)

# Router pour les endpoints administrateur
admin_router = routers.DefaultRouter()
admin_router.register(r'menu', AdminMenuViewSet, basename='admin-menu')
admin_router.register(r'ingredients', AdminIngredientViewSet, basename='admin-ingredients')
admin_router.register(r'personnel', AdminPersonnelViewSet, basename='admin-personnel')
admin_router.register(r'categories', AdminCategoryViewSet, basename='admin-categories')
admin_router.register(r'restaurants', AdminRestaurantViewSet, basename='admin-restaurants')

# URLs principales
urlpatterns = [
    # Endpoints publics
    path('register/', register, name='register'),
    path('token/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/pin-login/', pin_login, name='pin_login'),
    path('user/profile/', user_profile, name='user_profile'),
    path('upload-image/', upload_image, name='upload_image'),
    
    # Endpoints administrateur
    path('admin/dashboard/', admin_dashboard_data, name='admin-dashboard'),
    path('admin/statistics/', admin_statistics, name='admin-statistics'),
    path('admin/settings/', admin_settings, name='admin-settings'),
    path('admin/reports/', admin_reports, name='admin-reports'),
]

# Ajouter les URLs du router principal
urlpatterns += router.urls

# Ajouter les URLs admin avec préfixe 'admin/'
from django.urls import include
urlpatterns += [
    path('admin/', include(admin_router.urls)),
] 
