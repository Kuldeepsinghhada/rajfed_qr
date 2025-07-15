

import 'package:intl/intl.dart';

class DateFormatter {

  static String formatDateToDDMMMYYYY(String dateString){
    try {
      DateTime dateTime = DateTime.parse(dateString); // Convert to DateTime
      String formattedDate = DateFormat("dd MMM yyyy").format(
          dateTime); // Format
      return formattedDate;
    } catch(e){
      return "";
    }
  }
}