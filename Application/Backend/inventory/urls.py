from django.urls import path
from rest_framework import routers

from . import views

router = routers.DefaultRouter()
router.register(r"products", views.ProductViewSet)
router.register(r"crops", views.CropViewSet)
router.register(r"procurements", views.ProcurementViewSet)

urlpatterns = []
urlpatterns += router.urls 