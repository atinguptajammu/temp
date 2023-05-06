import 'package:intl/intl.dart';
class ChangeTimeZone{
  // String time;
  // int offSet=0;
  // String timeZone;
  // String finalDate="";
  // ChangeTimeZone( this.time,this.timeZone,){
  //   this.finalDate = convertTime(time);
  // }
  //#GCW 31-01-2023
  DateTime convertToUtc(DateTime date, int offset) {
    return date.add(Duration(hours: offset));
  }

  String convertTimeDT(DateTime date,String timeZone) {
    // print("ATTIN:$date $timeZone");
    // if (date == "") {
    //   return "";
    // }
    // var s = date.split(" ");
    // //yyyy-MM-ddTHH:mm:ss.mmm
    // var hour = int.parse(s[1].split(":")[0]);
    // if (s[2] == "pm") {
    //   hour += 12;
    //   //print(hour);
    // }
    // var hourStr = hour > 9 ? "$hour" : "0$hour";
    // var d =
    //     "${s[0].split("/")[2]}-${s[0].split("/")[0]}-${s[0].split("/")[1]}T${hourStr}:${s[1].split(":")[1]}:00.000";
    // //var d = "${s[0].split("/")[2]}-${s[0].split("/")[0]}-${s[0].split("/")[1]}T$hour${s[1].split(":")[1]}:00.000" ;
    // var dd = DateTime.parse(d);
    int offSet;
    if (timeZone == "Pacific/Honolulu") {
      offSet = 5;
    } else if (timeZone == "America/Anchorage") {
      offSet = 4;
    } else if (timeZone == "America/Los_Angeles") {
      offSet = 3;
    } else if (timeZone == "America/Denver") {
      offSet = 2;
    } else if (timeZone == "America/Chicago") {
      offSet = 1;
    } else {
      offSet = 0;
    }
    var finalDate = convertToUtc(date, offSet);
    var datee = DateFormat("MM/dd/yyyy h:mm a").format(finalDate);
    print("$datee");
    //var finalDateStr = DateFormat("MM/dd/yyyy HH:mm a").format(finalDate);
    return datee.toString();
  }
  //#GCW 31-01-2023
  String convertTime(String date,String timeZone) {
    print("ATTIN:$date $timeZone");
    if (date == "") {
      return "";
    }
    var s = date.split(" ");
    //yyyy-MM-ddTHH:mm:ss.mmm
    var hour = int.parse(s[1].split(":")[0]);
    if (s[2] == "pm") {
      hour += 12;
      //print(hour);
    }
    var hourStr = hour > 9 ? "$hour" : "0$hour";
    var d =
        "${s[0].split("/")[2]}-${s[0].split("/")[0]}-${s[0].split("/")[1]}T${hourStr}:${s[1].split(":")[1]}:00.000";
    //var d = "${s[0].split("/")[2]}-${s[0].split("/")[0]}-${s[0].split("/")[1]}T$hour${s[1].split(":")[1]}:00.000" ;
    var dd = DateTime.parse(d);
    int offSet;
    if (timeZone == "Pacific/Honolulu") {
      offSet = 5;
    } else if (timeZone == "America/Anchorage") {
      offSet = 4;
    } else if (timeZone == "America/Los_Angeles") {
      offSet = 3;
    } else if (timeZone == "America/Denver") {
      offSet = 2;
    } else if (timeZone == "America/Chicago") {
      offSet = 1;
    } else {
      offSet = 0;
    }
    var finalDate = convertToUtc(dd, offSet);
    var datee = DateFormat("MM/dd/yyyy h:mm a").format(finalDate);
    print("$datee");
    //var finalDateStr = DateFormat("MM/dd/yyyy HH:mm a").format(finalDate);
    return datee.toString();
  }
}