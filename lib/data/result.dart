
import 'dart:math';

class Result {
  String image = "";
  String itinerary = "";
  String cityAndCountry = "";
  String numberOfLikes = "0";
  String key = "";
  String budgetSpending = "";
  String finalDate = "";

  Result(this.image, this.itinerary, this.cityAndCountry, this.key,
      this.budgetSpending, this.finalDate);

  void setResultImage(String image) {
    this.image = image;
  }

  void setResultItinerary(String itinerary) {
    this.itinerary = itinerary;
  }

  void setResultCityAndCountry(String cityAndCountry) {
    this.cityAndCountry = cityAndCountry;
  }

  void calcFinalDate(List<String> dateRanges, String daysNumber) {
    List<DateTime> starts = [];
    List<DateTime> ends = [];
    int idx = daysNumber.indexOf(".");
    daysNumber = daysNumber.substring(0,idx);

    // Parse the string inputs into DateTime objects
    for (String range in dateRanges) {
      List<String> dates = range.split(' - ');
      starts.add(DateTime.parse(dates[0]));
      ends.add(DateTime.parse(dates[1]));
    }

    // Find the maximum start date
    DateTime start = starts.reduce((a, b) => a.isAfter(b) ? a : b);
    // Find the minimum end date
    DateTime end = ends.reduce((a, b) => a.isBefore(b) ? a : b);

    // Check if there is an overlap
    if (end.isAfter(start) || end.isAtSameMomentAs(start)) {
      // Calculate the difference in days
      int differenceInDays = end
          .difference(start)
          .inDays;

      // Check if the difference is greater than or equal to the given daysNumber
      if (differenceInDays == int.parse(daysNumber)) {
        // Additional condition check: if the years of the dates are the same
        if (starts.every((s) => s.year == start.year) &&
            ends.every((e) => e.year == start.year)) {
          finalDate =
          "${start.day}.${start.month}.${start.year}-${end.day}.${end.month},${end.year}";

        }
      } else {
        // No overlap, choose a random period from one of the ranges
        Random random = Random();
        int randomIndex = random.nextInt(starts.length);

        DateTime chosenStart = starts[randomIndex];
        DateTime chosenEnd = ends[randomIndex];

        // Generate a random start date within the chosen range
        int rangeDurationInDays = chosenEnd
            .difference(chosenStart)
            .inDays;
        int randomStartOffset = random.nextInt(rangeDurationInDays);
        DateTime randomStart = chosenStart.add(
            Duration(days: randomStartOffset));
        DateTime randomEnd = randomStart.add(
            Duration(days: int.parse(daysNumber)));

        // Ensure the random end does not exceed the chosen range's end date
        if (randomEnd.isAfter(chosenEnd)) {
          randomEnd = chosenEnd;
        }
        finalDate =
        "${randomStart.year}.${randomStart.month}.${randomStart.day}-${randomEnd.year}.${randomEnd.month}.${randomEnd.day}";
      }
    }
  }
}