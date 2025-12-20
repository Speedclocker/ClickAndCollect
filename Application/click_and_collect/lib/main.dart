
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Click And Collect',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext()
  {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch(selectedIndex)
    {
      case 0:
      page = FavoritesPage();
      break;
      case 1:
      page = GestionDesStocksPage();
      break;
      default:
      page = Placeholder();
      //throw UnimplementedError('no widget for $selectedIndex');
      break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(children: [
            SafeArea(
              child: NavigationRail(
                backgroundColor: Theme.of(context).colorScheme.primary,
                selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
                unselectedIconTheme: IconThemeData(color: Colors.white),
                selectedLabelTextStyle: TextStyle(color: Colors.white),
                unselectedLabelTextStyle: TextStyle(color: Colors.white),
                extended: constraints.maxWidth >= 600,
                destinations
                : [
                  NavigationRailDestination(
                    icon: Icon(Icons.receipt_long), 
                    label: Text("Gestion des commandes")),
                  NavigationRailDestination(
                    icon: Icon(Icons.inventory), 
                    label: Text("Gestion des stocks")),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings), 
                    label: Text("Paramètres"))
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {selectedIndex = value;});
                }
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page))
            ]
          )
        );
      }
    );
  }
}

class GestionDesStocksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

  //var appState = context.watch<MyAppState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Expanded(
            child: ListView(
              children: [
                ProductCard(
                  imageLink: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Red_Apple.jpg/1200px-Red_Apple.jpg",
                  productName: "Pommes", 
                  quantityAvailable: 41.6,
                  unitOfMeasurement: "kg"
                ),
                ProductCard(
                  imageLink: "https://upload.wikimedia.org/wikipedia/commons/8/8a/Banana-Single.jpg",
                  productName: "Bananes", 
                  quantityAvailable: 35.3,
                  unitOfMeasurement: "kg"
                ),
                ProductCard(
                  imageLink: "https://media.istockphoto.com/id/120742288/fr/photo/jus-dorange.jpg?s=612x612&w=0&k=20&c=kzTPf-07pLaVTV6yj5BkjOiSqD4mvSW9mAz6KyoJYDY=",
                  productName: "Jus d'orange (1L)", 
                  quantityAvailable: 100,
                  unitOfMeasurement: "bouteille(s)"
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    
    IconData icon;
    if(appState.favorites.contains(appState.current))
    {
      icon = Icons.favorite;
    }
    else
    {
      icon = Icons.favorite_border;
    }

    return ElevatedButton.icon(onPressed: () 
      {
        appState.toggleFavorite();
      },
      icon: Icon(icon),
      label: Text("Like"),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: LayoutBuilder(
        builder: (context, constraints)
        {
          return Card (
            child: ListTile(
              leading: SizedBox(
                width: 50,
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(10),
                  child: Image.network(imageLink),
                ),
              ), 
              title: Text(productName),
              subtitle: Text("Quantité : $quantityAvailableStr $unitOfMeasurement"),
              onTap: () => print(productName),
            )
          );
        },
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    var theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(color: theme.colorScheme.onSecondary, fontSize: 20);

    return ListView(
      children: favorites.map((pair) => 
          Card(
            color: theme.colorScheme.secondary,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(pair.asString, style: style),
            ),
          )
      ).toList()
    );
  }
}