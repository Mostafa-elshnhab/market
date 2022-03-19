import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/category_controller.dart';
import '../elements/AddToCartAlertDialog.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/FilterWidget.dart';
import '../elements/ProductGridItemWidget.dart';
import '../elements/ProductListItemWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class CategoryWidget extends StatefulWidget {
  final RouteArgument? routeArgument;
  CategoryWidget({Key? key, this.routeArgument, }) : super(key: key);

  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends StateMVC<CategoryWidget> {
  // TODO add layout in configuration file
  String layout = 'grid';

  CategoryController? _con;
  _CategoryWidgetState() : super(CategoryController()) {
    _con = controller as CategoryController?;
  }

  @override
  void initState() {
    _con!.listenForProductsByCategory(id: widget.routeArgument!.id);
    _con!.listenForCategory(id: widget.routeArgument!.id);
    _con!.listenForCart();
    super.initState();
  }

  void _selectTab(int tabItem) {
    Navigator.of(context).pushNamed('/Pages', arguments: tabItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con!.scaffoldKey,
      drawer: DrawerWidget(),
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
//            title: new Container(height: 0.0),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
//            title: new Container(height: 0.0),
          ),
          BottomNavigationBarItem(
//              title: new Container(height: 5.0),
              icon: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).accentColor.withOpacity(0.4),
                        blurRadius: 40,
                        offset: Offset(0, 15)),
                    BoxShadow(
                        color: Theme.of(context).accentColor.withOpacity(0.4),
                        blurRadius: 13,
                        offset: Offset(0, 3))
                  ],
                ),
                child:
                    new Icon(Icons.home, color: Theme.of(context).primaryColor),
              )),
          BottomNavigationBarItem(
            icon: new Icon(Icons.local_mall),
//            title: new Container(height: 0.0),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.favorite),
//            title: new Container(height: 0.0),
          ),
        ],
      ),
      endDrawer: FilterWidget(onFilter: (filter) {
        Navigator.of(context).pushReplacementNamed('/SubcategoriesWidget',
            arguments: RouteArgument(id: widget.routeArgument!.id));
      }, ),
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => _con!.scaffoldKey?.currentState?.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context)!.category,
          style: Theme.of(context)
              .textTheme
              .headline6!
              .merge(TextStyle(letterSpacing: 0)),
        ),
        actions: <Widget>[
          _con!.loadCart
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22.5, vertical: 15),
                  child: SizedBox(
                    width: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : ShoppingCartButtonWidget(
                  iconColor: Theme.of(context).hintColor,
                  labelColor: Theme.of(context).accentColor, ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con!.refreshCategory,
        child: SingleChildScrollView(
            controller: _con!.controllerList,

            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBarWidget(onClickFilter: (filter) {
                _con!.scaffoldKey?.currentState?.openEndDrawer();
              }),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: new Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    leading: Icon(
                      Icons.category,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      _con!.category?.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            setState(() {
                              this.layout = 'list';
                            });
                          },
                          icon: Icon(
                            Icons.format_list_bulleted,
                            color: this.layout == 'list'
                                ? Theme.of(context).accentColor
                                : Theme.of(context).focusColor,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              this.layout = 'grid';
                            });
                          },
                          icon: Icon(
                            Icons.apps,
                            color: this.layout == 'grid'
                                ? Theme.of(context).accentColor
                                : Theme.of(context).focusColor,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            this.layout == 'list'
                ?  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),

                child: _con!.products.isEmpty
                        ? CircularLoadingWidget(height: 500)
                        : Offstage(
                            offstage: this.layout != 'list',
                            child: ListView.separated(
                              scrollDirection: Axis.vertical,
                               physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              primary: false,
                              itemCount: _con!.products.length < _con!.indexlist
                                  ? _con!.products.length
                                  : _con!.indexlist,
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 10);
                              },
                              itemBuilder: (context, index) {
                                return ProductListItemWidget(
                                  heroTag: 'favorites_list',
                                  product: _con!.products.elementAt(index),
                                );
                              },
                            ),
                          ))
                :  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),

                child: _con!.products.isEmpty
                        ? CircularLoadingWidget(height: 500)
                        : Offstage(
                            offstage: this.layout != 'grid',
                            child: GridView.count(
                              physics: const NeverScrollableScrollPhysics(),

                              scrollDirection: Axis.vertical,
                              childAspectRatio:0.55,

                              shrinkWrap: true,
                              primary: false,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 20,
                              padding: EdgeInsets.symmetric(horizontal: 20),

                              // Create a grid with 2 columns. If you change the scrollDirection to
                              // horizontal, this produces 2 rows.
                              crossAxisCount: MediaQuery.of(context).size.width>480 ?(MediaQuery.of(context).size.width / 200).round():2,

                              // Generate 100 widgets that display their index in the List.
                              children: List.generate(
                                  _con!.products.length < _con!.indexlist
                                      ? _con!.products.length
                                      : _con!.indexlist, (index) {
                                return ProductGridItemWidget(
                                    heroTag: 'category_grid',
                                    product: _con!.products.elementAt(index),
                                    onPressed: () {
                                      if (currentUser.value.apiToken == null) {
                                        Navigator.of(context)
                                            .pushNamed('/LoginPhone');
                                      } else {
                                        if (true) {
                                          _con!.addToCart(
                                              _con!.products.elementAt(index));
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              // return object of type Dialog
                                              return AddToCartAlertDialogWidget(
                                                  oldProduct: _con!.carts
                                                      .elementAt(0)
                                                      ?.product,
                                                  newProduct: _con!.products
                                                      .elementAt(index),
                                                  onPressed: (product,
                                                      {reset: true}) {
                                                    return _con!.addToCart(
                                                        _con!.products
                                                            .elementAt(index),
                                                        reset: true);
                                                  });
                                            },
                                          );
                                        }
                                      }
                                    });
                              }),
                            ),
                          )),
            // _con.loadingNextProducts.value ? CircularLoadingWidget(height: 150)
            //     : Text(""),
            ValueListenableBuilder(
                valueListenable: _con!.loadingNextProducts!,
                builder: (context, bool val, _) {
                  return val ? CircularLoadingWidget(height: 50) : Text("");
                })
          ],
        )
      )
      ),
    );
  }
}
