import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem>
    with SingleTickerProviderStateMixin {
  var _expanded = false;
  // AnimationController? _controller;
  // Animation<Size>? _heightAnimation;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   _controller =
  //       AnimationController(vsync: this, duration: Duration(milliseconds: 200));
  //   _heightAnimation = Tween<Size>(
  //           begin: Size(double.infinity, 50),
  //           end: Size(double.infinity,
  //               min(widget.order.products.length * 20.0 + 10, 100)))
  //       .animate(CurvedAnimation(parent: _controller!, curve: Curves.easeIn));
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height:
          _expanded ? min(widget.order.products.length * 20.0 + 130, 200) : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Rs ${widget.order.amount}'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
              ),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            // if (_expanded)
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: _expanded ? min(widget.order.products.length * 20.0 + 10, 100) : 0,
              // constraints: BoxConstraints(
              //   minHeight: _expanded
              //       ? min(widget.order.products.length * 20.0 + 105, 100)
              //       : 0,
              //   maxHeight: _expanded
              //       ? max(widget.order.products.length * 20.0 + 155, 100)
              //       : 0,
              // ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                height: min(widget.order.products.length * 20.0 + 10, 100),
                child: ListView(
                  children: widget.order.products
                      .map(
                        (prod) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              prod.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${prod.quantity}x Rs ${prod.price}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
