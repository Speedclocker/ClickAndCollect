import 'package:flutter/material.dart';

import 'commonwidgets.dart';
import 'productpage.dart';
import 'models.dart';



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
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Cards d'information affichant les informations clés de la gestion des stocks (valorisation totale, nombre de produits, etc.)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InformationCard(value: totalValorisationString, caption: "Valorisation totale", dynamicInfo: "Information dynamique",),
                InformationCard(value: totalProduits, caption: "Nombre de produits", dynamicInfo: "Information dynamique",),
              ],
            ),
            // Tableau de la liste des produits en stock, avec les informations clés (prix, quantité nette, valorisation nette, etc.) pour chaque produit et un lien vers la page de détails du produit en cliquant sur son nom
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
                  return SingleChildScrollView(
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
            ),
          ],
        ),
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
                  SizedBox(
                    width: 80,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                      ),
                  ),
                  Expanded(flex: 3, child: Text("Produit", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)))),
                  Expanded(flex: 3, child: Text("Quantité nette", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)))),
                  Expanded(flex: 3, child: Text("Valorisation nette", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)))),
                  SizedBox(
                    width: 80, 
                    child: Text("Etat", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)))
                  ),

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
            Expanded(flex: 3, child: Text(product.name)),
            Expanded(flex: 3, child: Text("${product.quantityAvailable} ${product.unitOfMeasurement}")),
            Expanded(flex: 3, child: Text("${(product.cost*product.quantityAvailable).toStringAsFixed(2)} €")),
            Builder(
              builder: (context) {
                // TODO: Faire évoluer le StatusPill en les rendant plus pertinent et en tenant compte de l'évolution des stocks au fil du temps 
                StatusPillValue statusPillValue = product.quantityAvailable > 0 ? StatusPillValue.ok : StatusPillValue.out;
                return SizedBox(
                  width: 80,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: StatusPill(value: statusPillValue)
                  )
                );
              }
            ),
          ],
        ),
      ),
    );
  }
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

