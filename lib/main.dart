import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
void main() => runApp(MyApp());
class MyApp extends StatelessWidget{
@override
Widget build(BuildContext context){
return MaterialApp(
theme:ThemeData(
appBarTheme:AppBarTheme(
color:Colors.deepPurple[700],),
accentColor:Colors.pinkAccent[700],),
home:Scaffold(
appBar:AppBar(
title:Text("Stopwatchs for your job's"),),
body:MainScreen(),
),);}}
class MainScreen extends StatefulWidget {
@override
_MainScreenState createState()=>_MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
Map<String,int>_stopwatchMap={};
List<String> _sortedStopwatch = [];
final _txtControl=TextEditingController();
_loadStopwatches()async {
final _sharedPref=await SharedPreferences.getInstance();
var keys=_sharedPref.getKeys();
for(var key in keys){
_stopwatchMap[key]=_sharedPref.getInt(key);
}
_sortedStopwatch =_stopwatchMap.keys.toList()..sort();
setState((){});
}
@override
void initState(){
_loadStopwatches();
super.initState();
}
@override
Widget build(BuildContext context){
return Column(
children:<Widget>[
Expanded(
child:SingleChildScrollView(
child:Column(
children:_sortedStopwatch.map((text){
return StopwatchItem(text,_stopwatchMap[text]);
}).toList(),
),
),
),
TextFormField(
controller:_txtControl,
decoration:InputDecoration(
hintText:"Write here to add new stopwatch",
),
onEditingComplete:()=>setState((){
if(!_stopwatchMap.containsKey(_txtControl.text.toString())) {
var txt=_txtControl.text.toString();
_stopwatchMap[txt]=0;
_txtControl.text="";
_sortedStopwatch.add(txt);
if(_stopwatchMap.length>14)
Scaffold.of(context).showSnackBar(SnackBar(
content:Text("App may work slow if you add more than 15 stopwatches"),
backgroundColor:Colors.deepPurple[700],));
}}),),],);}}
class StopwatchItem extends StatefulWidget{
final String _txt;
final int _val;
StopwatchItem(this._txt,this._val);
@override
_StopwatchItemState createState()=>_StopwatchItemState(_txt,_val);}
class _StopwatchItemState extends State<StopwatchItem>{
final String _stopwatchTitle;
int _val;
final _stream=StreamController<bool>();
var _isRun=false;
_StopwatchItemState(this._stopwatchTitle,this._val);
@override
Widget build(BuildContext context){
return _val!=-1?Dismissible(
key:Key(_stopwatchTitle),
direction:DismissDirection.endToStart,
onDismissed:(DismissDirection direct){_val=-1;},
child:Card(
child:Column(
crossAxisAlignment:CrossAxisAlignment.start,
children:<Widget>[
Container(
padding:EdgeInsets.only(left:10,top:5),
child:Text(
_stopwatchTitle,
style:TextStyle(fontSize:35),)),
Row(children:<Widget>[
TimerWidget(_stopwatchTitle,_val,_stream.stream),
Expanded(
child:Container(),),
Container(
padding:EdgeInsets.only(right:20,bottom:10),
child:!_isRun
?Container():SpinKitPouringHourglass(
color:Colors.black,),),
Container(
padding:EdgeInsets.only(right:10, bottom:10),
child:FloatingActionButton(
child:_isRun
?Icon(Icons.stop)
:Icon(Icons.play_arrow),
onPressed:(){
_isRun ? _isRun =false :_isRun =true;
_stream.add(_isRun);
setState((){});
},),),],)],),),)
:Container();}
@override
void dispose(){
_stream.close();
super.dispose();}}
class TimerWidget extends StatefulWidget {
final String _txt;
final int _val;
final Stream<bool>_stream;
TimerWidget(this._txt,this._val,this._stream);
@override
_TimerWidgetState createState()=>_TimerWidgetState(_txt,_val,_stream);}
class _TimerWidgetState extends State<TimerWidget> {
_TimerWidgetState(this._swTitle,this._stopwatchTime,this._stream){
_timer=Timer.periodic(Duration(seconds:1),_callback);
_makeStopwatchText();
SharedPreferences.getInstance().then((sp){
_sharePref=sp;
_saveStopwatch();});
_stream.listen((isRun)=>setState((){
_isTic=isRun;
if(!isRun)_saveStopwatch();
}));}
final Stream<bool>_stream;
final String _swTitle;
Timer _timer;
var _stopwatchMinTxt="";
var _stopwatchSecTxt="";
var _stopwatchTime;
var _isTic=false;
SharedPreferences _sharePref;
_makeStopwatchText() {
int hour=_stopwatchTime~/3600;
int min=_stopwatchTime~/60;
int sec=_stopwatchTime%60;
_stopwatchMinTxt=
"${hour ==0 ? "" :hour.toString() + ":"}${min < 10 ? "0" + min.toString() :min.toString()}";
_stopwatchSecTxt =" ${sec < 10 ? "0" + sec.toString() :sec.toString()}";}
_callback(var tmr) {
if(_isTic){_stopwatchTime++;
_makeStopwatchText();
if(_stopwatchTime%10==0)_saveStopwatch();
setState(() {});}}
_saveStopwatch() {
final keys =_sharePref.getKeys();
if (keys.contains(_swTitle)) _sharePref.remove(_stopwatchMinTxt);
_sharePref.setInt(_swTitle, _stopwatchTime);}
@override
Widget build(BuildContext context){
return Container(padding:EdgeInsets.only(left:10),
child:Row(
crossAxisAlignment:CrossAxisAlignment.end,
children:<Widget>[
Text(_stopwatchMinTxt,
style:TextStyle(fontSize:33),),
Text(
_stopwatchSecTxt,
style:TextStyle(fontSize:25),
)],));}
@override
void dispose(){
_timer.cancel();
_sharePref.remove(_swTitle);
super.dispose();
}}