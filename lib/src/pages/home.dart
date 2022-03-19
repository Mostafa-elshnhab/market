import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/home_controller.dart';
import '../elements/CardsCarouselWidget.dart';
import '../elements/CaregoriesCarouselWidget.dart';
import '../elements/DeliveryAddressBottomSheetWidget.dart';
import '../elements/GridWidget.dart';
import '../elements/HomeSliderWidget.dart';
import '../elements/ProductsCarouselWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  HomeWidget({Key? key,this.parentScaffoldKey}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  HomeController? _con;
  _HomeWidgetState() : super(HomeController()) {
    _con = controller as HomeController?;
  }


  @override
  void initState() {
    super.initState();
    if ((currentUser.value.id == null ||currentUser.value.id =="")) {
      Timer(Duration(seconds: 2), ()  {
      if ((currentUser.value.id == null ||currentUser.value.id =="") && Helper.getInfoLogInEnable) {
        try{
          Helper.getInfoLogInEnable = false;
          _con!.showInfoLogInAdress("يرجى تسجيل الدخول من هنا");
        }catch(e){

        }
      }
      });
    }else if ((settingsRepo.deliveryAddress.value==null || settingsRepo.deliveryAddress.value.address == null)){
      Timer(Duration(seconds: 2), ()  {
        if ((settingsRepo.deliveryAddress.value==null || settingsRepo.deliveryAddress.value.address == null )&& Helper.getInfoAddressEnable) {
          try{
            _con!.showInfoLogInAdress(S.of(context)!.Please_address);
            Helper.getInfoAddressEnable = false;
          }catch(e){

          }
        }
      });
    }

  }
bool location = true;
  @override
  Widget build(BuildContext context) {

    print("fff ${settingsRepo.deliveryAddress.value?.address}");
    // if (location && (settingsRepo.deliveryAddress.value == null || settingsRepo.deliveryAddress.value?.address == null ||settingsRepo.deliveryAddress.value?.address == "")){
    //   Future.delayed(Duration(seconds: 5), () {
    //     if ((settingsRepo.deliveryAddress.value == null || settingsRepo.deliveryAddress.value?.address == null ||settingsRepo.deliveryAddress.value?.address == "")) {
    //       if (currentUser.value.apiToken == null ||
    //           currentUser.value.apiToken == '') {
    //         _con.requestForCurrentLocation(context);
    //       } else {
    //         Navigator.of(context).pushNamed('/DeliveryAddresses');
    //
    //         // var bottomSheetController = widget.parentScaffoldKey.currentState
    //         //     .showBottomSheet(
    //         //       (context) =>
    //         //       DeliveryAddressBottomSheetWidget(
    //         //           scaffoldKey: widget.parentScaffoldKey),
    //         //   shape: RoundedRectangleBorder(
    //         //     borderRadius: new BorderRadius.only(
    //         //         topLeft: Radius.circular(10),
    //         //         topRight: Radius.circular(10)),
    //         //   ),
    //         // );
    //         // bottomSheetController.closed.then((value) {
    //         //   _con.refreshHome();
    //         // });
    //       }
    //     }
    //   });
    //   location = false;
    // }

    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey!.currentState!.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder(
          valueListenable: settingsRepo.setting,
          builder: (context, value, child) {
            return Text(
               S.of(context)!.home,
              style: Theme.of(context).textTheme.headline6!.merge(TextStyle(letterSpacing: 1.3)),
            );
          },
        ),
        actions: <Widget>[
           ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor,),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con!.refreshHome,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: List.generate(settingsRepo.setting.value.homeSections.length, (index) {
              String _homeSection = settingsRepo.setting.value.homeSections.elementAt(index);
              switch (_homeSection) {
                case 'slider':
                  return HomeSliderWidget(slides: _con!.slides);
                case 'popular':
                  if (_con!.categoriesSouq == null)
                    {
                        return Text("");
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    // child: GridWidget(
                    //   marketsList: _con.popularMarkets,
                    //   heroTag: 'home_markets',
                    // ),
                    child:  InkWell(
                      onTap: (){
                        Navigator.of(context).pushNamed('/SubcategoriesWidget', arguments: RouteArgument(id: "252"));
                        // Navigator.of(context).pushNamed('/Category', arguments: RouteArgument(id: "162"));

                        // print(_con.categoriesSouq.image.url);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: CachedNetworkImage(
                          height: 170,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          imageUrl: _con!.categoriesSouq!.image!.url!,
                          placeholder: (context, url) => Image.asset(
                            'assets/img/loading.gif',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 170,
                          ),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                    ),
                  );
                case 'search':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SearchBarWidget(
                      onClickFilter: (event) {
                        widget.parentScaffoldKey!.currentState!.openEndDrawer();
                      },
                    ),
                  );
                case 'top_markets_heading':
                  return Padding(
                    padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                S.of(context)!.top_markets,
                                style: Theme.of(context).textTheme.headline4,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            InkWell(
                              key: _con!.buttonLogIn,
                              onTap: () {
                                if (currentUser.value.id == null ||currentUser.value.id =="") {
                                  // _con.requestForCurrentLocation(context);
                                  Navigator.of(context).pushNamed('/LoginPhone');
                                } else {
                                  Navigator.of(context).pushNamed('/DeliveryAddresses');
                                  // var bottomSheetController = widget.parentScaffoldKey.currentState.showBottomSheet(
                                  //   (context) => DeliveryAddressBottomSheetWidget(scaffoldKey: widget.parentScaffoldKey),
                                  //   shape: RoundedRectangleBorder(
                                  //     borderRadius: new BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                  //   ),
                                  // );
                                  // bottomSheetController.closed.then((value) {
                                  //   _con.refreshHome();
                                  // });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  color:  Theme.of(context).accentColor,
                                ),
                                child: Text(
              (currentUser.value.id == null ||currentUser.value.id =="")  ? S.of(context)!.login:S.of(context)!.address,
                                  style: TextStyle(
                                      color:Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            SizedBox(width: 7),
                            // InkWell(
                            //   onTap: () {
                            //     setState(() {
                            //       settingsRepo.deliveryAddress.value?.address = null;
                            //     });
                            //   },
                            //   child: Container(
                            //     padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.all(Radius.circular(5)),
                            //       color: settingsRepo.deliveryAddress.value?.address != null
                            //           ? Theme.of(context).focusColor.withOpacity(0.1)
                            //           : Theme.of(context).accentColor,
                            //     ),
                            //     child: Text(
                            //       S.of(context).pickup,
                            //       style: TextStyle(
                            //           color:
                            //               settingsRepo.deliveryAddress.value?.address != null ? Theme.of(context).hintColor : Theme.of(context).primaryColor),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        if (settingsRepo.deliveryAddress.value.address != null)
                         ...{
                           Padding(
                             padding: const EdgeInsets.only(top: 12),
                             child: Text(
                               S.of(context)!.near_to + " " + (settingsRepo.deliveryAddress.value.address!),
                               style: Theme.of(context).textTheme.caption,
                             ),
                           ),
                         }else if (currentUser.value.id != null && currentUser.value.id !="") ...{
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed('/DeliveryAddresses');

                            },
                            child:Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              S.of(context)!.Please_address,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                            )
                        }
                      ],
                    ),
                  );
                case 'top_markets':
                  return CardsCarouselWidget(marketsList: _con!.topMarkets, heroTag: 'home_top_markets');
                case 'trending_week_heading':
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    leading: Icon(
                      Icons.trending_up,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context)!.trending_this_week,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle: Text(
                      S.of(context)!.clickOnTheProductToGetMoreDetailsAboutIt,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  );
                case 'trending_week':
                  return ProductsCarouselWidget(productsList: _con!.trendingProducts, heroTag: 'home_product_carousel');
                case 'categories_heading':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.category,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context)!.product_categories,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );
                case 'categories':
                  return CategoriesCarouselWidget(
                    categories: _con!.categories,
                  );
                case 'popular_heading':
                  return Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.trending_up,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context)!.most_popular,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );

                case 'recent_reviews_heading':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                      leading: Icon(
                        Icons.recent_actors,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context)!.recent_reviews,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );
                case 'recent_reviews':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ReviewsListWidget(reviewsList: _con!.recentReviews),
                  );
                default:
                  return SizedBox(height: 0);
              }
            }),
          ),
        ),
      ),
    );
  }
}
