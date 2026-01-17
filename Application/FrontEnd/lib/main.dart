
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'inventaire.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          
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

  final navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        final NavigatorState? currentNavigator = navigatorKeys[selectedIndex].currentState;

        if(currentNavigator != null && currentNavigator.canPop())
        {
          currentNavigator.pop();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
                    unselectedIconTheme: IconThemeData(color: Colors.white),
                    selectedLabelTextStyle: TextStyle(color: Colors.white),
                    unselectedLabelTextStyle: TextStyle(color: Colors.white),
                    extended: constraints.maxWidth >= 600, // Important pour la bonne compatibilté avec mobile ? TBC
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
                  child: IndexedStack(
                    index: selectedIndex,
                    children: [
                      SectionNavigator(
                        navigatorKey: navigatorKeys[0], 
                        rootPage: Placeholder(),
                      ),
                      SectionNavigator(
                        navigatorKey: navigatorKeys[1], 
                        rootPage: GestionDesStocksPage(),
                      ),
                      SectionNavigator(
                        navigatorKey: navigatorKeys[2], 
                        rootPage: Placeholder(),
                      ),
                    ],
                  )
                )
              ]
            );
        }
      ),
    );
  }
}

class SectionNavigator extends StatelessWidget{
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget rootPage;

  const SectionNavigator({
    required this.navigatorKey,
    required this.rootPage,
  });


  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey, // Afin de rattacher la clé
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (builder) => rootPage);
      }, 
    );
  }
}

class GestionDesCommandesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    var theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(color: theme.colorScheme.onSecondary, fontSize: 20);

    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListView(
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
      ),
    );
  }
}



