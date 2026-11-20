import 'package:get/get.dart';
import '../bindings/produk_binding.dart';
import '../views/produk_form_view.dart';
import '../views/produk_list_view.dart';
import '../views/splash_view.dart';
import 'app_routes.dart';

/// Konfigurasi routing terpusat dengan GetX AppPages
class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: ProdukBinding(),
    ),
    GetPage(
      name: AppRoutes.daftar,
      page: () => const ProdukListView(),
      binding: ProdukBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: AppRoutes.form,
      page: () => const ProdukFormView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
  ];
}
