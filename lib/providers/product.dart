import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token,String userId) async{
    isFavorite = !isFavorite;
    notifyListeners();
    final url = 'https://shop-app-9e2de-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorite/$userId/$id.json?auth=$token';
    try{
      final response = await http.put(Uri.parse(url),body: json.encode(
        isFavorite,
      ));
      if(response.statusCode >= 400){
        throw 20;
      }
    }
    catch(error){
      isFavorite = !isFavorite;
      notifyListeners();
      print(error.toString());
      throw error;
    }
  }
}
