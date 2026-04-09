import 'package:flutter/material.dart';


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
        padding: const EdgeInsets.all(10),
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
                    SelectableText(caption, textScaler: TextScaler.linear(1.2), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
                    SelectableText(value, textScaler: TextScaler.linear(2), style: TextStyle(fontWeight: FontWeight.bold)),
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

  
enum StatusPillValue {ok, low, out}

class StatusPill extends StatelessWidget{
  final StatusPillValue value;

  const StatusPill({
    required this.value
    });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context)
      {
        if(value == StatusPillValue.ok)
        {
          return Container(
            width: 50,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "OK",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        else if(value == StatusPillValue.low)
        {
          return Container(
            width: 50,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Faible",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.orange,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        else
        {
          return Container(
            width: 50,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Epuisé",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
      }
    );
  }
}