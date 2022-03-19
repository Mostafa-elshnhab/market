import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/product.dart';
import '../models/route_argument.dart';

class ProductGridItemWidget extends StatefulWidget {
  final String? heroTag;
  final Product? product;
  final VoidCallback? onPressed;

  ProductGridItemWidget({Key? key, this.heroTag, this.product, this.onPressed})
      : super(key: key);

  @override
  _ProductGridItemWidgetState createState() => _ProductGridItemWidgetState();
}

class _ProductGridItemWidgetState extends State<ProductGridItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2)),
          ],
        ),
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Theme.of(context).accentColor.withOpacity(0.08),
          onTap: () {
            Navigator.of(context).pushNamed('/Product',
                arguments: new RouteArgument(
                    heroTag: this.widget.heroTag, id: this.widget.product!.id));
          },
          child: Stack(
            alignment: AlignmentDirectional.topEnd,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[


                  if (widget.product!.packageItemsCount != null &&
                      widget.product!.packageItemsCount != "null" &&
                      widget.product!.packageItemsCount != "" &&
                      int.parse(widget.product!.packageItemsCount!) <=
                          0) ...{
                    SizedBox(
                         height: 180,
                  child: Hero(
                  tag: widget.heroTag! + widget.product!.id!,
                  child:  Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(
                                  this.widget.product!.image!.url!),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(5),
                        ),

                        child: ClipRRect(
                          // make sure we apply clip it properly
                          child: BackdropFilter(
                            filter:
                            ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                            child: Container(
                                alignment: Alignment.center,
                                color: Colors.grey.withOpacity(0.1),
                                child: Text(
                                  S.of(context)!.QuantityIsOut,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ),
                        ),
                        // child: new BackdropFilter(
                        //   filter: new ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                        //   child: new Container(
                        //     decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                        //   ),
                        // ),
                      ),
                    )
                  ]
                  )))
                  }else...{
                    SizedBox(
                      // width: 180,
                      height: 180,
                      child:   CachedNetworkImage(
                        fit: BoxFit.cover,

                        alignment: Alignment.center,
                        imageUrl:  this.widget.product!.image!.url!,
                        placeholder: (context, url) => Image.asset(
                          'assets/img/loading.gif',
                          fit: BoxFit.cover,
                          // width: double.infinity,
                          height: 180,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),

                  },
                  // Expanded(
                  //   child: Hero(
                  //       tag: widget.heroTag + widget.product.id,
                  //       child: new Stack(
                  //         children: [
                  //           if (widget.product.packageItemsCount != null &&
                  //               widget.product.packageItemsCount != "" &&
                  //               int.parse(widget.product.packageItemsCount) <=
                  //                   0) ...{
                  //             Padding(
                  //               padding: EdgeInsets.all(10.0),
                  //               child: Container(
                  //               decoration: BoxDecoration(
                  //                 image: DecorationImage(
                  //                     image: NetworkImage(
                  //                         this.widget.product.image.url),
                  //                     fit: BoxFit.cover),
                  //                 borderRadius: BorderRadius.circular(5),
                  //               ),
                  //
                  //               child: ClipRRect(
                  //                 // make sure we apply clip it properly
                  //                 child: BackdropFilter(
                  //                   filter:
                  //                       ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  //                   child: Container(
                  //                       alignment: Alignment.center,
                  //                       color: Colors.grey.withOpacity(0.1),
                  //                       child: Text(
                  //                         S.of(context).QuantityIsOut,
                  //                         style: TextStyle(
                  //                             color: Colors.red,
                  //                             fontSize: 17,
                  //                             fontWeight: FontWeight.bold),
                  //                         overflow: TextOverflow.ellipsis,
                  //                       )),
                  //                 ),
                  //               ),
                  //               // child: new BackdropFilter(
                  //               //   filter: new ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                  //               //   child: new Container(
                  //               //     decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                  //               //   ),
                  //               // ),
                  //             ),
                  //                 )
                  //           } else ...{
                  //             Padding(
                  //               padding: EdgeInsets.all(10.0),
                  //               child: Container(
                  //                 decoration: BoxDecoration(
                  //                   image: DecorationImage(
                  //                       image: NetworkImage(
                  //                           this.widget.product.image.url),
                  //                       fit: BoxFit.cover),
                  //                   borderRadius: BorderRadius.circular(5),
                  //                 ),
                  //                 // child: CachedNetworkImage(
                  //                 //   fit: BoxFit.cover,
                  //                 //   imageUrl: this.widget.product.image.url,
                  //                 //   placeholder: (context, url) => Image.asset(
                  //                 //     'assets/img/loading.gif',
                  //                 //     fit: BoxFit.cover,
                  //                 //     width: double.infinity,
                  //                 //     height: 150,
                  //                 //   ),
                  //                 //   errorWidget: (context, url, error) => Icon(Icons.error),
                  //                 // ),
                  //               ),
                  //             ),
                  //             // Container(
                  //             //   margin: EdgeInsets.all(10),
                  //             //   width: 40,
                  //             //   height: 40,
                  //             //   child: FlatButton(
                  //             //     padding: EdgeInsets.all(0),
                  //             //     onPressed: () {
                  //             //       widget.onPressed();
                  //             //     },
                  //             //     child: Icon(
                  //             //       Icons.shopping_cart,
                  //             //       color: Theme.of(context).primaryColor,
                  //             //       size: 24,
                  //             //     ),
                  //             //     color: Theme.of(context)
                  //             //         .accentColor
                  //             //         .withOpacity(0.9),
                  //             //     shape: StadiumBorder(),
                  //             //   ),
                  //             // )
                  //           },
                  //         ],
                  //       )),
                  // ),
                  SizedBox(height: 5),
                   Expanded(child: AutoSizeText(
                    widget.product!.name! +
                        " " +
                        (widget.product!.unit! == null
                            ? ""
                            : widget.product!.unit!),
                    style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(fontSize: 20)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),),
                  SizedBox(height: 2),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5,
                    children: <Widget>[
                      Helper.getPrice(widget.product!.price!, context,
                          style: Theme.of(context).textTheme.headline3!,
                          zeroPlaceholder: 'Free'),
                      widget.product!.discountPrice! > 0
                          ? Helper.getPrice(
                              widget.product!.discountPrice!, context,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  !.merge(TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.red)))
                          : SizedBox(height: 0),
                    ],
                  ),
                   Padding(
                    padding: EdgeInsets.all(10),
                    child:  Center(
                      child: OutlineButton(
                        onPressed: () {
                          widget.onPressed!();
                        },
                        shape:  RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart,
                              color: Theme.of(context).accentColor,
                              size: 24,
                            ),
                            SizedBox(width: 10,),
                            new Text("أضف للسلة",style: new TextStyle(fontSize: 13,color:  Theme.of(context).accentColor),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ));
  }
}
