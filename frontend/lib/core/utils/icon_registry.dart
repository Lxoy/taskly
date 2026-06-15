import 'package:flutter/material.dart';

/// Mapira string naziv ikone (pohranjen u bazi) na Flutter IconData.
class IconRegistry {
  IconRegistry._();

  static const Map<String, IconData> all = {
    'bolt_rounded':              Icons.bolt_rounded,
    'tv_rounded':                Icons.tv_rounded,
    'directions_car_rounded':    Icons.directions_car_rounded,
    'medical_services_rounded':  Icons.medical_services_rounded,
    'home_rounded':              Icons.home_rounded,
    'fastfood_rounded':          Icons.fastfood_rounded,
    'school_rounded':            Icons.school_rounded,
    'fitness_center_rounded':    Icons.fitness_center_rounded,
    'pets_rounded':              Icons.pets_rounded,
    'flight_rounded':            Icons.flight_rounded,
    'shopping_bag_rounded':      Icons.shopping_bag_rounded,
    'sports_soccer_rounded':     Icons.sports_soccer_rounded,
    'attach_money_rounded':      Icons.attach_money_rounded,
    'music_note_rounded':        Icons.music_note_rounded,
    'work_rounded':              Icons.work_rounded,
    'wifi_rounded':              Icons.wifi_rounded,
    'phone_rounded':             Icons.phone_rounded,
    'local_gas_station_rounded': Icons.local_gas_station_rounded,
    'label_rounded':             Icons.label_rounded,
    'more_horiz_rounded':        Icons.more_horiz_rounded,
  };

  static IconData get(String? key) => all[key] ?? Icons.label_rounded;

  static List<String> get keys => all.keys.toList();
}