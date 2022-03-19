import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';

import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/slide.dart';
import '../repository/category_repository.dart';
import '../repository/market_repository.dart';
import '../repository/product_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/slider_repository.dart';

class HomeController extends ControllerMVC {
  List<Category> categories = <Category>[];
  Category ?categoriesSouq;
  List<Slide> slides = <Slide>[];
  List<Market> topMarkets = <Market>[];
  List<Market> popularMarkets = <Market>[];
  List<Review> recentReviews = <Review>[];
  List<Product> trendingProducts = <Product>[];
  GlobalKey?  buttonLogIn; // used by RaisedButton
  HomeController() {
    buttonLogIn = GlobalObjectKey( Uuid().toString().substring(0,6));
    listenForTopMarkets();
    listenForSlides();
    listenForTrendingProducts();
    listenForCategories();
    listenForPopularMarkets();
    listenForRecentReviews();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  void showInfoLogInAdress(String infoMsg) {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = buttonLogIn!.currentContext!.findRenderObject()!as RenderBox;
//    RenderBox target = buttonLogIn.currentContext.findRenderObject();

    // you can change the shape of the mark
    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = Rect.fromCircle(center: markRect.center, radius: markRect.longestSide * 0.6);

    coachMarkFAB.show(
      targetContext: buttonLogIn!.currentContext,
      markRect: markRect,
      markShape: BoxShape.rectangle,
      children: [
        Positioned(
          top: markRect.bottom + 15.0,
          right: 5.0,
          child:  SizedBox(
            width: MediaQuery.of(context).size.width - 30,
            child: Text(
              infoMsg,
              style: const TextStyle(
                fontSize: 24.0,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
      duration: null, // we don't want to dismiss this mark automatically so we are passing null
      onClose: () => Timer(Duration(seconds: 1), () => {}),
    );
  }
  Future<void> listenForSlides() async {
    final Stream<Slide> stream = await getSlides();
    stream.listen((Slide _slide) {
      setState(() => slides.add(_slide));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForCategories() async {
    if (categories != null &&categories.length>0){
      categories.removeRange(0, categories.length);

    }
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      print("sadsaads");
      print(_category.name);
      print(_category.id);
      print(_category.image!.url);
      if(_category.id == "162"){
        setState(() => categories.add(_category));
      }
      else if(_category.id == "252"){
        setState((){ categoriesSouq = _category;});
        // setState(() => categories.add(_category));

      }else{
        setState(() => categories.add(_category));
      }
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForTopMarkets() async {
    final Stream<Market> stream = await getNearMarkets(deliveryAddress.value, deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => topMarkets.add(_market));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForPopularMarkets() async {
    final Stream<Market> stream = await getPopularMarkets(deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => popularMarkets.add(_market));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForRecentReviews() async {
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      setState(() => recentReviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForTrendingProducts() async {
    final Stream<Product> stream = await getTrendingProducts(deliveryAddress.value);
    stream.listen((Product _product) {
      setState(() => trendingProducts.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void requestForCurrentLocation() {
    // OverlayEntry loader = Helper.overlayLoader(context);
    // Overlay.of(context).insert(loader);

    setCurrentLocation().then((_address) async {

      deliveryAddress.value = _address;
      await refreshHome();
      // loader.remove();
    }).catchError((e) {
      // loader.remove();
    });
  }

  Future<void> refreshHome() async {
    setState(() {
      slides = <Slide>[];
      categories = <Category>[];
      topMarkets = <Market>[];
      popularMarkets = <Market>[];
      recentReviews = <Review>[];
      trendingProducts = <Product>[];
    });
    await listenForSlides();
    await listenForTopMarkets();
    await listenForTrendingProducts();
    await listenForCategories();
    await listenForPopularMarkets();
    await listenForRecentReviews();
  }
}
