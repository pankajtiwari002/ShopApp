import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  String? _authToken;

  set token(String? token) => _authToken = token;
  String? _userId;

  set userid(String? userid) => _userId = userid;

  Future<void> fetchAndGetOrder() async {
    // log('call');
    final url =
        'https://shop-app-9e2de-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$_userId.json?auth=$_authToken';
    List<OrderItem> loadedOrders = [];
    final response = await http.get(Uri.parse(url));
    // log('0');
    // log(json.decode(response.body));
    final extractedOrder = json.decode(response.body);
    if (extractedOrder == null) {
      return;
    }
    try{
      extractedOrder.forEach((ordId, ordData) {
      loadedOrders.add(
        OrderItem(
          id: ordId,
          amount: ordData['amount'],
          dateTime: DateTime.parse(ordData['dateTime']),
          products: (ordData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ))
              .toList(),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    // log('2');
    }
    catch(error){
      // log('1');
      log(error.toString());
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://shop-app-9e2de-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$_userId.json?auth=$_authToken';
    final timeStamp = DateTime.now();
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price
                  })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timeStamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
