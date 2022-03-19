import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/search_controller.dart';
import '../elements/CardWidget.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/ProductItemWidget.dart';
import '../models/route_argument.dart';
import 'DrawerWidget.dart';
import 'ShoppingCartButtonWidget.dart';

class SearchResultWidget extends StatefulWidget {
  final String? heroTag;

  SearchResultWidget({Key? key, this.heroTag}) : super(key: key);

  @override
  _SearchResultWidgetState createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends StateMVC<SearchResultWidget> {
  SearchController? _con;
  ValueNotifier<bool> refreshState = new ValueNotifier(false);

  _SearchResultWidgetState() : super(SearchController()) {
    _con = controller as SearchController?;
  }

  @override
  void initState() {
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
//                    label: new Container(height: 0.0),
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
                title: Text(S.of(context)!.search),
                actions: <Widget>[
                  refreshState.value
                      ? SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularLoadingWidget(height: 50),
                  )
                      :            ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).colorScheme.secondary,),


                ],
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              body:Container(
      color: Theme
          .of(context)
          .scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 0),
              trailing: IconButton(
                icon: Icon(Icons.close),
                color: Theme
                    .of(context)
                    .hintColor,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                S
                    .of(context)!
                    .search,
                style: Theme
                    .of(context)
                    .textTheme
                    .headline4,
              ),
              subtitle: Text(
                S
                    .of(context)!
                    .ordered_by_nearby_first,
                style: Theme
                    .of(context)
                    .textTheme
                    .caption,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onSubmitted: (text) async {
                await _con!.refreshSearch(text);
                _con!.saveSearch(text);
              },
              autofocus: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(12),
                hintText: S
                    .of(context)!
                    .search_for_markets_or_products,
                hintStyle: Theme
                    .of(context)
                    .textTheme
                    .caption!
                    .merge(TextStyle(fontSize: 14)),
                prefixIcon: Icon(Icons.search, color: Theme
                    .of(context)
                    .accentColor),
                border: OutlineInputBorder(borderSide: BorderSide(color: Theme
                    .of(context)
                    .focusColor
                    .withOpacity(0.1))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme
                        .of(context)
                        .focusColor
                        .withOpacity(0.3))),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme
                        .of(context)
                        .focusColor
                        .withOpacity(0.1))),
              ),
            ),
          ),
          _con!.markets.isEmpty && _con!.products.isEmpty
              ? Expanded(
              child:CircularLoadingWidget(height: 288))
              : Expanded(
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    title: Text(
                      S
                          .of(context)!
                          .products_results,
                      style: Theme
                          .of(context)
                          .textTheme
                          .subtitle1,
                    ),
                  ),
                ),
                ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: _con!.products.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    return ProductItemWidget(
                      heroTag: 'search_list',
                      product: _con!.products.elementAt(index),
                      refreshState: this.refreshState,

                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    title: Text(
                      S
                          .of(context)!
                          .markets_results,
                      style: Theme
                          .of(context)
                          .textTheme
                          .subtitle1,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: _con!.markets.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/Details',
                            arguments: RouteArgument(
                              id: _con!.markets
                                  .elementAt(index)
                                  .id,
                              heroTag: widget.heroTag,
                            ));
                      },
                      child: CardWidget(market: _con!.markets.elementAt(index),
                          heroTag: widget.heroTag),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    )
          );
  });
  }
}
