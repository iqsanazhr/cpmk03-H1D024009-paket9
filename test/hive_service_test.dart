import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:cpmk3_paket9/models/produk_model.dart';
import 'package:cpmk3_paket9/models/produk_adapter.dart';
import 'package:cpmk3_paket9/services/hive_service.dart';

void main() {
  late Directory tempDir;
  final service = HiveService();

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_produk_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(ProdukAdapter());
    await Hive.openBox<Produk>(HiveService.boxName);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  final dummyProduk = Produk(
    sku: 'PRD-001',
    nama: 'Kripik Tempe Renyah',
    kategori: 'Makanan & Minuman',
    hargaBeli: 10000.0,
    hargaJual: 15000.0,
    stok: 25,
  );

  test('1. CREATE & READ: Menambah dan membaca produk dari Hive', () async {
    await service.create(dummyProduk);
    final all = service.getAll();
    expect(all.length, 1);
    expect(all.first.sku, 'PRD-001');
    expect(all.first.nama, 'Kripik Tempe Renyah');
    expect(all.first.stok, 25);
    // Verifikasi Fitur Khusus Paket 9
    expect(all.first.marginKeuntunganNominal, 5000.0);
    expect(all.first.marginKeuntunganPersen, 50.0);
    expect(all.first.totalNilaiStok, 250000.0);
  });

  test('2. UPDATE: Memperbarui data produk (harga jual dan stok)', () async {
    final updated = dummyProduk.copyWith(
      hargaJual: 18000.0,
      stok: 30,
    );
    await service.update(updated);

    final all = service.getAll();
    expect(all.length, 1);
    expect(all.first.hargaJual, 18000.0);
    expect(all.first.stok, 30);
    expect(all.first.marginKeuntunganNominal, 8000.0);
    expect(all.first.marginKeuntunganPersen, 80.0);
    expect(all.first.totalNilaiStok, 300000.0);
  });

  test('3. PERSISTENSI: Data tetap utuh setelah box ditutup & dibuka kembali', () async {
    await Hive.box<Produk>(HiveService.boxName).close();
    await Hive.openBox<Produk>(HiveService.boxName);

    final all = service.getAll();
    expect(all.isNotEmpty, isTrue);
    expect(all.first.sku, 'PRD-001');
    expect(all.first.hargaJual, 18000.0);
  });

  test('4. DELETE: Menghapus data produk dari Hive', () async {
    await service.delete('PRD-001');
    expect(service.getAll(), isEmpty);
    expect(service.exists('PRD-001'), isFalse);
  });
}
