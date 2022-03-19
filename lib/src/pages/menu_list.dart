import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/market_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/ProductItemWidget.dart';
import '../elements/ProductsCarouselWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/market.dart';
import '../models/route_argument.dart';

class MenuWidget extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
  final RouteArgument? routeArgument;
  MenuWidget({Key? key, this.routeArgument,}) : super(key: key);
}

class _MenuWidgetState extends StateMVC<MenuWidget> {
  MarketController? _con;
  ValueNotifier<bool> refreshState = new ValueNotifier(false);
  _MenuWidgetState() : super(MarketController()) {
    _con = controller as MarketController?;
  }

  @override
  void initState() {
    _con!.market = (new Market())..id = widget.routeArgument!.id;
    _con!.listenForTrendingProducts(widget.routeArgument!.id!);
    _con!.listenForCategories(widget.routeArgument!.id!);
    // _con.listenForProducts(widget.routeArgument.id);
    super.initState();
  }

  void _selectTab(int tabItem) {
    Navigator.of(context).pushNamed('/Pages', arguments: tabItem);
  }
  @override
  Widget build(BuildContext context) {

    return  ValueListenableBuilder<bool>(
        valueListenable: refreshState,
        builder: (context, value, child) {
          if (refreshState.value){
            _con!.scaffoldKey!.currentState?.showSnackBar(SnackBar(
              content: Text(S.of(context)!.this_product_was_added_to_cart),
            ));
             Future.delayed(Duration(seconds: 2)).then((_) {
               refreshState.value = false;
            });
          }

          return Scaffold(
              key: _con!.scaffoldKey,
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Theme.of(context).accentColor,
                selectedFontSize: 0,
                unselectedFontSize: 0,
                iconSize: 22,
                elevation: 0,
                backgroundColor: Colors.transparent,
                selectedIconTheme: IconThemeData(size: 28),
                unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
                currentIndex: 2,
                onTap: (int i) {
                  this._selectTab(i);
                },
                // this will be set when a new tab is tapped
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications),
//                    title: new Container(height: 0.0),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.location_on),
//                    title: new Container(height: 0.0),
                  ),
                  BottomNavigationBarItem(
//                      title: new Container(height: 5.0),
                      icon: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          ),
                          boxShadow: [
                            BoxShadow(color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 40, offset: Offset(0, 15)),
                            BoxShadow(color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 13, offset: Offset(0, 3))
                          ],
                        ),
                        child: new Icon(Icons.home, color: Theme.of(context).primaryColor),
                      )),
                  BottomNavigationBarItem(
                    icon: new Icon(Icons.local_mall),
//                    title: new Container(height: 0.0),
                  ),
                  BottomNavigationBarItem(
                    icon: new Icon(Icons.favorite),
//                    title: new Container(height: 0.0),
                  ),
                ],
              ),

              drawer: DrawerWidget(),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: new IconButton(
                  icon: new Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  _con!.market?.name ?? '',
                  // "${refreshState.value}",
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.headline6!.merge(TextStyle(letterSpacing: 0)),
                ),
                actions: <Widget>[
                    refreshState.value
                        ? SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularLoadingWidget(height: 50),
                    )
                        :    ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor,),


                ],
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              body:SingleChildScrollView(
                controller: _con!.controllerList,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SearchBarWidget(),
                    ),
                    // if(_con.trendingProducts.length > 0)...{
                    //   ListTile(
                    //     dense: true,
                    //     contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    //     leading: Icon(
                    //       Icons.bookmark,
                    //       color: Theme.of(context).hintColor,
                    //     ),
                    //     title: Text(
                    //       S.of(context).featured_products,
                    //       style: Theme.of(context).textTheme.headline4,
                    //     ),
                    //     subtitle: Text(
                    //       S.of(context).clickOnTheProductToGetMoreDetailsAboutIt,
                    //       maxLines: 2,
                    //       style: Theme.of(context).textTheme.caption,
                    //     ),
                    //   ),
                    //   ProductsCarouselWidget(heroTag: 'menu_trending_product', productsList: _con.trendingProducts),
                    //
                    // },
                   ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      leading: Icon(
                        Icons.subject,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context)!.products,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      subtitle: Text(
                        S.of(context)!.clickOnTheProductToGetMoreDetailsAboutIt,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    _con!.categories!.isEmpty
                        ? SizedBox(height: 90)
                        : Container(
                      height: 90,
                      child: ListView(
                        primary: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: List.generate(_con!.categories!.length, (index) {
                          var _category = _con!.categories!.elementAt(index);
                          var _selected = _con!.selectedCategories!.contains(_category.id);
                          return Padding(
                            padding: const EdgeInsetsDirectional.only(start: 20),
                            child: RawChip(
                              elevation: 0,
                              label: Text(_category.name!),
                              labelStyle: _selected
                                  ? Theme.of(context).textTheme.bodyText2!.merge(TextStyle(color: Theme.of(context).primaryColor))
                                  : Theme.of(context).textTheme.bodyText2,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                              backgroundColor: Theme.of(context).focusColor.withOpacity(0.1),
                              selectedColor: Theme.of(context).accentColor,
                              selected: _selected,
                              //shape: StadiumBorder(side: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.05))),
                              showCheckmark: false,
                              avatar: (_category.id == '0')
                                  ? null
                                  : (_category.image!.url!.toLowerCase().endsWith('.svg')
                                  ? SvgPicture.network(
                                _category.image!.url!,
                                color: _selected ? Theme.of(context).primaryColor : Theme.of(context).accentColor,
                              )
                                  : CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: _category.image!.icon!,
                                placeholder: (context, url) => Image.asset(
                                  'assets/img/loading.gif',
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              )),
                              onSelected: (bool value) {
                                setState(() {
                                  if (_category.id == '0') {
                                    _con!.selectedCategories = ['0'];
                                  } else {
                                    _con!.selectedCategories!.removeWhere((element) => element == '0');
                                  }
                                  if (value) {
                                    _con!.selectedCategories!.add(_category.id!);
                                  } else {
                                    _con!.selectedCategories!.removeWhere((element) => element == _category.id);
                                  }
                                  _con!.selectCategory(_con!.selectedCategories!);
                                });
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    _con!.products!.isEmpty
                        ? CircularLoadingWidget(height: 250)
                        : ListView.separated(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _con!.products!.length<_con!.indexlist?_con!.products!.length:_con!.indexlist,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 10);
                      },
                      itemBuilder: (context, index) {
                        return ProductItemWidget(
                          heroTag: 'menu_list',
                          product: _con!.products!.elementAt(index),
                          refreshState: this.refreshState,
                        );
                      },
                    ),
                    _con!.loadingNextProducts ? CircularLoadingWidget(height: 150)
                        : Text("")
                  ],
                ),
              )

          );
        }
    );

  }
}
