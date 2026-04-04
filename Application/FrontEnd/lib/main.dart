import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'inventaire.dart';

void main() {
  runApp(ChangeNotifierProvider<MyAppState>(
    create: (context) => MyAppState(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return MaterialApp(
      title: 'Click And Collect',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appState.themeMode,
      home: MyHomePage(),
    );
  }
}

class MyAppState extends ChangeNotifier {
  //TODO: Gérer la mise en cache des données, et les appels à l'API
  ThemeMode themeMode = ThemeMode.light;

  void toggleThemeMode() {
    themeMode = (themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
    notifyListeners(); // Notify listeners to rebuild the UI with the new theme mode
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
          final appColors = Theme.of(context).extension<AppColors>()!;
          const maxWidth = 1200;
          return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    backgroundColor: appColors.railColor,
                    selectedIconTheme: IconThemeData(color: appColors.selectedIconColor),
                    unselectedIconTheme: IconThemeData(color: appColors.unselectedIconColor),
                    selectedLabelTextStyle: TextStyle(color: appColors.selectedIconColor),
                    unselectedLabelTextStyle: TextStyle(color: appColors.unselectedIconColor),
                    indicatorColor: appColors.indicatorColor,
                    indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: appColors.indicatorColor, width: 1)), // Ajustez les dimensions selon vos besoins

                    labelType: constraints.maxWidth >= maxWidth ? NavigationRailLabelType.none : NavigationRailLabelType.all, // Affiche les labels uniquement si l'écran est petit
                    extended: constraints.maxWidth >= maxWidth, // Important pour la bonne compatibilté avec mobile ? TBC
                    destinations
                    : [
                      NavigationRailDestination(
                        icon: Icon(Icons.receipt_long), 
                        label: Text("Commandes")),
                      NavigationRailDestination(
                        icon: Icon(Icons.inventory), 
                        label: Text("Stocks")),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings), 
                        label: Text("Réglages")),
                    ],
                    trailing: Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: IconButton(
                            onPressed: () {
                              context.read<MyAppState>().toggleThemeMode();
                            }, 
                            icon: Icon( 
                              context.watch<MyAppState>().themeMode == ThemeMode.light ? Icons.brightness_7 : Icons.brightness_2, 
                              color: appColors.unselectedIconColor),
                          ),
                        ),
                      ),
                    ),
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

    //var theme = Theme.of(context);
    //final style = theme.textTheme.displaySmall!.copyWith(color: theme.colorScheme.onSecondary, fontSize: 20);

    // ---- To Do ----

  
    return Placeholder();
  }
}



