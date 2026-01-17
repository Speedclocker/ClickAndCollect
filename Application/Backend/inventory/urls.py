from django.urls import path
from rest_framework import routers

from . import views

router = routers.DefaultRouter()
router.register(r"product", views.ProductViewSet)

urlpatterns = [
    path('', views.main, name='main'),
    path('inventory/', views.inventory, name='inventory'),
    path('inventory/details/<int:id>', views.details, name='details'),
    path('testing/', views.testing, name='testing'),
]

urlpatterns += router.urls 