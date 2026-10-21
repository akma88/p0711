import 'package:flutter/material.dart';
import 'weather_service.dart';

void main() => runApp(const MyApp());

const ink = Color(0xFF111F38);
const muted = Color(0xFF9BAEC9);
const accent = Color(0xFFF5C96B);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Aspan',
    theme: ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: const Color(0xFF0B1425),
      colorScheme: const ColorScheme.dark(primary: accent, surface: ink),
    ),
    home: const WeatherHome(),
  );
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});
  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final search = TextEditingController();
  WeatherForecast? forecast;
  bool loading = false;
  String? error;

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> load({bool location = false}) async {
    final city = search.text.trim();
    if (loading || (!location && city.isEmpty)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await WeatherService().fetch(
        location ? (forecast?.city.name ?? 'Алматы') : city,
      );
      if (result.list.isEmpty) throw StateError('Empty forecast');
      if (mounted) setState(() => forecast = result);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = location
              ? 'Болжам жаңартылмады. Қайта көріңіз.'
              : 'Қала табылмады немесе желі қолжетімсіз. Қайта көріңіз.',
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = forecast?.list.first;
    final days = forecast?.list;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF203A5D), Color(0xFF0B1425), Color(0xFF111E32)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    children: [
                      const Icon(Icons.blur_on, color: accent, size: 32),
                      const SizedBox(width: 10),
                      const Text(
                        'aspan',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      IconButton.outlined(
                        onPressed: loading ? null : () => load(location: true),
                        tooltip: 'Болжамды жаңарту',
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: search,
                    onSubmitted: (_) => load(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Қаланы іздеу…',
                      prefixIcon: const Icon(Icons.search, color: muted),
                      suffixIcon: IconButton(
                        onPressed: loading ? null : () => load(),
                        icon: const Icon(Icons.arrow_forward, color: accent),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: LinearProgressIndicator(),
                    ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Color(0xFFFFBEAB)),
                      ),
                    ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: accent,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          forecast?.city.name ?? 'Алматы',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    forecast == null
                        ? 'Демо көрініс · Нақты ауа райы үшін қаланы іздеңіз'
                        : 'Ағымдағы күннің болжамы',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.07),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.09),
                            blurRadius: 60,
                          ),
                        ],
                      ),
                      child: Icon(weatherIcon(today), color: accent, size: 92),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${today?.temp.day.round() ?? 18}°',
                      style: const TextStyle(
                        fontSize: 108,
                        height: 1.2,
                        fontWeight: FontWeight.w200,
                        letterSpacing: -7,
                      ),
                    ),
                  ),
                  Text(
                    today?.weather.firstOrNull?.description ?? 'Аспан ашық',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 19, color: muted),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ең жоғары ${today?.temp.max.round() ?? 21}°    /    Ең төмен ${today?.temp.min.round() ?? 12}°',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: muted),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 22,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                    child: Row(
                      children: [
                        metric(
                          Icons.air,
                          '${today?.speed.toStringAsFixed(1) ?? '3.2'} м/с',
                          'Жел',
                        ),
                        metric(
                          Icons.water_drop_outlined,
                          '${today?.humidity ?? 45}%',
                          'Ылғалдылық',
                        ),
                        metric(
                          Icons.thermostat_outlined,
                          '${today?.feelsLike.day.round() ?? 17}°',
                          'Сезіледі',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Алдағы күндер',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${days?.length ?? 7} күн',
                        style: const TextStyle(color: muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: days?.length ?? 7,
                      separatorBuilder: (_, index) => const SizedBox(width: 10),
                      itemBuilder: (_, index) {
                        final day = days?[index];
                        final date = day == null
                            ? DateTime.now().add(Duration(days: index))
                            : DateTime.fromMillisecondsSinceEpoch(
                                (day.dt + forecast!.city.timezone) * 1000,
                                isUtc: true,
                              );
                        const weekdays = [
                          'Дс',
                          'Сс',
                          'Ср',
                          'Бс',
                          'Жм',
                          'Сб',
                          'Жс',
                        ];
                        return Container(
                          width: 100,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: index == 0
                                ? accent
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                index == 0
                                    ? 'Бүгін'
                                    : weekdays[date.weekday - 1],
                                style: TextStyle(
                                  color: index == 0 ? ink : muted,
                                ),
                              ),
                              Icon(
                                weatherIcon(day),
                                color: index == 0 ? ink : accent,
                                size: 30,
                              ),
                              Text(
                                '${day?.temp.max.round() ?? [21, 20, 18, 19, 22, 23, 20][index]}°',
                                style: TextStyle(
                                  color: index == 0 ? ink : Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${day?.temp.min.round() ?? 12}°',
                                style: TextStyle(
                                  color: index == 0
                                      ? ink.withValues(alpha: 0.6)
                                      : muted,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'ASPAN  /  Ауа райы: Open-Meteo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: muted,
                      fontSize: 10,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget metric(IconData icon, String value, String label) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: muted, size: 22),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: muted, fontSize: 11)),
      ],
    ),
  );
}

IconData weatherIcon(WeatherList? day) {
  final code = day?.weather.firstOrNull?.main.toLowerCase() ?? 'clear';
  if (code.contains('rain') || code.contains('drizzle')) {
    return Icons.water_drop;
  }
  if (code.contains('snow')) return Icons.ac_unit;
  if (code.contains('thunder')) return Icons.thunderstorm_outlined;
  if (code.contains('cloud')) return Icons.cloud_outlined;
  if (code.contains('mist') || code.contains('fog')) return Icons.blur_on;
  return Icons.wb_sunny_rounded;
}
