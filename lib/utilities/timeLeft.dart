class OurTimeLeft{
  List<String>timeLeft(dynamic time){
    List<String>retVal=[];
    //remaining time
    Duration _timeUntilDue=time.difference(DateTime.now());
    int _daysUntil=_timeUntilDue.inDays;
    int _hoursUntil=_timeUntilDue.inHours-24*_daysUntil;
    int _minUntil=_timeUntilDue.inMinutes-_hoursUntil*60-_daysUntil*24*60;
    int _secUntil=_timeUntilDue.inSeconds-_minUntil*60-_hoursUntil*60*60-_daysUntil*24*60*60;
    if(_daysUntil>0){
      retVal.add(_daysUntil.toString()+' days,'+_hoursUntil.toString()+' hours,'+_minUntil.toString()+'min,'+_secUntil.toString()+'sec');
    }else if(_hoursUntil>0){
      retVal.add(_hoursUntil.toString()+' hours,'+_minUntil.toString()+'min,'+_secUntil.toString()+'sec,');
    }else if(_minUntil>0){
      retVal.add(_minUntil.toString()+'min,'+_secUntil.toString()+'sec,');
    }else if(_secUntil>0){
      retVal.add(_secUntil.toString()+'sec');
    }else{
      retVal.add("Blocked Assignement");
    }

    return retVal;
  }
}
// class OurTimeLeft{
//   List<String>timeLeft(dynamic time){
//     List<String>retVal=[];
//     //remaining time
//     Duration _timeUntilDue=time.difference(DateTime.now());
//     int _daysUntil=_timeUntilDue.inDays;
//     int _hoursUntil=_timeUntilDue.inHours-24*_daysUntil;
//     int _minUntil=_timeUntilDue.inMinutes-_hoursUntil*60-_daysUntil*24*60;
//     int _secUntil=_timeUntilDue.inSeconds-_minUntil*60-_hoursUntil*60*60-_daysUntil*24*60*60;
//     if(_daysUntil>0){
//       retVal.add(_daysUntil.toString()+' days\n'+_hoursUntil.toString()+' hours\n'+_minUntil.toString()+'min\n'+_secUntil.toString()+'sec');
//     }else if(_hoursUntil>0){
//       retVal.add(_hoursUntil.toString()+' hours\n'+_minUntil.toString()+'min\n'+_secUntil.toString()+'sec');
//     }else if(_minUntil>0){
//       retVal.add(_minUntil.toString()+'min\n'+_secUntil.toString()+'sec');
//     }else if(_secUntil>0){
//       retVal.add(_secUntil.toString()+'sec');
//     }else{
//       retVal.add("Blocked Assignement");
//     }
//
//     return retVal;
//   }
// }