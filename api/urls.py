from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import *
from .views_admin import *
from .views_auth import create_client_account, client_login

router = DefaultRouter()
# ViewSets admin
router.register(r'admin/restaurants', AdminRestaurantViewSet, basename='admin-restaurant')
router.register(r'admin/menu', AdminMenuViewSet, basename='admin-menu')
router.register(r'admin/ingredients', AdminIngredientViewSet, basename='admin-ingredient')
router.register(r'admin/categories', AdminCategoryViewSet, basename='admin-category')
router.register(r'admin/personnel', AdminPersonnelViewSet, basename='admin-personnel')

# ViewSets publics
router.register(r'orders', OrderViewSet, basename='order')
router.register(r'bases', BaseViewSet, basename='base')
router.register(r'restaurants', RestaurantViewSet, basename='restaurant')
router.register(r'menu', MenuItemViewSet, basename='menu-item')
router.register(r'ingredients', IngredientViewSet, basename='ingredient')
router.register(r'users', UserViewSet, basename='user')
router.register(r'custom-dishes', CustomDishViewSet, basename='custom-dish')

urlpatterns = [
    path('', include(router.urls)),
    path('admin/restaurants/<int:pk>/upload-logo/', AdminRestaurantViewSet.as_view({'post': 'upload_logo'})),
    path('admin/menu/<int:pk>/upload-image/', AdminMenuViewSet.as_view({'post': 'upload_image'})),
    path('admin/statistics/', admin_statistics, name='admin-statistics'),
    path('auth/pin-login/', pin_login, name='pin_login'),
    path('auth/create-client/', create_client_account, name='create_client'),
    path('auth/client-login/', client_login, name='client_login'),
    
    # Endpoints pour demandes d'inscription restaurants
    path('restaurants/register/', restaurant_registration_request, name='restaurant_registration'),
    path('restaurants/register-info/', restaurant_registration_info, name='restaurant_registration_info'),
    path('restaurants/validate-wave/', validate_wave_link, name='validate_wave_link'),
    
    # Endpoints Wave
    path('wave/create-payment/', create_wave_payment, name='create_wave_payment'),
    path('wave/webhook/', wave_webhook, name='wave_webhook'),
    path('wave/payment-status/<int:order_id>/', check_payment_status, name='check_payment_status'),
] 
