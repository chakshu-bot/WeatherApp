import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

// void main() {
//   runApp(const HomeScreen(cityName: 'Barnala', countryName: 'India',));
// }

List<dynamic> hourlyForecast = [];
List<dynamic> dailyForecast = [];
String selectedPlace = '$cityNa/$countryNa';
String selectedTemperature = '...';
String selectedHumidity = '...';
String selectedDescription = '...';
int selectedHour = DateTime.now().hour;
int selectedDate = DateTime.now().day;
late double latitudeValue = 0.0;
late double longitudeValue = 0.0;

class HomeScreen extends StatefulWidget {
  final String cityName;
  final String countryName;

  const HomeScreen(
      {required this.cityName, required this.countryName, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController _controller;
  Map<int, String> weatherCodeToVideo = {
    0: 'assets/clearSky.mp4',
    1: 'assets/mainlyClearSky.mp4',
    2: 'assets/partlyCloudy.mp4',
    3: 'assets/partlyCloudy.mp4',
    45: 'assets/fog.mp4',
    48: 'assets/fog.mp4',
    51: 'assets/lightRain.mp4',
    53: 'assets/mediumRain.mp4',
    55: 'assets/heavyRain.mp4',
    56: 'assets/freezingRain.mp4',
    57: 'assets/freezingRain.mp4',
    61: 'assets/lightRain.mp4',
    63: 'assets/mediumRain.mp4',
    65: 'assets/heavyRain.mp4',
    66: 'assets/freezingRain.mp4',
    67: 'assets/freezingRain.mp4',
    71: 'assets/snowShowers.mp4',
    73: 'assets/snowShowers.mp4',
    75: 'assets/heavySnow.mp4',
    77: 'assets/snowShowers.mp4',
    80: 'assets/lightRain.mp4',
    81: 'assets/mediumRain.mp4',
    82: 'assets/heavyRainShower.mp4',
    85: 'assets/snowShowers.mp4',
    86: 'assets/heavySnow.mp4',
    95: 'assets/thundering.mp4',
    96: 'assets/thunderstormRain.mp4',
    99: 'assets/thunderstormRain.mp4',
  };

  @override
  void initState() {
    super.initState();
    initializeData();
    _controller = VideoPlayerController.asset(
      'assets/clearSky.mp4',
    );

    _controller.initialize().then((_) {
      _controller.play();
      _controller.setLooping(true);
      setState(() {});
    });

    /*_controller.addListener(() {
      setState(() {});
    });*/
    //_getAddressFromLatLng();
  }

  Future<void> initializeData() async {
    print(widget.cityName);
    print(widget.countryName);
    await getCoordinatesFromNominatim(widget.cityName, widget.countryName);
    fetchWeatherForecast();
  }

  Future<void> getCoordinatesFromNominatim(String cityName, String countryName) async {
    final url =
        'https://nominatim.openstreetmap.org/search?format=json&q=$cityName,$countryName';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final coordinates = data[0];
          double latitude = double.parse(coordinates['lat']);
          double longitude = double.parse(coordinates['lon']);
          print('Latitude: $latitude, Longitude: $longitude');
        } else {
          print('No results found');
        }
      } else {
        print('Failed to get coordinates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching coordinates: $e');
    }
  }


  void fetchWeatherForecast() async {
    // api = https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&past_days=10&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m
    //api = https://api.open-meteo.com/v1/forecast?latitude=30.3745&longitude=75.5487&current=relative_humidity_2m,is_day&hourly=relative_humidity_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&past_days=14&forecast_days=14
    //final uri = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=30.3745&longitude=75.5487&current=relative_humidity_2m,is_day&hourly=relative_humidity_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&past_days=14&forecast_days=14');
    //new uri = https://api.open-meteo.com/v1/forecast?latitude=30.3745&longitude=75.5487&current=temperature_2m,relative_humidity_2m,is_day&hourly=temperature_2m,relative_humidity_2m,weather_code&past_days=7
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitudeValue.toString(),
      'longitude': longitudeValue.toString(),
      'current': 'temperature_2m,relative_humidity_2m,is_day',
      'hourly': 'temperature_2m,relative_humidity_2m,weather_code',
      'past_days': '2',
      'forecast_days': '14',
    });
    print('URI = $uri');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // checking
      int hourlyLength = data['hourly']['time'].length;
      int humidityLength = data['hourly']['relative_humidity_2m'].length;
      int weatherCodeLength = data['hourly']['weather_code'].length;
      setState(() {
        hourlyForecast = data['hourly']['time']
            .asMap()
            .entries
            .map((entry) {
          int index = entry.key;
          String dateTimeStr = entry.value;
          DateTime dateTime = DateTime.parse(dateTimeStr);
          if (index < humidityLength && index < weatherCodeLength) {
            return {
              'date': dateTime.day,
              'hour': dateTime.hour,
              'relative_humidity': data['hourly']['relative_humidity_2m']
              [index],
              'weather_code': data['hourly']['weather_code'][index],
              'temperature': data['hourly']['temperature_2m'][index],
            };
          } else {
            return null;
          }
        })
            .where((element) => element != null)
            .toList();
      });
    } else {
      print('Some Error in API');
    }
    updatedWeather();
  }

  void updatedWeather() {
    print(selectedDate);
    print(selectedHour);
    setState(() {
      var forecastEntry = hourlyForecast.firstWhere(
            (entry) =>
        entry['date'] == selectedDate && entry['hour'] == selectedHour,
        orElse: () => null,
      );
      if (forecastEntry != null) {
        // Extract humidity, temperature, and weather code
        selectedHumidity = forecastEntry['relative_humidity']
            .toString(); // Assuming this is a string
        int selectedWeatherCode = forecastEntry['weather_code'];
        selectedTemperature = forecastEntry['temperature']
            .toString(); // Assuming this is a double
        selectedDescription =
            getWeatherDescription(selectedWeatherCode).toString();

        String videoAsset =
            weatherCodeToVideo[selectedWeatherCode] ?? 'assets/default.mp4';
        _controller = VideoPlayerController.asset(videoAsset)
          ..initialize().then((_) {
            _controller.play();
            _controller.setLooping(true);
            setState(() {});
          });
      } else {
        print('No forecast entry found for the specified date and hour.');
      }
    });
  }

  @override
  void dispose() {
    // Dispose of the video controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromRGBO(245, 245, 245, 0.5),
        appBar: null,
        body: Column(
          children: [
            Flexible(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SafeArea(
                  child: Container(
                    height: 800,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.all(Radius.circular(58)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(58),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controller.value.size.width,
                                height: _controller.value.size.height,
                                child: VideoPlayer(_controller),
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.6),
                          ),
                          Positioned(
                            top: 30,
                            left: 0,
                            right: 0,
                            child: Text(
                              selectedPlace,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Text color to stand out
                                shadows: [
                                  Shadow(
                                    offset: Offset(3.0, 3.0),
                                    // Offset of the shadow
                                    blurRadius: 5.0,
                                    // Blur radius of the shadow
                                    color: Colors.black.withOpacity(
                                        0.7), // Shadow color and opacity
                                  ),
                                ],
                              ),
                              textAlign:
                              TextAlign.center, // Center align the text
                            ),
                          ),
                          Positioned(
                            top: 80,
                            left: 0,
                            right: 0,
                            child: Text(
                              '$selectedTemperature°C',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 100,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(4.0, 4.0),
                                    blurRadius: 7.0,
                                    color: Colors.black.withOpacity(0.8),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            top: 220,
                            left: 0,
                            right: 0,
                            child: Text(
                              selectedDescription,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(3.0, 3.0),
                                    blurRadius: 5.0,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 40,
                            child: Text(
                              'H:$selectedHumidity%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(3.0, 3.0),
                                    blurRadius: 5.0,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            bottom: 50,
                            left: 30,
                            child: Text(
                              'Lat:' + latitudeValue.toStringAsFixed(2),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(3.0, 3.0),
                                    blurRadius: 5.0,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 30,
                            child: Text(
                              'Long:' + longitudeValue.toStringAsFixed(2),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(3.0, 3.0),
                                    blurRadius: 5.0,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SleekCircularSlider(
                      appearance: CircularSliderAppearance(
                        infoProperties: InfoProperties(
                          modifier: (double value) {
                            int hour = value.toInt();
                            return '${hour.toString().padLeft(2, '0')}:00 ';
                          },
                          mainLabelStyle: const TextStyle(
                            color: Colors.black, // Adjust text color here
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      min: 0,
                      max: 23,
                      initialValue: DateTime.now().hour.toDouble(),
                      onChange: (value) {
                        setState(() {
                          selectedHour = value.toInt();
                          updatedWeather();
                        });
                      },
                    ),
                    SleekCircularSlider(
                      appearance: CircularSliderAppearance(
                        infoProperties: InfoProperties(
                          modifier: (double value) {
                            DateTime initialDate = DateTime.now();
                            int daysFromInitial = value.toInt() - 5;
                            DateTime newDate = initialDate
                                .add(Duration(days: daysFromInitial));

                            // Map the integer weekday to the corresponding day name
                            Map<int, String> weekdays = {
                              1: 'Mon',
                              2: 'Tues',
                              3: 'Wed',
                              4: 'Thur',
                              5: 'Fri',
                              6: 'Sat',
                              7: 'Sun'
                            };

                            // Get the day of the week
                            int weekday = newDate.weekday;
                            int newValue = (value.toInt() + 29) % 30 + 1;

                            // Return the mapped day name
                            return ' $newValue, ${weekdays[weekday]} ';
                          },
                          mainLabelStyle: const TextStyle(
                            color: Colors.black, // Adjust text color here
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      min: DateTime.now().day.toDouble() - 2,
                      initialValue: DateTime.now().day.toDouble(),
                      max: DateTime.now().day.toDouble() + 13,
                      onChange: (value) {
                        setState(() {
                          selectedDate = value.toInt();
                          updatedWeather();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: null,
      ),
    );
  }
}

String getWeatherDescription(int code) {
  switch (code) {
    case 0:
      return "Clear sky";
    case 1:
      return "Mainly clear";
    case 2:
      return "Partly cloudy";
    case 3:
      return "Overcast";
    case 45:
      return "Fog";
    case 48:
      return "Depositing rime fog";
    case 51:
      return "Drizzle: Light";
    case 53:
      return "Drizzle: Moderate";
    case 55:
      return "Drizzle: Dense";
    case 56:
      return "Freezing Drizzle: Light";
    case 57:
      return "Freezing Drizzle: Dense";
    case 61:
      return "Rain: Slight";
    case 63:
      return "Rain: Moderate";
    case 65:
      return "Rain: Heavy";
    case 66:
      return "Freezing Rain: Light";
    case 67:
      return "Freezing Rain: Heavy";
    case 71:
      return "Snow fall: Slight";
    case 73:
      return "Snow fall: Moderate";
    case 75:
      return "Snow fall: Heavy";
    case 77:
      return "Snow grains";
    case 80:
      return "Rain showers: Slight";
    case 81:
      return "Rain showers: Moderate";
    case 82:
      return "Rain showers: Violent";
    case 85:
      return "Snow showers: Slight";
    case 86:
      return "Snow showers: Heavy";
    case 95:
      return "Thunderstorm: Slight or moderate";
    case 96:
      return "Thunderstorm with slight hail";
    case 99:
      return "Thunderstorm with heavy hail";
    default:
      return "Unknown weather";
  }
}
/*SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controller.value.size.width,
                                height: _controller.value.size.height,
                                child: VideoPlayer(_controller),
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.6),
                          ),
                          */
