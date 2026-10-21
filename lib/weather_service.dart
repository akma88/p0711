import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  Future<Map<String, dynamic>> _get(Uri uri) async {
    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw StateError('Service unavailable');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<WeatherForecast> fetch(String query) async {
    final places = await _get(
      Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': query,
        'count': '1',
        'language': 'ru',
      }),
    );
    final results = places['results'] as List?;
    if (results == null || results.isEmpty) throw StateError('City not found');
    final place = results.first as Map<String, dynamic>;
    final data = await _get(
      Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '${place['latitude']}',
        'longitude': '${place['longitude']}',
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
        'wind_speed_unit': 'ms',
        'timezone': 'auto',
        'forecast_days': '7',
      }),
    );
    final current = data['current'] as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;
    final dates = daily['time'] as List;
    final days = List.generate(dates.length, (i) {
      final max = (daily['temperature_2m_max'][i] as num).toDouble();
      final min = (daily['temperature_2m_min'][i] as num).toDouble();
      return WeatherList(
        dt: DateTime.parse('${dates[i]}T00:00:00Z').millisecondsSinceEpoch ~/ 1000,
        temp: Temperatures(
          i == 0
              ? (current['temperature_2m'] as num).toDouble()
              : (max + min) / 2,
          min,
          max,
        ),
        feelsLike: FeelsLike(
          (current['apparent_temperature'] as num).toDouble(),
        ),
        speed: (current['wind_speed_10m'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).round(),
        weather: [
          WeatherCondition(
            i == 0
                ? current['weather_code'] as int
                : daily['weather_code'][i] as int,
          ),
        ],
      );
    });
    return WeatherForecast(City('${place['name']}'), days);
  }
}

class WeatherForecast {
  final City city;
  final List<WeatherList> list;
  WeatherForecast(this.city, this.list);
}

class City {
  final String name;
  final int timezone = 0;
  City(this.name);
}

class WeatherList {
  final int dt, humidity;
  final double speed;
  final Temperatures temp;
  final FeelsLike feelsLike;
  final List<WeatherCondition> weather;
  WeatherList({
    required this.dt,
    required this.humidity,
    required this.speed,
    required this.temp,
    required this.feelsLike,
    required this.weather,
  });
}

class Temperatures {
  final double day, min, max;
  Temperatures(this.day, this.min, this.max);
}

class FeelsLike {
  final double day;
  FeelsLike(this.day);
}

class WeatherCondition {
  final int code;
  WeatherCondition(this.code);
  String get main {
    if (code >= 95) return 'thunder';
    if (code >= 71 && code <= 77 || code == 85 || code == 86) return 'snow';
    if (code >= 51) return 'rain';
    if (code >= 45) return 'fog';
    if (code >= 1) return 'cloud';
    return 'clear';
  }

  String get description => switch (main) {
    'thunder' => 'Найзағай',
    'snow' => 'Қар',
    'rain' => 'Жаңбыр',
    'fog' => 'Тұман',
    'cloud' => 'Бұлтты',
    _ => 'Аспан ашық',
  };
}
