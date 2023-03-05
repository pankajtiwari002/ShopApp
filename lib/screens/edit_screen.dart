import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import '../providers/product.dart';

class EditScreen extends StatefulWidget {
  static const routeName = '/edit-screen';
  // bool urlfocus = false;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _urlcontroller = TextEditingController();
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _urlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  bool _isInit = true;
  bool _isloading = false;
  var _editingProduct = Product(
    id: '',
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  Map<String, String> _initValues = {
    'title': '',
    'price': '',
    'imageUrl': '',
    'description': ''
  };

  @override
  void dispose() {
    // TODO: implement dispose
    _urlFocusNode.removeListener(_updateImageUrl);
    _urlFocusNode.dispose();
    _priceFocusNode.dispose();
    _urlcontroller.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_urlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _urlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments;
      if (productId != null) {
        _editingProduct =
            Provider.of<Products>(context).findById(productId.toString());
        _initValues = {
          'title': _editingProduct.title,
          'price': _editingProduct.price.toString(),
          'imageUrl': '',
          'description': _editingProduct.description,
        };
        _urlcontroller.text = _editingProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _saveForm() async {
    var isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isloading = true;
    });
    if (_editingProduct.id != '') {
      try {
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editingProduct.id, _editingProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('An error eccured!'),
                content: Text('Something went wrong'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text('Okay'),
                  )
                ],
              );
            });
      }
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editingProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('An error eccured!'),
                content: Text('Something went wrong'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text('Okay'),
                  )
                ],
              );
            });
      } 
      // finally {
      //   setState(() {
      //     _isloading = false;
      //     log('khattam');
      //   });
      //   log('done');
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isloading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _isloading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(
                        label: Text('Title'),
                      ),
                      validator: (value) {
                        return value!.isEmpty ? 'Please, Enter Title' : null;
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: ((_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      }),
                      onSaved: (value) {
                        _editingProduct = Product(
                          id: _editingProduct.id,
                          title: value!,
                          description: _editingProduct.description,
                          price: _editingProduct.price,
                          imageUrl: _editingProduct.imageUrl,
                          isFavorite: _editingProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(
                        label: Text('Price'),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter a Price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please Enter a valid Number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please Enter a number greater than 0';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: ((_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      }),
                      focusNode: _priceFocusNode,
                      onSaved: (value) {
                        _editingProduct = Product(
                          id: _editingProduct.id,
                          title: _editingProduct.title,
                          description: _editingProduct.description,
                          price: value!.isEmpty ? 0.0 : double.parse(value),
                          imageUrl: _editingProduct.imageUrl,
                          isFavorite: _editingProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(
                        label: Text('Description'),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter a Description';
                        }
                        if (value.length <= 10) {
                          return 'Should be atleast 10 character long';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _editingProduct = Product(
                          id: _editingProduct.id,
                          title: _editingProduct.title,
                          description: value!,
                          price: _editingProduct.price,
                          imageUrl: _editingProduct.imageUrl,
                          isFavorite: _editingProduct.isFavorite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Focus(
                          onFocusChange: (Value) {
                            if (!Value) {
                              setState(() {});
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 8, right: 10),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                                border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            )),
                            child: _urlcontroller.text.isEmpty
                                ? Center(child: Text("Enter a Url"))
                                : FittedBox(
                                    child: Image.network(
                                      _urlcontroller.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            // initialValue: _initValues['imageUrl'],
                            controller: _urlcontroller,
                            decoration: InputDecoration(label: Text('URL')),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.url,
                            focusNode: _urlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                              setState(() {});
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please Enter a Url';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Enter a valid Url';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editingProduct = Product(
                                  id: _editingProduct.id,
                                  title: _editingProduct.title,
                                  description: _editingProduct.description,
                                  price: _editingProduct.price,
                                  imageUrl: value!,
                                  isFavorite: _editingProduct.isFavorite);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
