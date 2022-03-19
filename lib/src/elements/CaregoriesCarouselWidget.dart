import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../elements/CategoriesCarouselItemWidget.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/category.dart';

// ignore: must_be_immutable
class CategoriesCarouselWidget extends StatelessWidget {
  List<Category>? categories;

  CategoriesCarouselWidget({Key? key, this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return this.categories!.isEmpty
        ? CircularLoadingWidget(height: 150)
        : Container(
            // height: 150,
            padding: EdgeInsets.symmetric(vertical: 10),
            child:
//             new StaggeredGridView.countBuilder(
//               primary: false,
//               shrinkWrap: true,
//               crossAxisCount: 4,
//               itemCount: this.categories.length,
//               itemBuilder: (BuildContext context, int index) {
//                 double _marginLeft = 0;
//                 (index == 0) ? _marginLeft = 20 : _marginLeft = 0;
//                 return new CategoriesCarouselItemWidget(
//                   marginLeft: _marginLeft,
//                   category: this.categories.elementAt(index),
//                 );
//               },
// //                  staggeredTileBuilder: (int index) => new StaggeredTile.fit(index % 2 == 0 ? 1 : 2),
//               staggeredTileBuilder: (int index) => new StaggeredTile.fit(MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4),
//               mainAxisSpacing: 15.0,
//               crossAxisSpacing: 15.0,
//             )

    ////////////////////////////////////////////////////////
      GridView.count(
        scrollDirection: Axis.vertical,
        childAspectRatio: 0.8244688644,

        shrinkWrap: true,
        primary: false,
        crossAxisSpacing: 10,
        mainAxisSpacing: 20,
        padding: EdgeInsets.symmetric(horizontal: 20),
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
        // Generate 100 widgets that display their index in the List.
        children: List.generate(this.categories!.length, (index) {
          double _marginLeft = 0;
          (index == 0) ? _marginLeft = 20 : _marginLeft = 0;
          return   new CategoriesCarouselItemWidget1(
            marginLeft: _marginLeft,
            category: this.categories!.elementAt(index),
            heroTag: "heroTag $index",
          );
        }),
      ),

    );
  }
}
