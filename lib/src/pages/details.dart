import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../controllers/market_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/GalleryCarouselWidget.dart';
import '../elements/ProductItemWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/ShoppingCartFloatButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';

class DetailsWidget extends StatefulWidget {
  final RouteArgument? routeArgument;
  DetailsWidget({Key? key, this.routeArgument,}) : super(key: key);

  @override
  _DetailsWidgetState createState() {
    return _DetailsWidgetState();
  }
}

class _DetailsWidgetState extends StateMVC<DetailsWidget> {
  MarketController? _con;

  _DetailsWidgetState() : super(MarketController()) {
    _con = controller as MarketController?;
  }

  @override
  void initState() {
    _con!.listenForMarket(id: widget.routeArgument!.id);
    _con!.listenForGalleries(widget.routeArgument!.id!);
    _con!.listenForFeaturedProducts(widget.routeArgument!.id!);
    _con!.listenForMarketReviews(id: widget.routeArgument!.id);
    super.initState();
  }
  void _selectTab(int tabItem) {
    Navigator.of(context).pushNamed('/Pages', arguments: tabItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con!.scaffoldKey,
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: () {
        //     Navigator.of(context).pushNamed('/Menu', arguments: new RouteArgument(id: widget.routeArgument.id));
        //   },
        //   isExtended: true,
        //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //   icon: Icon(
        //     Icons.shopping_basket,
        //     color: Theme.of(context).primaryColor,
        //   ),
        //   label: Text(
        //     S.of(context).shopping,
        //     style: TextStyle(color: Theme.of(context).primaryColor),
        //   ),
        // ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
//              title: new Container(height: 0.0),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
//              title: new Container(height: 0.0),
            ),
            BottomNavigationBarItem(
//                title: new Container(height: 5.0),
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
//              title: new Container(height: 0.0),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.favorite),
//              title: new Container(height: 0.0),
            ),
          ],
        ),
        body:
        RefreshIndicator(
          onRefresh: _con!.refreshMarket,
          child: _con!.market == null
              ? CircularLoadingWidget(height: 500)
              : Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CustomScrollView(
                primary: true,
                shrinkWrap: false,
                slivers: <Widget>[
                  SliverAppBar(
                    backgroundColor: Theme.of(context).accentColor.withOpacity(0.9),
                    expandedHeight: 300,
                    elevation: 0,
                    iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Hero(
                        tag: (widget.routeArgument?.heroTag ?? '') + _con!.market!.id!,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: _con!.market!.image!.url!,
                          placeholder: (context, url) => Image.asset(
                            'assets/img/loading.gif',
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Wrap(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20, left: 20, bottom: 10, top: 25),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  _con!.market?.name ?? '',
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  maxLines: 2,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                              ),
                              SizedBox(
                                height: 32,
                                child: Chip(
                                  padding: EdgeInsets.all(0),
                                  label: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(_con!.market!.rate!,
                                          style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(color: Theme.of(context).primaryColor))),
                                      Icon(
                                        Icons.star_border,
                                        color: Theme.of(context).primaryColor,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Theme.of(context).accentColor.withOpacity(0.9),
                                  shape: StadiumBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(width: 20),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(color: _con!.market!.closed! ? Colors.grey : Colors.green, borderRadius: BorderRadius.circular(24)),
                              child: _con!.market!.closed!
                                  ? Text(
                                S.of(context)!.closed,
                                style: Theme.of(context).textTheme.caption!.merge(TextStyle(color: Theme.of(context).primaryColor)),
                              )
                                  : Text(
                                S.of(context)!.open,
                                style: Theme.of(context).textTheme.caption!.merge(TextStyle(color: Theme.of(context).primaryColor)),
                              ),
                            ),
                            SizedBox(width: 10),

                            Expanded(child: SizedBox(height: 0)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                  color: Helper.canDelivery(_con!.market!) ? Colors.green : Colors.grey, borderRadius: BorderRadius.circular(24)),
                              child: Text(
                                Helper.getDistance(_con!.market!.distance!, Helper.of(context).trans(setting.value.distanceUnit!)),
                                style: Theme.of(context).textTheme.caption!.merge(TextStyle(color: Theme.of(context).primaryColor)),
                              ),
                            ),
                            SizedBox(width: 20),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Helper.applyHtml(context, _con!.market!.description!),
                        ),
                        ImageThumbCarouselWidget(galleriesList: _con!.galleries),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            leading: Icon(
                              Icons.stars,
                              color: Theme.of(context).hintColor,
                            ),
                            title: Text(
                              S.of(context)!.information,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        //   child: Helper.applyHtml(context, _con.market.information),
                        // ),

                        if (_con!.market!.phone != null)...{
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            color: Theme.of(context).primaryColor,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    '${_con!.market!.phone}',
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                SizedBox(width: 10),
                                SizedBox(
                                  width: 42,
                                  height: 42,
                                  child: FlatButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {
                                      launch("tel:${_con!.market!.phone}");
                                    },
                                    child: Icon(
                                      Icons.call,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                    color: Theme.of(context).accentColor.withOpacity(0.9),
                                    shape: StadiumBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        },
                        if (_con!.market!.mobile != null)...{
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            color: Theme.of(context).primaryColor,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    '${_con!.market!.mobile}',
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                SizedBox(width: 10),
                                SizedBox(
                                  width: 42,
                                  height: 42,
                                  child: FlatButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {
                                      launch("tel:${_con!.market!.mobile}");
                                    },
                                    child: Icon(
                                      Icons.call,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                    color: Theme.of(context).accentColor.withOpacity(0.9),
                                    shape: StadiumBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        },
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          color: Theme.of(context).primaryColor,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  _con!.market!.address ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),

                            ],
                          ),
                        ),


                        // _con.featuredProducts.isEmpty
                        //     ? SizedBox(height: 0)
                        //     : Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 20),
                        //   child: ListTile(
                        //     dense: true,
                        //     contentPadding: EdgeInsets.symmetric(vertical: 0),
                        //     leading: Icon(
                        //       Icons.shopping_basket,
                        //       color: Theme.of(context).hintColor,
                        //     ),
                        //     title: Text(
                        //       S.of(context).featured_products,
                        //       style: Theme.of(context).textTheme.headline4,
                        //     ),
                        //   ),
                        // ),
                        // _con.featuredProducts.isEmpty
                        //     ? SizedBox(height: 0)
                        //     : ListView.separated(
                        //   padding: EdgeInsets.symmetric(vertical: 10),
                        //   scrollDirection: Axis.vertical,
                        //   shrinkWrap: true,
                        //   primary: false,
                        //   itemCount: _con.featuredProducts.length,
                        //   separatorBuilder: (context, index) {
                        //     return SizedBox(height: 10);
                        //   },
                        //   itemBuilder: (context, index) {
                        //     return ProductItemWidget(
                        //       heroTag: 'details_featured_product',
                        //       product: _con.featuredProducts.elementAt(index),
                        //     );
                        //   },
                        // ),
                        SizedBox(height: 100),
                        // _con.reviews.isEmpty
                        //     ? SizedBox(height: 5)
                        //     : Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        //   child: ListTile(
                        //     dense: true,
                        //     contentPadding: EdgeInsets.symmetric(vertical: 0),
                        //     leading: Icon(
                        //       Icons.recent_actors,
                        //       color: Theme.of(context).hintColor,
                        //     ),
                        //     title: Text(
                        //       S.of(context).what_they_say,
                        //       style: Theme.of(context).textTheme.headline4,
                        //     ),
                        //   ),
                        // ),
                        // _con.reviews.isEmpty
                        //     ? SizedBox(height: 5)
                        //     : Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        //   child: ReviewsListWidget(reviewsList: _con.reviews),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 32,
                right: 20,
                child: ShoppingCartFloatButtonWidget(
                  iconColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).hintColor,
                  routeArgument: RouteArgument(param: '/Details', id: widget.routeArgument!.id),
                ),
              ),
            ],
          ),
        )
    );
  }
}
