import 'package:hive/hive.dart';
import '../models/produk_model.dart';

/// Lapisan akses data (Service - bagian dari MODEL pada arsitektur MVC).
/// Seluruh interaksi operasi CRUD ke database Hive dikapsulasi di sini,
/// sehingga View maupun Controller tidak menyentuh box Hive secara langsung.
class HiveService {
  static const String boxName = 'produk_box';

  /// Getter instans Box Hive yang telah dibuka
  Box<Produk> get _box => Hive.box<Produk>(boxName);

  /// READ: Mengambil seluruh koleksi objek produk
  List<Produk> getAll() => _box.values.toList();

  /// READ BY SKU: Mengambil satu produk berdasarkan primary key SKU
  Produk? getBySku(String sku) => _box.get(sku);

  /// CREATE: Menyimpan produk baru dengan primary key SKU
  Future<void> create(Produk produk) => _box.put(produk.sku, produk);

  /// UPDATE: Menimpa data produk lama pada primary key SKU yang sama
  Future<void> update(Produk produk) => _box.put(produk.sku, produk);

  /// DELETE: Menghapus data produk berdasarkan primary key SKU
  Future<void> delete(String sku) => _box.delete(sku);

  /// VALIDASI: Memeriksa apakah SKU sudah terdaftar di database
  bool exists(String sku) => _box.containsKey(sku);

  /// CLEAR: Mengosongkan data (berguna untuk testing atau reset)
  Future<int> clear() => _box.clear();
}
