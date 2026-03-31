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


class GestionDesStocksPage extends StatefulWidget {
  @override
  State<GestionDesStocksPage> createState() => _GestionDesStocksPageState();
}



class _GestionDesStocksPageState extends State<GestionDesStocksPage> {
  late Future<List<dynamic>> productsFuture;

  @override
  void initState() {
    super.initState();
    productsFuture = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FutureBuilder(
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
        
                    return ListView.builder( // ListView builder utile pour un grand nombre d'objets (build uniquement ceux affichés)
                      itemCount: products.length,
                      itemBuilder: (context, index)
                      {
                        // In case of success
                        return ProductCard(
                          product: Product(
                            imageLink: products[index]["image_link"], 
                            name: products[index]["name"], 
                            quantityAvailable: double.parse(products[index]["total_stock"].toString()), 
                            unitOfMeasurement: products[index]["unit_of_measurement"], 
                            cost: double.parse(products[index]["cost"]))
                        );
                      }
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


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

// Card affichant les informations clés d'un produit (prix, quantité nette, valorisation nette, etc.) et permettant d'accéder à la page de détails du produit 
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product
  });

  @override
  Widget build(BuildContext context) {
    var quantityAvailableStr = product.quantityAvailable.toString();
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: LayoutBuilder(
          builder: (context, constraints)
          {
            return Card (
              child: ListTile(
                leading: SizedBox(
                  width: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(product.imageLink),
                  ),
                ), 
                title: Text(product.name),
                subtitle: Text("Quantité : $quantityAvailableStr ${product.unitOfMeasurement}"),
                onTap: () {
                  Navigator.of(context).push(
                    createRoute(ProductPage(product: product))
                  );
                } 
              )
            );
          },
        ),
      ),
    );
  }
}


Route createRoute(Widget page)
{
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

class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({ super.key, required this.product });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

// Page affichant les détails d'un produit, avec les informations clés (prix, quantité nette, valorisation nette, etc.) et un tableau détaillé par récolte
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
      appBar: AppBar(backgroundColor: Theme.of(context).secondaryHeaderColor,),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 30),
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Column(
          children: [
            Row( // Titre du produit
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Divider(color: Theme.of(context).colorScheme.onSurface),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InformationCard(caption: "Prix (/${product.unitOfMeasurement})", value: "${product.cost} €"),
                InformationCard(caption: "Quantité nette", value: "${product.quantityAvailable} ${product.unitOfMeasurement}"),
                InformationCard(caption: "Valorisation nette", value: "${(product.cost*product.quantityAvailable).toStringAsFixed(2)} €"),
                //InformationCard(caption: "Quantité brute", value: "${product.quantityAvailable} ${product.unitOfMeasurement}"),
              ],
            ), // Quantité réelle présente en stock
            Padding(
              padding: const EdgeInsets.all(20),
              child: Divider(color: Theme.of(context).colorScheme.onSurface),
            ),
            
            
            // Tableau détaillé par récolte
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
                List<Crop> crops = [];
                for (var cropData in cropsData) {         
                  crops.add(
                    Crop(
                      productName: cropData["product_name"],
                      produceDate: DateTime.parse(cropData["produce_date"]),
                      expirationDate: DateTime.parse(cropData["expiration_date"]),
                      storageLocation: cropData["storage_location"],
                      quantity: double.parse(cropData["quantity"].toString()),
                      valorization: double.parse(cropData["quantity"].toString()) * product.cost
                    )
                  );
                }

                return Row(
                  children: [
                    Expanded(child: CropsTable(crops: crops, unitOfMeasurement: product.unitOfMeasurement)),
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
      ),
    );
  }

}

// Card d'information utilisée pour afficher les informations clés d'un produit (prix, quantité nette, valorisation nette, etc.)
class InformationCard extends StatelessWidget {
  final String value;
  final String caption;

  const InformationCard({super.key, required this.value, required this.caption});

  @override
  Widget build(BuildContext context)
  {
    return Card(
      elevation: 5,
      child: SizedBox(
        width: 180,
        height: 120,
        child: Padding(
          padding: EdgeInsetsGeometry.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(child: SelectableText(value, textScaler: TextScaler.linear(2))),
              ),
              Spacer(),
              SelectableText(caption, textScaler: TextScaler.linear(1.2)),
            ],
          )
        ),
      ),
    );
  }
  
}

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

class CropsTable extends StatelessWidget {
  final List<Crop> crops;
  final String unitOfMeasurement;

  const CropsTable({super.key, required this.crops, required this.unitOfMeasurement});


  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
      child: Container(
        color: Theme.of(context).secondaryHeaderColor,
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
      ),
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