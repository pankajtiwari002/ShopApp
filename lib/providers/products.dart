import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  String? _authToken;
  // Products(this._authToken,this._items);
  set token(String? token) => _authToken = token;

  String? _userId;
  set userid(String? userid) => _userId = userid;

  Future<void> fetchAndGet([bool filter = false]) async{
      try{
        log('1');
          String filterString = filter ? 'orderBy="creatorId"&equalTo="$_userId"' : '';
          // String filterString = "";
          var url = 'https://shop-app-9e2de-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$_authToken&$filterString';
          final response = await http.get(Uri.parse(url)); 
          final List<Product> loadedProduct = [];
          // log('2');
          String responsestring = response.body.toString();
          final Map<String,dynamic> _extractedData = json.decode(responsestring);
          // log('3');
          url = 'https://shop-app-9e2de-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorite/$_userId.json?auth=$_authToken';
          // log('4');
          final Response favoriteResponse = await http.get(Uri.parse(url));
          // log('5');
          String favoritestring = favoriteResponse.body.toString();
          // log('6');
          final Map<String,dynamic> favoriteData = json.decode(favoritestring);
          // log(_extractedData.toString());
          _extractedData.forEach((prodId, prodData) {
            Product product = Product(
              id: prodId.toString(),
              description: prodData['description'].toString(),
              price: prodData['price'],
              imageUrl: prodData['imageUrl'].toString(),
              title: prodData['title'].toString(),
              isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false, 
                // id: prodId.toString(),
                // description: 'Pankaj Tiwari is a good boy',
                // price: 50.00,
                // imageUrl: "https://m.media-amazon.com/images/I/612LwAwHefL.SX679.jpg",
                // title: "Spiral Notebook",
                // isFavorite: false, 
            );
            // log('8');
            loadedProduct.add(product);
          });
          // log('9');
          _items = loadedProduct;
          notifyListeners();
          // print(json.decode(response.body));
      }catch(error){
        log(error.toString());
      }
  }

  Future<void> addProduct(Product product) async {

    log('add hua h');
    final url = 'https://shop-app-9e2de-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$_authToken';
    try{
      final response = await http.post(Uri.parse(url), body: json.encode({
      'creatorId': _userId,
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'imageUrl': product.imageUrl,
    }));
        Product newProduct = Product(
          // log(${json.decode(response.body).toString()});
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
        );
        _items.add(newProduct);
        notifyListeners();
    }catch(error){
      throw error;
    }
  }

  Future<void> updateProduct(String id,Product newProduct)async{
    // log('update hua h');
    final url = 'https://shop-app-9e2de-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$_authToken';
    final prodInd = _items.indexWhere((prod) => prod.id == id);
    if(prodInd >= 0){
      try{
        await http.patch(Uri.parse(url),body: json.encode({
          'title': newProduct.title,
          'imageUrl': newProduct.imageUrl,
          'description': newProduct.description,
          'price': newProduct.price,
        }));
        _items[prodInd] = newProduct;
        notifyListeners();
      }
      catch(error){
        print(error.toString());
      }
    }
  }

  Future<void> deleteProduct(String productId) async{
    final url = 'https://shop-app-9e2de-default-rtdb.asia-southeast1.firebasedatabase.app/products/$productId.json?auth=$_authToken';
    try{
       final response = await http.delete(Uri.parse(url));
       if(response.statusCode >= 400){
        throw 20;
       }
      _items.removeWhere((prod) => prod.id == productId);
      notifyListeners();
    }
    catch(error){
      print(error.toString());
      throw error;
    }
  }
}
