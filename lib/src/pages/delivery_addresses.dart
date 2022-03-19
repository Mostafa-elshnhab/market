import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart' as geocoder;
 import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/delivery_addresses_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DeliveryAddressDialog.dart';
import '../elements/DeliveryAddressesItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';

class DeliveryAddressesWidget extends StatefulWidget {
  final RouteArgument? routeArgument;
  DeliveryAddressesWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _DeliveryAddressesWidgetState createState() =>
      _DeliveryAddressesWidgetState();
}

class _DeliveryAddressesWidgetState extends StateMVC<DeliveryAddressesWidget> {
  DeliveryAddressesController? _con;
  PaymentMethodList? list;

  _DeliveryAddressesWidgetState() : super(DeliveryAddressesController()) {
    _con = controller as DeliveryAddressesController?;
  }

  @override
  Widget build(BuildContext context) {
    list =  PaymentMethodList(context);
    return Scaffold(
      key: _con!.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context)!.delivery_addresses,
          style: Theme.of(context)
              .textTheme
              .headline6!
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
           ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).accentColor,),
        ],
      ),
      floatingActionButton:
          // _con.cart != null && _con.cart.product.market.availableForDelivery
          //     ?
          FloatingActionButton(
                  onPressed: () async {
                    add_address();
                    //setState(() => _pickedLocation = result);
                  },
                  backgroundColor: Theme.of(context).accentColor,
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).primaryColor,
                  ))
              // : SizedBox(height: 0)
      ,
      body: RefreshIndicator(
        onRefresh: _con!.refreshAddresses,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(
                    Icons.map,
                    color: Theme.of(context).hintColor,
                  ),
                  title: Text(
                    S.of(context)!.delivery_addresses,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  subtitle: Text(
                   (_con!.load== false && _con!.addresses!.length == 0)?"يرجى اضافة عنوان في المملكة العربية السعودية فقط":S
                        .of(context)!
                        .long_press_to_edit_item_swipe_item_to_delete_it,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
              _con!.load
                  ? CircularLoadingWidget(height: 250)
                  : _con!.addresses!.length == 0?
                  Center(child:  RaisedButton(
                    onPressed: () {
                      add_address();
                    },
                    child: Text(
                      S.of(context)!.add,
                      style: new TextStyle(color: Colors.white),
                    ),
                    color: Theme.of(context).accentColor,
                  ),)
              :ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _con!.addresses!.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 15);
                      },
                      itemBuilder: (context, index) {
                        // return Text(_con.addresses.elementAt(index).address);
                        return  Container(
                          child:  Row(
                            children: [
                               IconButton(
                                  icon: new Icon(Icons.edit),
                                  onPressed: () {
                                    DeliveryAddressDialog(
                                      context: context,
                                      address: _con!.addresses!.elementAt(index),
                                      onChanged: (Address _address) {
                                        _con!.updateAddress(_address);
                                      },
                                    );
                                  }),
                               Expanded(child: DeliveryAddressesItemWidget(
                                address: _con!.addresses!.elementAt(index),
                                onPressed: (Address _address) {
                                  _con
                                      !.changeDeliveryAddress(
                                      _con!.addresses!.elementAt(index))
                                      .then((value) {  Navigator.of(context).pushNamed('/Pages', arguments: 2);});

                                },
                                onLongPress: (Address _address) {
                                  DeliveryAddressDialog(
                                    context: context,
                                    address: _address,
                                    onChanged: (Address _address) {
                                      _con!.updateAddress(_address);
                                    },
                                  );
                                },
                                onDismissed: (Address? _address) {
                                  _con!.removeDeliveryAddress(_address!,);
                                },
                              ))
                            ],
                          ),
                        );
                        // return DeliveryAddressesItemWidget(
                        //   address: _con.addresses.elementAt(index),
                        //   onPressed: (Address _address) {
                        //     _con
                        //         .changeDeliveryAddress(
                        //         _con.addresses.elementAt(index))
                        //         .then((value) {
                        //      });
                        //     DeliveryAddressDialog(
                        //       context: context,
                        //       address: _address,
                        //       onChanged: (Address _address) {
                        //         _con.updateAddress(_address);
                        //       },
                        //     );
                        //   },
                        //   onLongPress: (Address _address) {
                        //     DeliveryAddressDialog(
                        //       context: context,
                        //       address: _address,
                        //       onChanged: (Address _address) {
                        //         _con.updateAddress(_address);
                        //       },
                        //     );
                        //   },
                        //   onDismissed: (Address _address) {
                        //     _con.removeDeliveryAddress(_address);
                        //   },
                        // );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
  void add_address() async{
    LocationResult result = await showLocationPicker(
        context,
        setting.value.googleMapsKey,
        initialCenter: LatLng(
            deliveryAddress.value.latitude ?? 24.683539257146286,
            deliveryAddress.value.longitude ?? 46.691313832998276),
        automaticallyAnimateToCurrentLocation: true,
        //mapStylePath: 'assets/mapStyle.json',
        myLocationButtonEnabled: true,
        language:"ar",
        initialZoom:9
      //resultCardAlignment: Alignment.bottomCenter,
    );
    if (result==null) {
      _con!.showMsg("العنوان غير صحيح");
      return ;
    }
    if (result.address == null) {
      result.address = "";

    }
    if (result.latLng == null || result.latLng.latitude == null) {
      _con!.showMsg("العنوان غير صحيح");
      return;
    }
    setState(() { _con!.load = true;});
    try{
      final coordinates = new geocoder.Coordinates(result.latLng.latitude, result.latLng.longitude);
      var addresses2 = await geocoder.Geocoder.google( setting.value.googleMapsKey).findAddressesFromCoordinates(coordinates);
      var first = addresses2.first;
      String adressBase = first.featureName;
      if (result.address == "" && adressBase != null){
        result.address = adressBase;
      }
      print("${first.featureName} : ${first.countryCode}");
      if (first.countryCode.toUpperCase() != "SA"){
        setState(() { _con!.load = false;});
        _con!.showMsg("التطبيق متاح فقط في المملكة العربية السعودية");
        return;
      }
    }catch(e){

    }
    setState(() { _con!.load = false;});

    // setState(() { _con.load = false;});
    DeliveryAddressDialog(
      context: context,
      address: new Address.fromJSON({
        'address': result.address,
        'latitude': result.latLng.latitude,
        'longitude': result.latLng.longitude,
      }),
      onChanged: (Address _address) {
        setState(() { _con!.load = true;});

        _con! .addAddress(_address);
      },
    );

    print("result = $result");
  }
}
