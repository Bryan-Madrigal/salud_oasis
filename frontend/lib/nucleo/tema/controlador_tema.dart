import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControladorTema extends ChangeNotifier {
  ControladorTema._();
  static final ControladorTema instancia = ControladorTema._();

  static const _claveOscuro = 'mi_oasis_tema_oscuro';

  bool _esOscuro = false;
  SharedPreferences? _prefs;

  bool get esOscuro => _esOscuro;

  Future<void> inicializar() async {
    _prefs = await SharedPreferences.getInstance();
    _esOscuro = _prefs?.getBool(_claveOscuro) ?? false;
    notifyListeners();
  }

  Future<void> alternar(bool valor) async {
    _esOscuro = valor;
    await _prefs?.setBool(_claveOscuro, valor);
    notifyListeners();
  }
}