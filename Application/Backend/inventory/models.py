from django.db import models

# Product model representing a product with its name, unit of measurement, an image link that will be used for display, and cost
class Product(models.Model):
    name = models.CharField(max_length=255, null=False)
    unit_of_measurement = models.CharField(max_length=255, null=False)
    image_link = models.URLField(null=True, blank=True)
    cost = models.DecimalField(max_digits=10, decimal_places=2, default=0)

    def __str__(self):
        return f"{self.name}"
    
# Crop model representing a batch of harvested products, with information about the production date, storage location, quantity, and expiration date
class Crop(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, null=False)
    produce_date = models.DateField()
    storage_location = models.CharField(max_length=255)
    quantity = models.DecimalField(max_digits=10, decimal_places=3)
    expiration_date = models.DateField(null=True)

    def __str__(self):
        return f"{self.product.name} - {self.produce_date}"


# Procurement model representing a batch of procured products, with information about the procurement date, storage location, quantity, limitation date, and purchase cost
class Procurement(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, null=False)
    procurement_date = models.DateField()
    storage_location = models.CharField(max_length=255)
    quantity = models.DecimalField(max_digits=10, decimal_places=3)
    expiration_date = models.DateField(null=True)
    purchase_cost = models.DecimalField(max_digits=10, decimal_places=2)
    
    def __str__(self):
        return f"{self.product.name} - {self.procurement_date}"

