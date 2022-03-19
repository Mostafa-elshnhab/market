import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/credit_card.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

ValueNotifier<User> currentUser = new ValueNotifier(User());

Future<User> login(User user) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}login';
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    currentUser.value = User.fromJSON(json.decode(response.body)['data']);
  } else {
    throw new Exception(response.body);
  }
  return currentUser.value;
}

Future<User> register(User user) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}register';
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );

  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    currentUser.value = User.fromJSON(json.decode(response.body)['data']);
  } else {
     print(response.body);
    // print(value.apiToken );
    throw new Exception(response.body);
  }
  return currentUser.value;
}


Future<String> findByPhone(String number) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}findByPhone';
  // final String url = 'https://www.steeramarket.com/delivery/api/findByPhone';
  final client = new http.Client();
  var data = new Map();
  data["phone"] =  number;

  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(data),
  );
  if (response.statusCode == 200) {
    return json.decode(response.body)['data'];
  } else {
    throw new Exception(response.body);
  }
  return "";
}


Future<User> login_verification_code(String name,String number) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}phoneSign';
  // final String url = 'https://www.steeramarket.com/delivery/api/phoneSign';
  final client = new http.Client();
  var data = new Map();
  data["phone"] =  number;
  data["name"] =  name;

  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(data),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    currentUser.value = User.fromJSON(json.decode(response.body)['data']);
  } else {
    throw new Exception(response.body);
  }
  return currentUser.value;
}


Future<bool> resetPassword(User user) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}send_reset_link_email';
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    return true;
  } else {
    throw new Exception(response.body);
  }
}

Future<void> logout() async {
  currentUser.value = new User();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('current_user');
}

void setCurrentUser(jsonString) async {
  if (json.decode(jsonString)['data'] != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try{
      User user = User.fromJSON(json.decode(jsonString)['data']);

      FirebaseCrashlytics.instance.setUserIdentifier((user.id == null|| user.id == "") ? "Not Found ": user.id!);
      FirebaseCrashlytics.instance.setCustomKey("name ", (user.name == null|| user.name! == "") ? "Not Found ": user.name!);
      FirebaseCrashlytics.instance.setCustomKey("phone ", (user.phone == null|| user.phone == "") ? "Not Found ": user.phone!);
      FirebaseCrashlytics.instance.setCustomKey("email ", (user.email == null|| user.email == "") ? "Not Found ": user.email!);
      FirebaseCrashlytics.instance.log("name: ${(user.name == null|| user.name == "") ? "Not Found ": user.name}");
      FirebaseCrashlytics.instance.log("phone: ${(user.phone == null|| user.phone == "") ? "Not Found ": user.phone}");
      FirebaseCrashlytics.instance.log("email: ${(user.email == null|| user.email == "") ? "Not Found ": user.email}");

    }catch(e){
    }

    await prefs.setString('current_user', json.encode(json.decode(jsonString)['data']));
  }
}

Future<void> setCreditCard(CreditCard creditCard) async {
  if (creditCard != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('credit_card', json.encode(creditCard.toMap()));
  }
}

Future<User> getCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //prefs.clear();
  if (currentUser.value.auth == null && prefs.containsKey('current_user')) {
    currentUser.value = User.fromJSON(json.decode(await prefs.get('current_user').toString()));
    currentUser.value.auth = true;
    try{
      FirebaseCrashlytics.instance.setUserIdentifier((currentUser.value.id == null|| currentUser.value.id == "") ? "Not Found ": currentUser.value.id!);
      FirebaseCrashlytics.instance.setCustomKey("name ", (currentUser.value.name == null|| currentUser.value.name == "") ? "Not Found ": currentUser.value.name!);
      FirebaseCrashlytics.instance.setCustomKey("phone ", (currentUser.value.phone == null|| currentUser.value.phone == "") ? "Not Found ": currentUser.value.phone!);
      FirebaseCrashlytics.instance.setCustomKey("email ", (currentUser.value.email == null|| currentUser.value.email == "") ? "Not Found ": currentUser.value.email!);
      FirebaseCrashlytics.instance.log("name: ${(currentUser.value.name == null|| currentUser.value.name == "") ? "Not Found ": currentUser.value.name}");
      FirebaseCrashlytics.instance.log("phone: ${(currentUser.value.phone == null|| currentUser.value.phone == "") ? "Not Found ": currentUser.value.phone}");
      FirebaseCrashlytics.instance.log("email: ${(currentUser.value.email == null|| currentUser.value.email == "") ? "Not Found ": currentUser.value.email}");

    }catch(e){
      print("FirebaseCrashlytics Error");
    }

  }
  else {
    try{
      FirebaseCrashlytics.instance.log("User is not logged in");
    }catch(e){
      print("FirebaseCrashlytics Error");
    }
    currentUser.value.auth = false;
  }
  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
  currentUser.notifyListeners();
  return currentUser.value;
}

Future<CreditCard> getCreditCard() async {
  CreditCard _creditCard = new CreditCard();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('credit_card')) {
    _creditCard = CreditCard.fromJSON(json.decode(await prefs.get('credit_card').toString()));
  }
  return _creditCard;
}

Future<User> update(User user) async {
  final String _apiToken = 'api_token=${currentUser.value.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}users/${currentUser.value.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  ); 
  setCurrentUser(response.body);
  currentUser.value = User.fromJSON(json.decode(response.body)['data']);
  return currentUser.value;
}

Future<Stream<Address>> getAddresses() async {
  User _user = currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}delivery_addresses?$_apiToken&search=user_id:${_user.id}&searchFields=user_id:=&orderBy=updated_at&sortedBy=desc';
  print(url);
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
    return Address.fromJSON(data);
  });
}

Future<Address> addAddress(Address address) async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  address.userId = _user.id;
  final String url = '${GlobalConfiguration().getString('api_base_url')}delivery_addresses?$_apiToken';
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(address.toMap()),
  );
  return Address.fromJSON(json.decode(response.body)['data']);
}

Future<Address> updateAddress(Address address) async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  address.userId = _user.id;
  final String url = '${GlobalConfiguration().getString('api_base_url')}delivery_addresses/${address.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.put(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(address.toMap()),
  );
  return Address.fromJSON(json.decode(response.body)['data']);
}

Future<Address> removeDeliveryAddress(Address address) async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}delivery_addresses/${address.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.delete(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  return Address.fromJSON(json.decode(response.body)['data']);
}


//////////////////////////////////
Future<User> register_phone(User user) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}registerphone';
  final client = new http.Client();
  var map = new Map<String, dynamic>();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
//    print(response.body);
//    currentUser.value = User.fromJSON(json.decode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
  return currentUser.value;
}
Future<User> verification_code(User user) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}check';
  final client = new http.Client();
  var map = new Map<String, dynamic>();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    print("sdalsn00");
    print(response.body);
    currentUser.value = User.fromJSON(json.decode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
  return currentUser.value;
}
Future<User> login_phone(User user) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}loginphone';
  final client = new http.Client();
  var map = new Map<String, dynamic>();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
  return currentUser.value;
}