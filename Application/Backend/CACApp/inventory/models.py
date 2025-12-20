from django.db import models

# Create your models here.
class Product(models.Model):
    name = models.CharField(max_length=255)
    quantity = models.IntegerField()
    unitOfMeasurement = models.CharField(max_length=255)