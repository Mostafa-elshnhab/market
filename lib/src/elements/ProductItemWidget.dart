import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/product_controller.dart';
import '../helpers/helper.dart';
import '../models/product.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';
import 'AddToCartAlertDialog.dart';

class ProductItemWidget extends StatefulWidget {
  final String? heroTag;
  final Product? product;

  final ValueNotifier<bool>? refreshState;
  ProductItemWidget({Key? key, this.product, this.heroTag, this.refreshState}) : super(key: key);

  @override
  _ProductItemState createState() {
    return _ProductItemState(product: this.product, heroTag: this.heroTag,refreshState: this.refreshState,);
  }
}
class _ProductItemState extends StateMVC<ProductItemWidget> {
  ProductController? _con;
  final String? heroTag;
  final Product? product;
  final ValueNotifier<bool>? refreshState;
  _ProductItemState({Key? key, this.product,this.heroTag, this.refreshState}) : super(ProductController()) {
    _con = controller! as ProductController?;
    _con!.product = this.product;
  }

  @override
  Widget build(BuildContext context) {
    // return Text("data");

    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        Navigator.of(context).pushNamed('/Product', arguments: RouteArgument(id: product!.id, heroTag: this.heroTag));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: heroTag! + product!.id!,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: CachedNetworkImage(
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  imageUrl: product!.image!.url!,
                  placeholder: (context, url) => Image.asset(
                    'assets/img/loading.gif',
                    fit: BoxFit.cover,
                    height: 60,
                    width: 60,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          product!.name!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              onPressed: () {
                                _con!.decrementQuantity();
                              },
                              iconSize: 30,
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                              icon: Icon(Icons.remove_circle_outline),
                              color: Theme.of(context).hintColor,
                            ),
                            Text(_con!.quantity.toString(), style: Theme.of(context).textTheme.subtitle1),
                            IconButton(
                              onPressed: () {
                                _con!.incrementQuantity();
                              },
                              iconSize: 30,
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                              icon: Icon(Icons.add_circle_outline),
                              color: Theme.of(context).hintColor,
                            )
                          ],
                        ),
                        SizedBox(
                          // width: MediaQuery.of(context).size.width - 110,
                          child: FlatButton(
                            onPressed: () {
                              if (currentUser.value.apiToken == null) {
                                Navigator.of(context).pushNamed("/LoginPhone");
                              } else {
                                if (true) {
                                  _con!.addToCart(product!).then( (v){
                                    setState(() {
                                      if (refreshState != null && refreshState!.value != null){
                                        refreshState!.value = true;

                                      }
                                    });
                                  });
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // return object of type Dialog
                                      return AddToCartAlertDialogWidget(
                                          oldProduct: _con!.carts.elementAt(0).product,
                                          newProduct: _con!.product,
                                          onPressed: (product, {reset: true})async {
                                            return _con!.addToCart(_con!.product!, reset: true,);
                                          });
                                    },
                                  );
                                }
                              }
                            },
                            color: Theme.of(context).accentColor,
                            shape: StadiumBorder(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                S.of(context)!.add_to_cart,
                                textAlign: TextAlign.start,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: Helper.getStarsList(product!.getRate()),
                        ),
                        Text(
                          product!.options!.map((e) => e.name).toList().join(', '),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Helper.getPrice(
                        product!.price!,
                        context,
                        style: Theme.of(context).textTheme.headline4!,
                      ),
                      product!.discountPrice! > 0
                          ? Helper.getPrice(product!.discountPrice!, context,
                          style: Theme.of(context).textTheme.bodyText2!.merge(TextStyle(decoration: TextDecoration.lineThrough)))
                          : SizedBox(height: 0),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
