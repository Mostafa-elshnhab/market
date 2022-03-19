import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/product.dart';
import '../models/route_argument.dart';

// ignore: must_be_immutable
class ProductListItemWidget extends StatelessWidget {
  String? heroTag;
  Product? product;

  ProductListItemWidget({Key? key, this.heroTag, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        Navigator.of(context).pushNamed('/Product', arguments: new RouteArgument(heroTag: this.heroTag, id: this.product!.id));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(image: NetworkImage(product!.image!.thumb!), fit: BoxFit.cover),
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
                          this.product!.name! + " " +  (this.product!.unit! == null ? "":this.product!.unit!),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 5,
                          children: <Widget>[
                            product!.discountPrice! > 0
                                ? Helper.getPrice(product!.discountPrice!, context,
                                style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(decoration: TextDecoration.lineThrough,color: Colors.red)))
                                : SizedBox(height: 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  // Helper.getPrice(product.price, context, style: Theme.of(context).textTheme.headline4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5,
                    children: <Widget>[
                      Helper.getPrice(product!.price!, context, style: Theme.of(context).textTheme.headline4!, zeroPlaceholder: 'Free'),

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
