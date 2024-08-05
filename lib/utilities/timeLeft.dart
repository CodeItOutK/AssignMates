class OurTimeLeft {
  List<String> timeLeft(dynamic time) {
    List<String> retVal = [];

    // Get current time in IST
    DateTime nowIST = DateTime.now().toUtc().add(Duration(hours: 5, minutes: 30));

    // Calculate remaining time
    Duration _timeUntilDue = time.difference(nowIST);

    if (_timeUntilDue.inSeconds <= 0) {
      // The duration is zero or negative
      retVal.add("Blocked Assignment");
      return retVal;
    }

    int _daysUntil = _timeUntilDue.inDays;
    int _hoursUntil = _timeUntilDue.inHours - 24 * _daysUntil;
    int _minUntil = _timeUntilDue.inMinutes - _hoursUntil * 60 - _daysUntil * 24 * 60;
    int _secUntil = _timeUntilDue.inSeconds - _minUntil * 60 - _hoursUntil * 60 * 60 - _daysUntil * 24 * 60 * 60;

    if (_daysUntil > 0) {
      retVal.add(_daysUntil.toString() + ' days, ' + _hoursUntil.toString() + ' hours, ' + _minUntil.toString() + ' min, ' + _secUntil.toString() + ' sec');
    } else if (_hoursUntil > 0) {
      retVal.add(_hoursUntil.toString() + ' hours, ' + _minUntil.toString() + ' min, ' + _secUntil.toString() + ' sec');
    } else if (_minUntil > 0) {
      retVal.add(_minUntil.toString() + ' min, ' + _secUntil.toString() + ' sec');
    } else if (_secUntil > 0) {
      retVal.add(_secUntil.toString() + ' sec');
    } else {
      retVal.add("Blocked Assignment");
    }

    return retVal;
  }
}


// class OurTimeLeft {
  // List<String> timeLeft(dynamic time) {
  //   // Convert the input time to Indian Standard Time (UTC +5:30)
  //   DateTime istTime = time.difference(DateTime.now().toLocal());
  //
  //   // DateTime istTime=time.toLocal().toLocaleString("en-US", {timeZone: "Asia/Kolkata"})
  //   List<String> retVal = [];
  //   // Calculate remaining time from the adjusted IST time
  //   Duration _timeUntilDue = istTime.difference(DateTime.now().toLocal());
  //   int _daysUntil = _timeUntilDue.inDays;
  //   int _hoursUntil = _timeUntilDue.inHours - 24 * _daysUntil;
  //   int _minUntil = _timeUntilDue.inMinutes - _hoursUntil * 60 - _daysUntil * 24 * 60;
  //   int _secUntil = _timeUntilDue.inSeconds - _minUntil * 60 - _hoursUntil * 60 * 60 - _daysUntil * 24 * 60 * 60;
  //
  //   if (_daysUntil > 0) {
  //     retVal.add(_daysUntil.toString() + ' days,' + _hoursUntil.toString() + ' hours,' + _minUntil.toString() + 'min,' + _secUntil.toString() + 'sec');
  //   } else if (_hoursUntil > 0) {
  //     retVal.add(_hoursUntil.toString() + ' hours,' + _minUntil.toString() + 'min,' + _secUntil.toString() + 'sec,');
  //   } else if (_minUntil > 0) {
  //     retVal.add(_minUntil.toString() + 'min,' + _secUntil.toString() + 'sec,');
  //   } else if (_secUntil > 0) {
  //     retVal.add(_secUntil.toString() + 'sec');
  //   } else {
  //     retVal.add("Blocked Assignment");
  //   }
  //
  //   return retVal;
  // }
// }


// class OurTimeLeft{
//   List<String>timeLeft(dynamic time){
//     List<String>retVal=[];
//     //remaining time
//     Duration _timeUntilDue=time.difference(DateTime.now());
//     if (_timeUntilDue.inSeconds <= 0) {
//       // The duration is zero or negative
//       retVal.add("Blocked Assignment");
//       return retVal;
//     }
//     int _daysUntil=_timeUntilDue.inDays;
//     int _hoursUntil=_timeUntilDue.inHours-24*_daysUntil;
//     int _minUntil=_timeUntilDue.inMinutes-_hoursUntil*60-_daysUntil*24*60;
//     int _secUntil=_timeUntilDue.inSeconds-_minUntil*60-_hoursUntil*60*60-_daysUntil*24*60*60;
//     if(_daysUntil>0){
//       retVal.add(_daysUntil.toString()+' days,'+_hoursUntil.toString()+' hours,'+_minUntil.toString()+'min,'+_secUntil.toString()+'sec');
//     }else if(_hoursUntil>0){
//       retVal.add(_hoursUntil.toString()+' hours,'+_minUntil.toString()+'min,'+_secUntil.toString()+'sec,');
//     }else if(_minUntil>0){
//       retVal.add(_minUntil.toString()+'min,'+_secUntil.toString()+'sec,');
//     }else if(_secUntil>0){
//       retVal.add(_secUntil.toString()+'sec');
//     }else{
//       retVal.add("Blocked Assignment");
//     }
//
//     return retVal;
//   }
// }