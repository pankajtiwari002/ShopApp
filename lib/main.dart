import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/splash_screen.dart';
import './providers/auth.dart';
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_product_screen.dart';
import './screens/edit_screen.dart';
import './screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider.value(
        value: Auth(),
      ),
      ChangeNotifierProxyProvider<Auth, Products>(
        create: (_) => Products(),
        update: (_, auth, products) {
          products!.token = auth.token;
          products.userid = auth.userId;
          return products;
        },
        // update: ((context, auth, previousData) => Products(auth.token, previousData!.items) ),
      ),
      ChangeNotifierProvider.value(
        value: Cart(),
      ),
      ChangeNotifierProxyProvider<Auth, Orders?>(
        create: (_) => Orders(),
        update: (_, auth, order) {
          order!.token = auth.token;
          order.userid = auth.userId;
          return order;
        },
        // update: ((context, auth, previousData) => Products(auth.token, previousData!.items) ),
      ),
    ], child: wrapper());
  }
}

class wrapper extends StatefulWidget {
  const wrapper({
    Key? key,
  }) : super(key: key);

  @override
  State<wrapper> createState() => _wrapperState();
}

class _wrapperState extends State<wrapper> {
  // var _isinit = true;
  // bool _isLoading = false;
  // bool isAlreadyLogin = false;
  // @override
  // void initState() {
  //   // TODO: implement initState

  //   Future.delayed(Duration.zero).then((_) async {
  //     // setState(() {
  //     //   _isLoading = true;
  //     // });
  //     isAlreadyLogin =
  //         await Provider.of<Auth>(context, listen: false).tryAutoLogin();
  //   });
  //   setState(() {
  //     _isLoading = false;
  //   });
    // Future.delayed(Duration(seconds: 5));
    // super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(
      builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
                  ? ProductsOverviewScreen()
                  // : AuthScreen(),
          : FutureBuilder(
              future: auth.tryAutoLogin(),
              builder: ((context, snapshot) =>
                  (snapshot.connectionState == ConnectionState.waiting)
                      ? SplashScreen()
                      : AuthScreen()
                  ),
            ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductScreen.routeName: (ctx) => UserProductScreen(),
            EditScreen.routeName: (ctx) => EditScreen(),
          }),
    );
  }
}
