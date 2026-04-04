
import 'package:flutter/material.dart';

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

// Page affichant la liste des produits en stock, avec les informations clés (prix, quantité nette, valorisation nette, etc.) et permettant d'accéder à la page de détails d'un produit
class GestionDesStocksPage extends StatefulWidget {
  @override
  State<GestionDesStocksPage> createState() => _GestionDesStocksPageState();
}

// State de la page de gestion des stocks, avec une requête pour récupérer la liste des produits en stock et un FutureBuilder pour afficher la liste des produits
class _GestionDesStocksPageState extends State<GestionDesStocksPage> {
  late Future<List<dynamic>> productsFuture;
  var totalValorisationString = "-- €";
  var totalProduits = "--";

  @override
  void initState() {
    super.initState();
    productsFuture = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface, 
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.inventory),
            SizedBox(width: 10),
            Text("Gestion des stocks"),
          ],
        )),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Cards d'information affichant les informations clés de la gestion des stocks (valorisation totale, nombre de produits, etc.)
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InformationCard(value: totalValorisationString, caption: "Valorisation totale", dynamicInfo: "Information dynamique",),
                InformationCard(value: totalProduits, caption: "Nombre de produits", dynamicInfo: "Information dynamique",),
              ],
            ),
          ),
          // Tableau de la liste des produits en stock, avec les informations clés (prix, quantité nette, valorisation nette, etc.) pour chaque produit et un lien vers la page de détails du produit en cliquant sur son nom
          FutureBuilder(
            future: productsFuture, 
            builder: (context, snapshot)
            {
              // Loading
              if(snapshot.connectionState == ConnectionState.waiting)
              {
                return const Center(child: CircularProgressIndicator());
              }
                  
              // In case of error
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur : ${snapshot.error}'),
                );
              }
                  
              // In case of success
              final products = snapshot.data!; // products non nullable
          
              // Compute total valorisation of the stock
              var totalValorisation = 0.0;
              for (var product in products) {
                totalValorisation = totalValorisation + double.parse(product["cost"].toString()) * double.parse(product["total_stock"].toString());
              }
          
              // Update the total valorisation and total number of products displayed in the information cards
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  totalValorisationString = "${totalValorisation.toStringAsFixed(2)} €";
                  totalProduits = products.length.toString();
                });
              });
          
              // Build the table of products
              return Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: ProductsTable(
                  products: products.map((product) => Product(
                  imageLink: product["image_link"], 
                  name: product["name"], 
                  quantityAvailable: double.parse(product["total_stock"].toString()), 
                  unitOfMeasurement: product["unit_of_measurement"], 
                  cost: double.parse(product["cost"]))).toList()
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}

// Tableau affichant la liste des produits en stock, avec les informations clés (prix, quantité nette, valorisation nette, etc.) pour chaque produit et permettant d'accéder à la page de détails d'un produit en cliquant sur son nom
class ProductsTable extends StatelessWidget {
  final List<Product> products;

  const ProductsTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 0.2),
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          children: [
            // En-tête du tableau, avec les titres des colonnes (Produit, Quantité nette, Valorisation nette, etc.)
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                      ),
                  ),
                  Expanded(flex: 1, child: Text("Produit", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)))),
                  Expanded(flex: 1, child: Text("Quantité nette", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)))),
                  Expanded(flex: 1, child: Text("Valorisation nette", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)))),
                ],
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.onSurface, thickness: 0.2, height: 0.0),
            // Liste des produits, avec une ligne par produit, les informations clés (prix, quantité nette, valorisation nette, etc.) pour chaque produit et un lien vers la page de détails du produit en cliquant sur son nom
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: products.map((product) => ProductRow(product: product)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Ligne d'un produit dans le tableau de la page de gestion des stocks, avec les informations clés (prix, quantité nette, valorisation nette, etc.) et une navigation vers la page de détails du produit en cliquant sur son nom
class ProductRow extends StatelessWidget {
  final Product product;

  const ProductRow({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        createRoute(ProductPage(product: product))
      ),
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            SizedBox(
              width: 80,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Material(
                      elevation: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Image.network(product.imageLink),
                      ),
                    ),
                ),
            ),
            Expanded(flex: 1, child: Text(product.name)),
            Expanded(flex: 1, child: Text("${product.quantityAvailable} ${product.unitOfMeasurement}")),
            Expanded(flex: 1, child: Text("${(product.cost*product.quantityAvailable).toStringAsFixed(2)} €"))
          ],
        ),
      ),
    );
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

// Route de transition personnalisée pour la navigation vers la page de détails d'un produit (slide depuis la droite)
Route createRoute(Widget page){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child)
    {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: page,
      );
    }
    ,
  );
}



// Page affichant les détails d'un produit, avec les informations clés (prix, quantité nette, valorisation nette, etc.) et un tableau détaillé par récolte
class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({ super.key, required this.product });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

// State de la page de détails d'un produit, avec une requête pour récupérer les données détaillées du produit (crops) et un FutureBuilder pour afficher un tableau détaillé par récolte
class _ProductPageState extends State<ProductPage> {
  late Future<List<dynamic>> cropsFuture;

  @override
  void initState() {
    super.initState();
    cropsFuture = fetchCrops(widget.product.name);
  }

  //final ProductCard produit;
  
  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface, 
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined),
            SizedBox(width: 10),
            Text("Détails du produit"),
          ],
        )),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Titre du produit
          Row( 
            children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
                    child: Material(
                      elevation: 8,
                      color: Color.fromARGB(0, 0, 0, 0),
                      clipBehavior: Clip.antiAlias,
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
                        child: Image.network(product.imageLink)
                      ),
                    ),
                  ),
                ),
              Text(product.name, textScaler: TextScaler.linear(3)),
            ],
          ),
          // Divider
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10,  bottom: 20),
            child: Divider(color: Theme.of(context).colorScheme.onSurface),
          ),
          // General information related to the product
          Row(
            children: [
              InformationCard(caption: "Prix (/${product.unitOfMeasurement})", value: "${product.cost} €"),
              InformationCard(caption: "Quantité nette", value: "${product.quantityAvailable} ${product.unitOfMeasurement}"),
              InformationCard(caption: "Valorisation nette", value: "${(product.cost*product.quantityAvailable).toStringAsFixed(2)} €"),
            ],
          ), 
          // Tableau détaillé des récoltes
          // Une ligne correspond à une date de récolte
          FutureBuilder(              
            future: cropsFuture,
            builder: (context, snapshot) {
              // TODO: Gérer la mise en cache des données, pour éviter de faire une requête à chaque fois que l'on clique sur un produit
          
              // Loading
              if(snapshot.connectionState == ConnectionState.waiting)
              {
                return const Center(child: CircularProgressIndicator());
              }
              
              // In case of error
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur : ${snapshot.error}'),
                );
              }
              
              // In case of success
              final cropsData = snapshot.data!; // products non nullable
          
          
              List<Crop> crops = cropsData.map<Crop>((cropData) => Crop(
                productName: cropData["product_name"],
                produceDate: DateTime.parse(cropData["produce_date"]),
                expirationDate: DateTime.parse(cropData["expiration_date"]),
                storageLocation: cropData["storage_location"],
                quantity: double.parse(cropData["quantity"].toString()),
                valorization: double.parse(cropData["quantity"].toString()) * product.cost
              )).toList();
              
          
              return Row(
                children: [
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                    child: CropsTable(crops: crops, unitOfMeasurement: product.unitOfMeasurement),
                  )),
                ],
              );
            }
          ),
                  
          // Courbe d'évolution du produit
          // Courbe de quantité nette en fonction du temps
          // Sur le même graphe, possibilité d'afficher plusieurs courbes 
          //Text("Courbe de quantité nette en fonction du temps"), 
          //Text("Courbe de quantité brut en fonction du temps"), 
          //Text("Courbe de production en fonction du temps"), 
          //Text("Perte en fonction du temps"), 
        ],
      ),
    );
  }

}

// Card d'information utilisée pour afficher les informations clés d'un produit (prix, quantité nette, valorisation nette, etc.)
class InformationCard extends StatelessWidget {
  final String value;
  final String caption;
  final String? dynamicInfo; // Information dynamique qui change en fonction de la valeur (ex: si valorisation nette élevée, afficher "Valorisation élevée", etc.), si nombre de produits, afficher le nombre de produits pour chaque catégorie (ex: 10 produits avec une valorisation nette élevée, 5 produits avec une valorisation nette moyenne, etc.)

  const InformationCard({super.key, required this.value, required this.caption, this.dynamicInfo});

  @override
  Widget build(BuildContext context)
  {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10 , bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, 
            border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SelectableText(caption, textScaler: TextScaler.linear(1.2), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
                    SelectableText(value, textScaler: TextScaler.linear(2)),
                    if (dynamicInfo != null)
                      SelectableText(dynamicInfo!, textScaler: TextScaler.linear(1.2), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withAlpha(100))),
                    // TODO : Ajouter du texte dynamique qui change en fonction de la valeur (ex: si valorisation nette élevée, afficher "Valorisation élevée", etc.), si nombre de produits, afficher le nombre de produits pour chaque catégorie (ex: 10 produits avec une valorisation nette élevée, 5 produits avec une valorisation nette moyenne, etc.)
                  ],
                ),
            ),
        ),
      ),
    );
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

// Tableau détaillé par récolte, avec une ligne par date de récolte et les informations clés (date de récolte, date limite de conservation, quantité nette, valorisation, etc.) pour chaque récolte
class CropsTable extends StatelessWidget {
  final List<Crop> crops;
  final String unitOfMeasurement;

  const CropsTable({super.key, required this.crops, required this.unitOfMeasurement});


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 0.2),
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: DataTable(
        columns: [
          DataColumn(
            label: Text("Date de récolte/ramassage")
          ),
          DataColumn(
            label: Text("Lieu de stockage")
          ),
          DataColumn(
            label: Text("Quantité nette ($unitOfMeasurement)")
          ),
          DataColumn(
            label: Text("Date limite de conservation")
          ),
          DataColumn(
            label: Text("Valorisation (€)")
          ),
        ], rows: createRows(crops)),
    );
  }

  List<DataRow> createRows(List<Crop> crops)
  {
    return crops.map((crop) {
      return DataRow(
        cells: 
        [
          DataCell(Text(crop.produceDate.toString().split(' ')[0])),
          DataCell(Text(crop.storageLocation)),
          DataCell(Text(crop.quantity.toString())),
          DataCell(Text(crop.expirationDate.toString().split(' ')[0])),
          DataCell(Text(crop.valorization.toStringAsFixed(2).toString())),
        ]
      );
    }).toList();
  }
}