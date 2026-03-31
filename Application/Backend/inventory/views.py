from django.db.models import Sum, Value, FloatField, F
from django.db.models.functions import Coalesce

from rest_framework import viewsets
from rest_framework.permissions import AllowAny
from .serializers import ProcurementSerializer, ProductSerializer, CropSerializer
from .models import Product, Crop, Procurement


from django_filters.rest_framework import DjangoFilterBackend
from .filters import CropFilter, ProcurementFilter



class ProductViewSet(viewsets.ModelViewSet):
    """
    API endpoint for adding and editing products of the inventory
    """
    queryset = Product.objects.annotate(
        crop_stock=Coalesce(Sum('crop__quantity'), Value(0.0), output_field=FloatField()),
        procurement_stock=Coalesce(Sum('procurement__quantity'), Value(0.0), output_field=FloatField())
    ).annotate(
        total_stock=F('crop_stock') + F('procurement_stock')
    ).order_by("id") # To sum the quantity of all crops and procurement related to a product and get the total stock of that product, if there are no related crops, it will return 0.0 instead of null
    
    serializer_class = ProductSerializer
    permission_classes = [AllowAny]  
    # TODO: AllowAny is used for development purposes, it will be changed to a more restrictive permission class in production

class CropViewSet(viewsets.ModelViewSet):
    """
    API endpoint for adding and editing crops
    """
    queryset = Crop.objects.all().order_by("id")
    serializer_class = CropSerializer
    permission_classes = [AllowAny] 
    # TODO: AllowAny is used for development purposes, it will be changed to a more restrictive permission class in production
    filter_backends = [DjangoFilterBackend]
    filterset_class = CropFilter


class ProcurementViewSet(viewsets.ModelViewSet):
    """
    API endpoint for adding and editing procurements
    """
    queryset = Procurement.objects.all().order_by("id")
    serializer_class = ProcurementSerializer
    permission_classes = [AllowAny] 
    # TODO: AllowAny is used for development purposes, it will be changed to a more restrictive permission class in production
    filter_backends = [DjangoFilterBackend]
    filterset_class = ProcurementFilter
