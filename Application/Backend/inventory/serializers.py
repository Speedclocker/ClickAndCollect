from django.contrib.auth.models import Group, User
from rest_framework import serializers

from .models import Product

class ProductSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Product
        fields = ["name", "quantity", "unitOfMeasurement", "imageLink"]