import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import '../screens/user_product_screen.dart';
import '../providers/auth.dart';
import '../screens/orders_screen.dart';
import '../helpers/custom_route.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello Friend!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () {
              // Navigator.of(context).pushReplacementNamed('/');
              Navigator.of(context).pushReplacement(CustomRoute(((context) => ProductsOverviewScreen())));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {
              // Navigator.of(context)
                  // .pushReplacementNamed(OrdersScreen.routeName);
                  Navigator.of(context).pushReplacement(CustomRoute(((context) => OrdersScreen())));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () {
              // Navigator.of(context)
              //     .pushReplacementNamed(UserProductScreen.routeName);
              Navigator.of(context).pushReplacement(CustomRoute(((context) => UserProductScreen())));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text('logout'),
            onTap: () async{
              await Provider.of<Auth>(context,listen: false).logout();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
