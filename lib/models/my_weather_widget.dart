import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

class MyWeatherWidget extends StatefulWidget {
  const MyWeatherWidget({super.key});

  @override
  State<MyWeatherWidget> createState() => _MyWeatherWidgetState();
}

class _MyWeatherWidgetState extends State<MyWeatherWidget> {
  final WeatherFactory _wf = WeatherFactory('5dfb22dd23bffff6a6fdd6e75b52a38e');
  Weather? _weather;
  String _message = '';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  void _getWeather() async {
    // Get permission for location
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      setState(() {
        _isLoading = false;
        _message = "Please enable location services";
      });
      return;
    }

    try {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // Get weather for current location
      Weather weather = await _wf.currentWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _weather = weather;
        _message = _getWeatherMessage(weather);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = "Could not get weather data";
      });
    }
  }

  String _getWeatherMessage(Weather weather) {
    final condition = weather.weatherMain?.toLowerCase() ?? '';
    final temp = weather.temperature?.celsius ?? 0;

    if (condition.contains('rain')) {
      return _getRandomMessage([
        "Cozy rainy day, huh? Perfect for gaming! 🎮",
        "Do you love walking in the rain? I'll keep you dry inside! ☔",
        "Rain outside? Time for a gaming marathon! 🌧️"
      ]);
    } else if (condition.contains('clear') && temp > 20) {
      return _getRandomMessage([
        "Beautiful day! Maybe touch some grass between games? 🌿",
        "Sun's out! How about a quick walk before the next game? 🌞",
        "Perfect weather for outdoor activities! But one game first? 🎮"
      ]);
    } else if (condition.contains('snow')) {
      return _getRandomMessage([
        "Snowy day! Stay warm and play games! ❄️",
        "Perfect weather for hot cocoa and gaming! ☃️",
        "Let it snow! We've got plenty of games to keep you busy! ❄️"
      ]);
    } else {
      return "Ready for some gaming fun? 🎮";
    }
  }

  String _getRandomMessage(List<String> messages) {
    return messages[DateTime.now().millisecond % messages.length];
  }

  IconData _getWeatherIcon(String? condition) {
    if (condition == null) return Icons.add_a_photo;
    
    condition = condition.toLowerCase();
    if (condition.contains('rain')) return Icons.car_repair_rounded;
    if (condition.contains('snow')) return Icons.car_repair_rounded;
    if (condition.contains('clear')) return Icons.car_repair_rounded;
    if (condition.contains('cloud')) return Icons.car_repair_rounded;
    if (condition.contains('thunder')) return Icons.car_repair_rounded;
    return  Icons.car_repair_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_weather == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_message),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getWeatherIcon(_weather?.weatherMain),
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_weather?.temperature?.celsius?.toStringAsFixed(1)}°C',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _weather?.weatherMain ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 