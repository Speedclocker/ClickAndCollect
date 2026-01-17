import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;


Future<List<dynamic>> fetchProducts() async {
  final response = await http.get(
    Uri.parse('http://127.0.0.1:8000/product/')
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Erreur API');
  }
}

class GestionDesStocksPage extends StatelessWidget {
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
                  future: fetchProducts(), 
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
                        return ProductCard(
                          imageLink: products[index]["imageLink"],
                          productName: products[index]["name"],
                          quantityAvailable: products[index]["quantity"],
                          unitOfMeasurement: products[index]["unitOfMeasurement"],
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


class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.imageLink,
    required this.productName,
    required this.quantityAvailable,
    required this.unitOfMeasurement,
  });

  final String imageLink, productName, unitOfMeasurement;
  final double quantityAvailable;
  

  @override
  Widget build(BuildContext context) {
    var quantityAvailableStr = quantityAvailable.toString();
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
                    child: Image.network(imageLink),
                  ),
                ), 
                title: Text(productName),
                subtitle: Text("Quantité : $quantityAvailableStr $unitOfMeasurement"),
                onTap: () {
                  Navigator.of(context).push(
                    createRoute(ProduitPage(produit: this))
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

class ProduitPage extends StatelessWidget {
  final ProductCard produit;

  const ProduitPage({super.key, required this.produit});
  
  @override
  Widget build(BuildContext context) {
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
                          child: Image.network(produit.imageLink)
                        ),
                      ),
                    ),
                  ),
                Text(produit.productName, textScaler: TextScaler.linear(3)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Divider(color: Theme.of(context).colorScheme.onSurface),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InformationCard(caption: "Prix (/${produit.unitOfMeasurement})", value: "1.99 €"),
                InformationCard(caption: "Quantité nette", value: "${produit.quantityAvailable} ${produit.unitOfMeasurement}"),
                InformationCard(caption: "Valorisation nette", value: "${(1.99*produit.quantityAvailable).toStringAsFixed(2)} €"),
                InformationCard(caption: "Quantité brute", value: "${produit.quantityAvailable} ${produit.unitOfMeasurement}"),
              ],
            ), // Quantité réelle présente en stock
            Padding(
              padding: const EdgeInsets.all(20),
              child: Divider(color: Theme.of(context).colorScheme.onSurface),
            ),
            
            
            // Tableau détaillé par récolte
            // Une ligne correspond à une date de récolte
            Row(
              children: [
                Expanded(child: RecolteTable(produit: produit)),
              ],
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
  

class RecolteTable extends StatelessWidget {
  final ProductCard produit;

  const RecolteTable({super.key, required this.produit});


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
              label: Text("Quantité nette (${produit.unitOfMeasurement})")
            ),
            DataColumn(
              label: Text("Date limite de conservation")
            ),
            DataColumn(
              label: Text("Valorisation (€)")
            ),
          ], rows: createRows(DateTime(2026,1,1), "Paris", produit.quantityAvailable, DateTime(2026,1,15), produit.quantityAvailable*1.99)),
      ),
    );
  }

  List<DataRow> createRows(DateTime dateRecolte, String lieuStockage, double quantite, DateTime dateLimiteCons, double valorisation)
  {
    List<Map> recoltes = [
      {
        "dateRecolte" : dateRecolte,
        "lieuStockage" : lieuStockage,
        "quantite" : quantite,
        "dateLimiteCons" : dateLimiteCons,
        "valorisation" : valorisation
      }
    ];
    
    return recoltes.map((recolte) {
      return DataRow(
        cells: 
        [
          DataCell(Text(recolte["dateRecolte"].toString().split(' ')[0])),
          DataCell(Text(recolte["lieuStockage"].toString())),
          DataCell(Text(recolte["quantite"].toString())),
          DataCell(Text(recolte["dateLimiteCons"].toString().split(' ')[0])),
          DataCell(Text((recolte["valorisation"] as double).toStringAsFixed(2).toString())),
        ]
      );
    }).toList();
  }
}