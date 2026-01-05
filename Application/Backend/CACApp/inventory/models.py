from django.db import models

# Create your models here.
class Product(models.Model):
    name = models.CharField(max_length=255)
    quantity = models.FloatField()
    unitOfMeasurement = models.CharField(max_length=255)
    imageLink = models.CharField(max_length=255, default='https://upload.wikimedia.org/wikipedia/commons/8/8a/Banana-Single.jpg')

    def __str__(self):
        return f"{self.name}"