import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasOnboarding {
  PreferenciasOnboarding._();
  static final PreferenciasOnboarding instancia = PreferenciasOnboarding._();

  static const _claveVisto = 'mi_oasis_onboarding_seen';

  SharedPreferences? _prefs;

  Future<void> inicializar() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> haVistoBienvenida() async {
    await inicializar();
    return _prefs?.getBool(_claveVisto) ?? false;
  }

  Future<void> marcarComoVisto() async {
    await inicializar();
    await _prefs?.setBool(_claveVisto, true);
  }

  Future<void> resetear() async {
    await inicializar();
    await _prefs?.remove(_claveVisto);
  }
}