import 'package:flutter/material.dart';

import 'models.dart';
import 'commonwidgets.dart';


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
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Titre du produit
            Row( 
              children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
                    child: Material(
                      elevation: 8,
                      color: Color.fromARGB(0, 0, 0, 0),
                      clipBehavior: Clip.antiAlias,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Image.network(product.imageLink)
                      ),
                    ),
                  ),
                Text(product.name, textScaler: TextScaler.linear(3)),
              ],
            ),
            // Divider
            Divider(color: Theme.of(context).colorScheme.onSurface),
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
                    Expanded (
                      child: CropsTable(crops: crops, unitOfMeasurement: product.unitOfMeasurement)
                    ),
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

// Tableau détaillé par récolte, avec une ligne par date de récolte et les informations clés (date de récolte, date limite de conservation, quantité nette, valorisation, etc.) pour chaque récolte
class CropsTable extends StatelessWidget {
  final List<Crop> crops;
  final String unitOfMeasurement;

  const CropsTable({super.key, required this.crops, required this.unitOfMeasurement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
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
                  Expanded(flex: 1, child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text("Date récolte", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withAlpha(120))),
                  )),
                  Expanded(flex: 1, child: Text("Lieu stockage", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)))),
                  Expanded(flex: 1, child: Text("Quantité nette ($unitOfMeasurement)", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)))),
                  Expanded(flex: 1, child: Text("Date limite", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)))),
                  Expanded(flex: 1, child: Text("Valorisation (€)", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)))),

                ],
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.onSurface, thickness: 0.2, height: 0.0),
            // Liste des produits, avec une ligne par produit, les informations clés (prix, quantité nette, valorisation nette, etc.) pour chaque produit et un lien vers la page de détails du produit en cliquant sur son nom
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: crops.map((crop) => CropRow(crop: crop, unitOfMeasurement: unitOfMeasurement,)).toList(),
            ),
          ],
        ),
      ),
    );
  }

}


class CropRow extends StatelessWidget {
  final Crop crop;
  final String unitOfMeasurement;

  const CropRow({super.key, required this.crop, required this.unitOfMeasurement});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(flex: 1, child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(crop.produceDate.toString().split(' ')[0]),
          )),
          Expanded(flex: 1, child: Text(crop.storageLocation)),
          Expanded(flex: 1, child: Text('${crop.quantity.toString()} $unitOfMeasurement')),
          Expanded(flex: 1, child: Text(crop.expirationDate.toString().split(' ')[0])),
          Expanded(flex: 1, child: Text('${crop.valorization.toStringAsFixed(2).toString()} €')),
        ],
      ),
    );
  }
}
