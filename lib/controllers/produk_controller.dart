import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/produk_model.dart';
import '../services/hive_service.dart';

/// CONTROLLER: Logika bisnis dan manajemen status reaktif produk UMKM.
class ProdukController extends GetxController {
  final HiveService _service = HiveService();

  final RxList<Produk> produkList = <Produk>[].obs;
  final RxString keyword = ''.obs;
  final RxString selectedKategori = 'Semua'.obs;

  static const List<String> kategoriList = [
    'Makanan & Minuman',
    'Pakaian & Tekstil',
    'Kerajinan Tangan',
    'Kecantikan & Herbal',
  ];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    var data = _service.getAll();
    if (data.isEmpty) {
      _seedInitialData();
      data = _service.getAll();
    }
    produkList.assignAll(data);
  }

  void _seedInitialData() {
    _service.create(Produk(
      sku: 'PRD-001',
      nama: 'Kripik Tempe Renyah Banyumas',
      kategori: 'Makanan & Minuman',
      hargaBeli: 12000.0,
      hargaJual: 18000.0,
      stok: 45,
    ));
    _service.create(Produk(
      sku: 'PRD-002',
      nama: 'Batik Tulis Motif Klasik',
      kategori: 'Pakaian & Tekstil',
      hargaBeli: 150000.0,
      hargaJual: 225000.0,
      stok: 12,
    ));
  }
}
