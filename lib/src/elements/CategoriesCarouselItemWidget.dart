import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/category.dart';
import '../models/route_argument.dart';

// ignore: must_be_immutable
class CategoriesCarouselItemWidget extends StatelessWidget {
  double? marginLeft;
  Category? category;
  CategoriesCarouselItemWidget({Key? key, this.marginLeft, this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor.withOpacity(0.08),
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.of(context).pushNamed('/SubcategoriesWidget', arguments: RouteArgument(id: category!.id!));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Hero(
            tag: category!.id!,
            child: Container(
              // margin: EdgeInsetsDirectional.only(start: this.marginLeft, end: 20),
              // width: double.infinity,
              // height: 120,
              // decoration: BoxDecoration(
              //     color: Theme.of(context).primaryColor,
              //     borderRadius: BorderRadius.all(Radius.circular(5)),
              //     boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.2), offset: Offset(0, 2), blurRadius: 7.0)]),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: category!.image!.url!.toLowerCase().endsWith('.svg')
                    ? SvgPicture.network(
                        category!.image!.url!,
                  width: double.infinity,
                  color: Theme.of(context).accentColor,
                      )
                    : CachedNetworkImage(
                        fit: BoxFit.fill,
                  width: double.infinity,
                  imageUrl: category!.image!.icon!,
                        placeholder: (context, url) => Image.asset(

                          'assets/img/loading.gif',
                          fit: BoxFit.cover,
                          width: double.infinity,

                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Container(
            margin: EdgeInsetsDirectional.only(start: this.marginLeft!, end: 20),
            child: Text(
              category!.name!,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ],
      ),
    );
  }
}





//////////////////////////////////////////////////////


 class CategoriesCarouselItemWidget1 extends StatelessWidget {
  double? marginLeft;
  Category? category;
  final String? heroTag;

  CategoriesCarouselItemWidget1({Key? key, this.marginLeft, this.category,this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      //   decoration: BoxDecoration(
      //     color: Theme.of(context).primaryColor.withOpacity(0.9),
      //     boxShadow: [
      //       BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
      //     ],
      //   ),
        child:InkWell(
          highlightColor: Colors.transparent,
          splashColor: Theme.of(context).accentColor.withOpacity(0.08),
          onTap: () {
            Navigator.of(context).pushNamed('/SubcategoriesWidget', arguments: RouteArgument(id: category!.id!));

          },
          child: Stack(
            alignment: AlignmentDirectional.topEnd,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: <Widget>[
                  SizedBox(
                    height: 160,
                    child:   CachedNetworkImage(
                      fit: BoxFit.fill,
                      alignment: Alignment.center,
                      width: double.infinity,

                      imageUrl: this.category!.image!.url!,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        // width: double.infinity,
                        height: 160,
                        width: 160,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),


                  SizedBox(height: 5),


                  SizedBox(height: 5),
                  Container(
                    margin: EdgeInsetsDirectional.only(start: this.marginLeft!, end: 20),
                    child: AutoSizeText(
                      category!.name!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                  SizedBox(height: 2),

                ],
              ),

            ],
          ),
        )
    );

    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Theme.of(context).accentColor.withOpacity(0.08),
      onTap: () {
        Navigator.of(context).pushNamed('/SubcategoriesWidget', arguments: RouteArgument(id: category!.id!));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Hero(
            tag: category!.id!,
            child: Container(
              // margin: EdgeInsetsDirectional.only(start: this.marginLeft, end: 20),
              // width: double.infinity,
              // height: 120,
              // decoration: BoxDecoration(
              //     color: Theme.of(context).primaryColor,
              //     borderRadius: BorderRadius.all(Radius.circular(5)),
              //     boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.2), offset: Offset(0, 2), blurRadius: 7.0)]),
              child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: category!.image!.url!.toLowerCase().endsWith('.svg')
                      ? SvgPicture.network(
                    category!.image!.url!,
                    width: double.infinity,
                    color: Theme.of(context).accentColor,
                  )
                      : Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(image: NetworkImage(category!.image!.url!), fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  )

              ),
            ),
          ),
          // SizedBox(height: 5),
          // Container(
          //   margin: EdgeInsetsDirectional.only(start: this.marginLeft, end: 20),
          //   child: Text(
          //     category.name,
          //     overflow: TextOverflow.ellipsis,
          //     style: Theme.of(context).textTheme.bodyText2,
          //   ),
          // ),
        ],
      ),
    );
  }
}
