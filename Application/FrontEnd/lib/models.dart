
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'config.dart';


Future<List<dynamic>> fetchProducts() async {
  final response = await http.get(
    Uri.parse('$bddUrl/products/')
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    // TODO : Afficher une page d'erreur plus détaillée, avec un bouton de retry
    throw Exception('Erreur API');
  }
}

// Modèle de données pour un produit, avec les informations clés (prix, quantité nette, valorisation nette, etc.) et une liste de récoltes détaillées
class Product {
  final String imageLink, name, unitOfMeasurement;
  final double quantityAvailable, cost;

  const Product({
    required this.imageLink,
    required this.name,
    required this.quantityAvailable,
    required this.unitOfMeasurement,
    required this.cost
  });
}



Future<List<dynamic>> fetchCrops(String productName) async {
  final response = await http.get(
    Uri.parse('$bddUrl/crops/?product_name=$productName')
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    // TODO : Afficher une page d'erreur plus détaillée, avec un bouton de retry
    throw Exception('Erreur API');
  }
}

// Modèle de données pour une récolte, avec les informations clés (date de récolte, date limite de conservation, quantité nette, valorisation, etc.)
class Crop {
  final DateTime produceDate, expirationDate;
  final String productName, storageLocation;
  final double quantity, valorization;

  const Crop({
    required this.produceDate,
    required this.expirationDate,
    required this.productName,
    required this.storageLocation,
    required this.quantity,
    required this.valorization
  });
}