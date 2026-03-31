from django.contrib import admin
from .models import Product, Crop

class ProductAdmin(admin.ModelAdmin):
  list_display = ("name", "unit_of_measurement", "cost") 
  
class CropAdmin(admin.ModelAdmin):
  list_display = ("product", "produce_date", "storage_location", "quantity", "expiration_date")

# Register your models here.
admin.site.register(Product, ProductAdmin)
admin.site.register(Crop, CropAdmin)