import 'package:get/get.dart';
import '../controllers/produk_controller.dart';

/// BINDING: Dependency Injection GetX
/// Mendaftarkan ProdukController dengan lazyPut sehingga controller
/// hanya dibuat saat dibutuhkan dan otomatis dilepas saat rute dihancurkan.
class ProdukBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProdukController>(() => ProdukController());
  }
}
