import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../repository/cart_repository.dart';
import '../repository/category_repository.dart';
import '../repository/product_repository.dart';

class CategoryController extends ControllerMVC {
  List<Product> products = <Product>[];
  ScrollController? controllerList;
  int indexlist = 20;
  ValueNotifier<bool>? loadingNextProducts = new ValueNotifier(false);

  GlobalKey<ScaffoldState>? scaffoldKey;
  Category? category;
  bool loadCart = false;
  bool loadgetProducts = false;
  List<Cart> carts = [];
  List<Category> categories = <Category>[];
  List<String> selectedCategories =  [];
  CategoryController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  @override
  void initState() {
    indexlist = 20;
    controllerList = ScrollController(initialScrollOffset: 5.0)..addListener(_scrollListener);
    super.initState();
  }
  @override
  void dispose() {
    controllerList!.dispose();
    super.dispose();
  }
  _scrollListener() {

   if (controllerList!.offset >= controllerList!.position.maxScrollExtent &&
        !controllerList!.position.outOfRange) {

      // message = "reach the bottom";
      if (products.length>this.indexlist &&  this.loadingNextProducts!.value == false){
        this.loadingNextProducts!.value = true;
        Timer(Duration(milliseconds: 800), () {
          setState(() {
            this.loadingNextProducts!.value = false;
            this.indexlist += 20;
          });
        });

      }



    }
    // if (controllerList.offset <= controllerList.position.minScrollExtent &&
    //     !controllerList.position.outOfRange) {
    //   setState(() {
    //
    //     // message = "reach the top";
    //   });
    // }
  }

  Future<void> selectCategory(String categoriesId) async {
    products.clear();
    listenForProductsByCategory(id: categoriesId);
  }


  //
  void listenForProductsByCategory({String? id, String? message}) async {
    setState((){
      loadgetProducts = true;
    });
    final Stream<Product> stream = await getProductsByCategory(id);
    stream.listen((Product _product) {
      setState(() {
        products.add(_product);
        loadgetProducts = false;
      });
    }, onError: (a) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context!)!.verify_your_internet_connection),
      ));
      if(loadgetProducts){
        setState((){
          loadgetProducts = false;
        });
      }
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
      if(loadgetProducts){
        setState((){
          loadgetProducts = false;
        });
      }
    });
  }

  void listenForCategory({String? id, String? message}) async {
    final Stream<Category> stream = await getCategory(id!);
    stream.listen((Category _category) {
      setState(() {
        category = _category;
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context!)!.verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void getSubCategory({String? id, String? message}) async {
    final Stream<Category> stream = await getSubCategoryRepo(id!);
    stream.listen((Category _category) {
      if (selectedCategories.length == 0){
        selectedCategories.add(_category.id!);
        selectCategory(selectedCategories[0]);
        print("selectedCategories");
        print(id);
        print(_category.id);
      }
      setState(() => categories.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      carts.add(_cart);
    });
  }

  bool isSameMarkets(Product product) {
    if (carts.isNotEmpty) {
      return carts[0].product?.market?.id == product.market?.id;
    }
    return true;
  }

  /*void addToCart(Product product, {bool reset = false}) async {
    setState(() {
      this.loadCart = true;
    });
    var _cart = new Cart();
    _cart.product = product;
    _cart.options = [];
    _cart.quantity = 1;
    addCart(_cart, reset).then((value) {
      setState(() {
        this.loadCart = false;
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).this_product_was_added_to_cart),
      ));
    });
  }*/

  void addToCart(Product product, {bool reset = false}) async {
    if (product.packageItemsCount != null && product.packageItemsCount != "" &&
        int.parse(product.packageItemsCount!) <= 0){
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context!)!.QuantityIsOut),
      ));
      return;
    }
    setState(() {
      this.loadCart = true;
    });
    var _newCart = new Cart();
    _newCart.product = product;
    _newCart.options = [];
    _newCart.quantity = 1;
    // if product exist in the cart then increment quantity
    var _oldCart = isExistInCart(_newCart);
    if (_oldCart != null) {

      if (_newCart.product!.packageItemsCount != null &&
          _newCart.product!.packageItemsCount != "" &&
      _oldCart.quantity!+1>int.parse(_newCart.product!.packageItemsCount!)){
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context!)!.Notpossible_product),
        ));
        setState(() {
          this.loadCart = false;
        });
        return;
      }
      _oldCart.quantity =_oldCart.quantity!+1;
      updateCart(_oldCart).then((value) {
        setState(() {
          this.loadCart = false;
        });
      }).whenComplete(() {
        setState(() {
          this.loadCart = false;
        });
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context!)!.this_product_was_added_to_cart),
        ));
      });
    } else {
      // the product doesnt exist in the cart add new one
      addCart(_newCart, reset).then((value) {
        setState(() {
          carts.add(value);
          this.loadCart = false;
        });

      }).whenComplete(() {
         setState(() {
          this.loadCart = false;
        });
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context!)!.this_product_was_added_to_cart),
        ));
      });
    }
  }

  Cart isExistInCart(Cart _cart) {
    return carts.firstWhere((Cart oldCart) => _cart.isSame(oldCart), orElse: () => null!);
  }

  Future<void> refreshCategory() async {
    products.clear();
    // category = new Category();
    // listenForProductsByCategory(message: S.of(context).category_refreshed_successfuly);
    // listenForCategory(message: S.of(context).category_refreshed_successfuly);
    listenForProductsByCategory(id:selectedCategories[0],message: S.of(context!)!.category_refreshed_successfuly);

  }
}
