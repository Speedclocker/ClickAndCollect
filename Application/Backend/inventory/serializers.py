from rest_framework import serializers

from .models import Product, Crop, Procurement

class ProductSerializer(serializers.ModelSerializer):
    total_stock = serializers.FloatField(read_only=True) # This field will be added to the queryset in the viewset, it represents the total stock of a product by summing the quantity of all related crops
    
    class Meta:
        model = Product
        fields = ["id", "name", "unit_of_measurement", "image_link", "cost", "total_stock"] # total_stock is an annotated field that will be added to the queryset in the viewset, it represents the total stock of a product by summing the quantity of all related crops


class CropSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)

    class Meta:
        model = Crop
        fields = ["id", "product", "product_name", "produce_date", "storage_location", "quantity", "expiration_date"]

class ProcurementSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)

    class Meta:
        model = Procurement
        fields = ["id", "product", "product_name", "procurement_date", "storage_location", "quantity", "expiration_date", "purchase_cost"]