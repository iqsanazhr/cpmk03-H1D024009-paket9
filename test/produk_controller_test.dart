import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:cpmk3_paket9/models/produk_model.dart';
import 'package:cpmk3_paket9/models/produk_adapter.dart';
import 'package:cpmk3_paket9/services/hive_service.dart';
import 'package:cpmk3_paket9/controllers/produk_controller.dart';

void main() {
  late Directory tempDir;
  late ProdukController controller;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_controller_test');
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

  setUp(() {
    controller = ProdukController();
    controller.loadData();
  });

  test('5. FITUR KHUSUS 1: Margin Keuntungan (%) dihitung otomatis', () {
    final p = controller.produkList.firstWhere((item) => item.sku == 'PRD-001');
    // Beli: 12.000, Jual: 18.000 -> Margin: (6.000 / 12.000) * 100% = 50.0%
    expect(p.marginKeuntunganNominal, 6000.0);
    expect(p.marginKeuntunganPersen, 50.0);
  });

  test('6. FITUR KHUSUS 2: Pengurutan berdasarkan Harga Jual (Termurah <-> Termahal)', () {
    // Default: sortAscending = true (Termurah)
    controller.sortAscending.value = true;
    var list = controller.filteredList;
    for (int i = 0; i < list.length - 1; i++) {
      expect(list[i].hargaJual <= list[i + 1].hargaJual, isTrue);
    }

    // Toggle ke Termahal (Descending)
    controller.toggleSort();
    expect(controller.sortAscending.value, isFalse);
    list = controller.filteredList;
    for (int i = 0; i < list.length - 1; i++) {
      expect(list[i].hargaJual >= list[i + 1].hargaJual, isTrue);
    }
  });

  test('7. FITUR KHUSUS 3: Total Nilai Stok tampil di atas daftar', () {
    // Total nilai stok = sum(hargaBeli * stok)
    final expectedTotal = controller.produkList.fold(
      0.0,
      (sum, p) => sum + (p.hargaBeli * p.stok),
    );
    expect(controller.totalNilaiStok, expectedTotal);
    expect(controller.totalNilaiStok > 0, isTrue);
  });

  test('8. VALIDASI FORM: SKU, Nama, Harga Beli, Harga Jual, dan Stok', () {
    // Validasi SKU
    expect(controller.validateSku(''), 'SKU wajib diisi');
    expect(controller.validateSku('INVALID-1'), 'Format SKU harus PRD-001 (contoh: PRD-001, PRD-025)');
    expect(controller.validateSku('PRD-999'), isNull);

    // Validasi Nama
    expect(controller.validateNama(''), 'Nama produk wajib diisi');
    expect(controller.validateNama('AB'), 'Nama produk minimal 3 karakter');
    expect(controller.validateNama('Batik Tulis'), isNull);

    // Validasi Harga Beli
    expect(controller.validateHargaBeli(''), 'Harga beli wajib diisi');
    expect(controller.validateHargaBeli('0'), 'Harga beli harus lebih besar dari 0');
    expect(controller.validateHargaBeli('25000'), isNull);

    // Validasi Harga Jual vs Beli
    controller.hargaBeliC.text = '25000';
    expect(controller.validateHargaJual('20000'), contains('harus lebih besar dari modal beli'));
    expect(controller.validateHargaJual('35000'), isNull);

    // Validasi Stok
    expect(controller.validateStok(''), 'Stok wajib diisi');
    expect(controller.validateStok('-5'), 'Stok tidak boleh negatif (minimal 0)');
    expect(controller.validateStok('10'), isNull);
  });

  test('9. SEARCH & FILTER: Pencarian berdasarkan Nama / SKU & Kategori', () {
    // Pencarian SKU
    controller.keyword.value = 'PRD-001';
    expect(controller.filteredList.length, 1);
    expect(controller.filteredList.first.sku, 'PRD-001');

    // Pencarian Nama
    controller.keyword.value = 'Batik';
    expect(controller.filteredList.length, 1);
    expect(controller.filteredList.first.nama, contains('Batik'));

    // Filter Kategori
    controller.keyword.value = '';
    controller.setKategori('Makanan & Minuman');
    for (var p in controller.filteredList) {
      expect(p.kategori, 'Makanan & Minuman');
    }
  });
}
