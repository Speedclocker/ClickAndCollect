from django.http import HttpResponse
from django.template import loader
from rest_framework import permissions, viewsets
from rest_framework.permissions import AllowAny

from .serializers import ProductSerializer
from .models import Product

class ProductViewSet(viewsets.ModelViewSet):
    """
    API endpoint for adding and editing products of the inventory
    """
    queryset = Product.objects.all().order_by("id")
    serializer_class = ProductSerializer
    permission_classes = [AllowAny]

def inventory(request):
    all_products = Product.objects.all().values()
    template = loader.get_template("all_products.html")
    context = {
        'all_products': all_products,
    }
    return HttpResponse(template.render(context, request))

def details(request, id):
    product = Product.objects.get(id=id)
    template = loader.get_template("details.html")
    context = {
        'product': product,
    }
    return HttpResponse(template.render(context, request))

def main(request):
    template = loader.get_template("main.html")
    return HttpResponse(template.render())

def testing(request):
    template = loader.get_template("testing.html")
    context = {
        'fruits': ['Apple', 'Banana', 'Cherry'],
    }
    return HttpResponse(template.render(context, request))