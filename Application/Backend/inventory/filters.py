import django_filters
from .models import Crop, Procurement

class CropFilter(django_filters.FilterSet):
    product_name = django_filters.CharFilter(
        field_name='product__name', 
        lookup_expr='iexact',
    )
    
    class Meta:
        model = Crop
        fields = ['product_name']


class ProcurementFilter(django_filters.FilterSet):
    product_name = django_filters.CharFilter(
        field_name='product__name', 
        lookup_expr='iexact',
    )
    
    class Meta:
        model = Procurement
        fields = ['product_name']