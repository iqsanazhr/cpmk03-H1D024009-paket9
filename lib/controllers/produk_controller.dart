import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/produk_model.dart';
import '../services/hive_service.dart';

/// CONTROLLER: Logika bisnis dan manajemen status reaktif produk UMKM.
class ProdukController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final skuC = TextEditingController();
  final namaC = TextEditingController();
  final hargaBeliC = TextEditingController();
  final hargaJualC = TextEditingController();
  final stokC = TextEditingController();
  final RxString formKategori = kategoriList.first.obs;
  final RxBool isEdit = false.obs;
  String? _editingSku;

  void openAddForm() {
    isEdit.value = false;
    _editingSku = null;
    skuC.clear();
    namaC.clear();
    hargaBeliC.clear();
    hargaJualC.clear();
    stokC.clear();
    formKategori.value = kategoriList.first;
    Get.toNamed('/form');
  }

  void openEditForm(Produk p) {
    isEdit.value = true;
    _editingSku = p.sku;
    skuC.text = p.sku;
    namaC.text = p.nama;
    hargaBeliC.text = p.hargaBeli.toStringAsFixed(0);
    hargaJualC.text = p.hargaJual.toStringAsFixed(0);
    stokC.text = p.stok.toString();
    formKategori.value = p.kategori;
    Get.toNamed('/form');
  }

  void tutup() => Get.key.currentState?.pop();

  Future<void> confirmDelete(Produk p) async {
    final yakin = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text('Yakin ingin menghapus ${p.nama}?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Hapus')),
        ],
      ),
    );
    if (yakin == true) {
      await _service.delete(p.sku);
      loadData();
      Get.snackbar('Terhapus', '${p.nama} telah dihapus', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final produk = Produk(
      sku: skuC.text.trim().toUpperCase(),
      nama: namaC.text.trim(),
      kategori: formKategori.value,
      hargaBeli: double.tryParse(hargaBeliC.text.trim()) ?? 0.0,
      hargaJual: double.tryParse(hargaJualC.text.trim()) ?? 0.0,
      stok: int.tryParse(stokC.text.trim()) ?? 0,
    );
    if (isEdit.value) {
      await _service.update(produk);
    } else {
      await _service.create(produk);
    }
    loadData();
    tutup();
    Get.snackbar('Berhasil', 'Data produk berhasil disimpan',
        snackPosition: SnackPosition.BOTTOM);
  }

  final HiveService _service = HiveService();

  final RxList<Produk> produkList = <Produk>[].obs;
  final RxString keyword = ''.obs;
  final RxString selectedKategori = 'Semua'.obs;
  final RxBool sortAscending = true.obs;

  void toggleSort() => sortAscending.value = !sortAscending.value;
  void setKategori(String k) => selectedKategori.value = k;

  List<Produk> get filteredList {
    final q = keyword.value.trim().toLowerCase();
    final kat = selectedKategori.value;
    var hasil = produkList.where((p) {
      final cocokKeyword = q.isEmpty || p.nama.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q);
      final cocokKategori = (kat == 'Semua') || (p.kategori == kat);
      return cocokKeyword && cocokKategori;
    }).toList();
    if (sortAscending.value) {
      hasil.sort((a, b) => a.hargaJual.compareTo(b.hargaJual));
    } else {
      hasil.sort((a, b) => b.hargaJual.compareTo(a.hargaJual));
    }
    return hasil;
  }


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

  double get totalNilaiStok {
    return produkList.fold(0.0, (t, p) => t + p.totalNilaiStok);
  }

  int get totalKuantitasStok {
    return produkList.fold(0, (t, p) => t + p.stok);
  }

  double get rataRataMargin {
    if (produkList.isEmpty) return 0.0;
    final totalMargin = produkList.fold(0.0, (t, p) => t + p.marginKeuntunganPersen);
    return totalMargin / produkList.length;
  }

  double get potensiLabaKumulatif {
    return produkList.fold(0.0, (t, p) => t + (p.marginKeuntunganNominal * p.stok));
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
