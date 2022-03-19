import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/category.dart';
import '../models/gallery.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../repository/category_repository.dart';
import '../repository/gallery_repository.dart';
import '../repository/market_repository.dart';
import '../repository/product_repository.dart';
import '../repository/settings_repository.dart';

class MarketController extends ControllerMVC {
  Market? market;
  List<Gallery>? galleries = <Gallery>[];
  List<Product>? products = <Product>[];
  List<Category>? categories = <Category>[];
  List<String>? selectedCategories = [];

  List<Product>? trendingProducts = <Product>[];
  List<Product>? featuredProducts = <Product>[];
  List<Review>? reviews = <Review>[];
  GlobalKey<ScaffoldState>? scaffoldKey;
  ScrollController? controllerList;
  int indexlist = 10;
  bool loadingNextProducts = false;

  MarketController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  @override
  void initState() {
    indexlist = 10;
    controllerList = ScrollController();
    controllerList!.addListener(_scrollListener);
    super.initState();
  }


  _scrollListener() {
    if (controllerList!.offset >= controllerList!.position.maxScrollExtent &&
        !controllerList!.position.outOfRange) {

        // message = "reach the bottom";
        if (products!.length>this.indexlist){
          setState(() {
          this.loadingNextProducts = true;
          });
          Timer(Duration(seconds: 3), () {
            setState(() {
              this.loadingNextProducts = false;
              this.indexlist += 10;
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


  void listenForMarket({String? id, String? message,}) async {
    final Stream<Market> stream = await getMarket(id!, deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => market = _market);
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context)!.verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForGalleries(String idMarket) async {
    final Stream<Gallery> stream = await getGalleries(idMarket);
    stream.listen((Gallery _gallery) {
      setState(() => galleries!.add(_gallery));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForMarketReviews({String? id, String? message}) async {
    final Stream<Review> stream = await getMarketReviews(id!);
    stream.listen((Review _review) {
      setState(() => reviews!.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForProducts(String idMarket, {List<String>? categoriesId}) async {
    final Stream<Product> stream = await getProductsOfMarket(idMarket, categories: categoriesId!);
    stream.listen((Product _product) {
      setState(() => products!.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {
      market!..name = products?.elementAt(0).market?.name;
    });
  }

  void listenForTrendingProducts(String idMarket) async {
    final Stream<Product> stream = await getTrendingProductsOfMarket(idMarket);
    stream.listen((Product _product) {
      setState(() => trendingProducts!.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForFeaturedProducts(String idMarket) async {
    final Stream<Product> stream = await getFeaturedProductsOfMarket(idMarket);
    stream.listen((Product _product) {
      setState(() => featuredProducts!.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForCategories(String marketId) async {
    selectedCategories!.removeRange(0, selectedCategories!.length);
    final Stream<Category> stream = await getCategoriesOfMarket(marketId);
    stream.listen((Category _category) {
      if (selectedCategories!.isEmpty){
        selectedCategories!.add(_category.id!);
        listenForProducts(marketId,categoriesId: selectedCategories);
      }
      setState(() => categories!.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {
      // categories.insert(0, new Category.fromJSON({'id': '0', 'name': S.of(context).all}));
    });
  }

  Future<void> selectCategory(List<String> categoriesId,) async {
    products!.clear();
    listenForProducts(market!.id!, categoriesId: categoriesId);
  }

  Future<void> refreshMarket() async {
    var _id = market!.id;
    market = new Market();
    galleries!.clear();
    reviews!.clear();
    featuredProducts!.clear();
    listenForMarket(id: _id, message: S.of(context)!.market_refreshed_successfuly);
    listenForMarketReviews(id: _id);
    listenForGalleries(_id!);
    listenForFeaturedProducts(_id);
  }
}
