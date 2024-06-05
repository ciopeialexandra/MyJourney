import 'package:myjorurney/data/plan.dart';
import 'package:myjorurney/data/request.dart';

Plan plan = Plan("", "" ,"","",false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,"");
String resultMsg = "";
List<String> plans = [];
List<Request> request =  List.empty(growable: true);
List<bool> isSelected = List<bool>.filled(100, false);
bool isFriendsTrip = false;
bool isPlanRequest = false;
int requestIndex = -1;
bool requestUpdateNeeded = false;
bool areResultsGeneratedGlobal = false;
String globalRequestIdSoloTrip = "";
String globalCurrentTripImage = "";
String globalCurrentCityAndCountry = "";
String globalItinerary = "";
Request globalRequest = Request("", List.empty(growable: true), List.empty(growable: true),"");