

class CacheManager{
  
  // Temps de cache
  Duration cacheDuration;

  // Gestion des produits mis en cache
  List<dynamic>? _cachedProducts;
  DateTime? _cachedProductsDateTime;

  // Gestion des crops mis en cache
  final Map<String, List<dynamic>> _cachedCrops = {};
  final Map<String, DateTime> _cachedCropsDateTime = {};

  // Constructeur
  CacheManager({this.cacheDuration=const Duration(minutes: 1)});

  void clearProductsCache()
  {
    _cachedProducts = null;
  }

  // Fonction pour récupérer les produits en cache
  List<dynamic>? getCachedProducts(){
    if(_cachedProducts == null || _cachedProductsDateTime == null) return null;
    if(DateTime.now().difference(_cachedProductsDateTime!)> cacheDuration) return null;
    return _cachedProducts;
  }

  // Fonction pour mettre les produits dans le cache
  void cacheProducts(List<dynamic> products)
  {
    _cachedProducts = products;
    _cachedProductsDateTime = DateTime.now();
  }

  // Fonction pour récupérer les récoltes en cache
  List<dynamic>? getCachedCrops(String productName)
  {
    if(!_cachedCrops.containsKey(productName) || !_cachedCropsDateTime.containsKey(productName)) return null;
    if(DateTime.now().difference(_cachedCropsDateTime[productName]!) > cacheDuration) return null;
    return _cachedCrops[productName];
  }

  void cacheCrops(String productName, List<dynamic> crops)
  {
    _cachedCrops[productName] = crops;
    _cachedCropsDateTime[productName] = DateTime.now();
  }
}