import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/produk_model.dart';
import '../services/hive_service.dart';

/// CONTROLLER: Otak logika bisnis, analitik finansial UMKM, dan manajemen status reaktif.
/// Menghubungkan lapisan View dengan Service (Hive), mengelola state reaktif (.obs),
/// validasi form, sorting, log mutasi riwayat, quick restock, dan filter operasional.
class ProdukController extends GetxController {
  final HiveService _service = HiveService();

  // ------------------ STATE REAKTIF (.obs) ------------------
  /// Seluruh koleksi data produk dari database lokal Hive
  final RxList<Produk> produkList = <Produk>[].obs;

  /// Kata kunci pencarian (nama atau SKU)
  final RxString keyword = ''.obs;

  /// Filter kategori yang sedang aktif ('Semua' atau kategori spesifik)
  final RxString selectedKategori = 'Semua'.obs;

  /// Filter cepat Watchlist ('Semua Aset', 'Stok Kritis (<= 5)', 'Margin Tinggi (> 40%)', 'Valuasi Terbesar')
  final RxString watchlistFilter = 'Semua Aset'.obs;

  /// Fitur Khusus 2: Pengurutan berdasarkan harga jual (true: Ascending / Termurah, false: Descending / Termahal)
  final RxBool sortAscending = true.obs;

  /// Tab aktif pada Bottom Navigation Bar (0: Katalog, 1: Analitik, 2: Riwayat)
  final RxInt activeDockTab = 0.obs;

  /// Log mutasi aktivitas transaksi katalog
  final RxList<Map<String, dynamic>> activityLogs = <Map<String, dynamic>>[].obs;

  /// Daftar pilihan kategori baku (minimal 3 kategori sesuai instruksi paket)
  static const List<String> kategoriList = [
    'Makanan & Minuman',
    'Pakaian & Tekstil',
    'Kerajinan Tangan',
    'Kecantikan & Herbal',
  ];

  // ------------------ STATE FORM & VALIDASI ------------------
  final formKey = GlobalKey<FormState>();
  final skuC = TextEditingController();
  final namaC = TextEditingController();
  final hargaBeliC = TextEditingController();
  final hargaJualC = TextEditingController();
  final stokC = TextEditingController();

  /// Kategori yang dipilih pada form tambah/edit
  final RxString formKategori = kategoriList.first.obs;

  /// Satuan kemasan (Retail / Lusin / Box)
  final RxString formKemasan = 'Retail (Pcs)'.obs;

  /// Penanda apakah sedang dalam mode edit atau tambah baru
  final RxBool isEdit = false.obs;

  /// Menyimpan SKU lama saat mode edit untuk validasi keunikan
  String? _editingSku;

  @override
  void onInit() {
    super.onInit();
    loadData();
    _initInitialLogs();
  }

  // ------------------ READ & FILTER LOGIC ------------------
  /// Memuat data terbaru dari HiveService ke dalam RxList
  void loadData() {
    var data = _service.getAll();
    if (data.isEmpty) {
      _seedInitialData();
      data = _service.getAll();
    }
    produkList.assignAll(data);
  }

  /// Data awal untuk mendemonstrasikan katalog produk UMKM secara realistis
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
    _service.create(Produk(
      sku: 'PRD-003',
      nama: 'Tas Anyaman Bambu Alami',
      kategori: 'Kerajinan Tangan',
      hargaBeli: 35000.0,
      hargaJual: 55000.0,
      stok: 20,
    ));
    _service.create(Produk(
      sku: 'PRD-004',
      nama: 'Minyak Atsiri Sereh Wangi 100ml',
      kategori: 'Kecantikan & Herbal',
      hargaBeli: 40000.0,
      hargaJual: 65000.0,
      stok: 3, // Stok kritis untuk mendemonstrasikan alert restock
    ));
  }

  void _initInitialLogs() {
    if (activityLogs.isEmpty) {
      activityLogs.addAll([
        {
          'title': 'Katalog Diinisialisasi',
          'desc': 'Database lokal Hive berhasil memuat 4 produk awal.',
          'type': 'system',
          'time': DateTime.now().subtract(const Duration(minutes: 15)),
        },
        {
          'title': 'Restock Alert Terdeteksi',
          'desc': 'Minyak Atsiri Sereh Wangi (PRD-004) memiliki sisa stok 3 unit.',
          'type': 'warning',
          'time': DateTime.now().subtract(const Duration(minutes: 5)),
        },
      ]);
    }
  }

  void addActivityLog(String title, String desc, String type) {
    activityLogs.insert(0, {
      'title': title,
      'desc': desc,
      'type': type,
      'time': DateTime.now(),
    });
    if (activityLogs.length > 50) {
      activityLogs.removeLast();
    }
  }

  /// Getter daftar produk terfilter dan terurut (Fitur Khusus 2, Kategori, & Watchlist)
  List<Produk> get filteredList {
    final q = keyword.value.trim().toLowerCase();
    final kat = selectedKategori.value;
    final wl = watchlistFilter.value;

    var hasil = produkList.where((p) {
      final cocokKeyword = q.isEmpty ||
          p.nama.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q);

      final cocokKategori = (kat == 'Semua') || (p.kategori == kat);

      bool cocokWatchlist = true;
      if (wl == 'Stok Kritis (<= 5)') {
        cocokWatchlist = p.stok <= 5;
      } else if (wl == 'Margin Tinggi (> 40%)') {
        cocokWatchlist = p.marginKeuntunganPersen > 40.0;
      }

      return cocokKeyword && cocokKategori && cocokWatchlist;
    }).toList();

    // Watchlist Sort atau Fitur Khusus 2: Urutkan berdasarkan harga jual
    if (wl == 'Valuasi Terbesar') {
      hasil.sort((a, b) => b.totalNilaiStok.compareTo(a.totalNilaiStok));
    } else {
      if (sortAscending.value) {
        hasil.sort((a, b) => a.hargaJual.compareTo(b.hargaJual));
      } else {
        hasil.sort((a, b) => b.hargaJual.compareTo(a.hargaJual));
      }
    }

    return hasil;
  }

  /// Fitur Khusus 3: Total nilai stok seluruh produk (hargaBeli * stok)
  double get totalNilaiStok {
    return produkList.fold(0.0, (total, p) => total + p.totalNilaiStok);
  }

  /// Total kuantitas unit produk yang tersedia
  int get totalKuantitasStok {
    return produkList.fold(0, (total, p) => total + p.stok);
  }

  /// Rata-rata margin keuntungan seluruh katalog UMKM (%)
  double get rataRataMargin {
    if (produkList.isEmpty) return 0.0;
    final totalMargin =
        produkList.fold(0.0, (total, p) => total + p.marginKeuntunganPersen);
    return totalMargin / produkList.length;
  }

  /// Jumlah produk dengan stok kritis (<= 5 unit)
  int get criticalStockCount {
    return produkList.where((p) => p.stok <= 5).length;
  }

  /// Daftar produk dengan stok kritis (<= 5 unit)
  List<Produk> get criticalStockList {
    return produkList.where((p) => p.stok <= 5).toList();
  }

  /// Proyeksi Laba Bersih Potensial (Total Jual - Total Modal)
  double get potensiLabaKumulatif {
    return produkList.fold(0.0, (total, p) => total + (p.marginKeuntunganNominal * p.stok));
  }

  /// Status Progres 4 Langkah Setup Toko UMKM
  Map<String, bool> get setupStepsStatus {
    final hasEnoughProducts = produkList.length >= 4;
    final uniqueCats = produkList.map((p) => p.kategori).toSet().length;
    final hasMultiCategory = uniqueCats >= 3;
    final hasHealthyMargin = produkList.isNotEmpty &&
        produkList.every((p) => p.marginKeuntunganPersen >= 20.0);
    final hasSafeStock = produkList.isNotEmpty &&
        produkList.every((p) => p.stok > 3);

    return {
      'hasProducts': hasEnoughProducts,
      'hasMultiCategory': hasMultiCategory,
      'hasHealthyMargin': hasHealthyMargin,
      'hasSafeStock': hasSafeStock,
    };
  }

  int get setupStepsCompletedCount {
    final status = setupStepsStatus;
    return status.values.where((v) => v).length;
  }

  // ------------------ TOGGLE & FILTER ------------------
  /// Mengubah urutan harga jual antara termurah dan termahal
  void toggleSort() {
    sortAscending.value = !sortAscending.value;
  }

  /// Memilih filter kategori
  void setKategori(String kategori) {
    selectedKategori.value = kategori;
  }

  /// Memilih filter cepat Watchlist
  void setWatchlistFilter(String filter) {
    watchlistFilter.value = filter;
  }

  // ------------------ QUICK RESTOCK ------------------
  Future<void> quickRestock(Produk p, int amount) async {
    final updated = p.copyWith(stok: p.stok + amount);
    await _service.update(updated);
    loadData();
    addActivityLog(
      'Restock Persediaan',
      'Stok ${p.nama} ditambah $amount unit (total sekarang ${updated.stok} unit).',
      'restock',
    );

    Get.snackbar(
      'Stok Ditambahkan',
      'Stok ${p.nama} bertambah +$amount unit.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0052FF),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.inventory_rounded, color: Colors.white),
    );
  }

  // ------------------ NAVIGASI FORM ------------------
  /// Membuka form dalam mode Tambah Produk Baru
  void openAddForm() {
    isEdit.value = false;
    _editingSku = null;
    skuC.clear();
    namaC.clear();
    hargaBeliC.clear();
    hargaJualC.clear();
    stokC.clear();
    formKategori.value = kategoriList.first;
    formKemasan.value = 'Retail (Pcs)';
    Get.toNamed('/form');
  }

  /// Membuka form dalam mode Edit Produk
  void openEditForm(Produk p) {
    isEdit.value = true;
    _editingSku = p.sku;
    skuC.text = p.sku;
    namaC.text = p.nama;
    hargaBeliC.text = p.hargaBeli.toStringAsFixed(0);
    hargaJualC.text = p.hargaJual.toStringAsFixed(0);
    stokC.text = p.stok.toString();
    formKategori.value =
        kategoriList.contains(p.kategori) ? p.kategori : kategoriList.first;
    formKemasan.value = 'Retail (Pcs)';
    Get.toNamed('/form');
  }

  /// Navigasi kembali ke daftar secara aman
  void tutup() {
    Get.key.currentState?.pop();
  }

  // ------------------ CREATE & UPDATE ------------------
  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    final sku = skuC.text.trim().toUpperCase();
    final nama = namaC.text.trim();
    final kategori = formKategori.value;
    final hargaBeli = double.tryParse(hargaBeliC.text.trim()) ?? 0.0;
    final hargaJual = double.tryParse(hargaJualC.text.trim()) ?? 0.0;
    final stok = int.tryParse(stokC.text.trim()) ?? 0;

    final produk = Produk(
      sku: sku,
      nama: nama,
      kategori: kategori,
      hargaBeli: hargaBeli,
      hargaJual: hargaJual,
      stok: stok,
    );

    if (isEdit.value) {
      await _service.update(produk);
      addActivityLog(
        'Produk Diperbarui',
        'Data $nama ($sku) berhasil diubah. Margin: +${produk.marginKeuntunganPersen.toStringAsFixed(1)}%.',
        'update',
      );
    } else {
      await _service.create(produk);
      addActivityLog(
        'Produk Baru Ditambahkan',
        '$nama ($sku) ditambahkan ke katalog dengan stok $stok unit.',
        'create',
      );
    }

    loadData();
    tutup();

    final pesan = isEdit.value
        ? 'Produk $nama berhasil diperbarui'
        : 'Produk $nama berhasil ditambahkan';

    Get.snackbar(
      'Berhasil',
      pesan,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0052FF),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
    );
  }

  // ------------------ DELETE DENGAN DIALOG KONFIRMASI ------------------
  Future<void> confirmDelete(Produk p) async {
    final yakin = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFDE8E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDF1B41), size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Hapus Produk?',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0A0B0D)),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus produk "${p.nama}" (${p.sku})?\nData stok dan nilai aset akan dihapus permanen dari Hive.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF5B616E), height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5B616E),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                    onPressed: () => Get.back(result: false),
                    child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDF1B41),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                    onPressed: () => Get.back(result: true),
                    child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (yakin == true) {
      await _service.delete(p.sku);
      addActivityLog(
        'Produk Dihapus',
        'Produk ${p.nama} (${p.sku}) telah dihapus dari katalog.',
        'delete',
      );
      loadData();
      Get.snackbar(
        'Terhapus',
        'Produk ${p.nama} (${p.sku}) telah dihapus dari katalog',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0A0B0D),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // ------------------ EKSPOR DATA & RESET ------------------
  String exportJsonData() {
    final list = produkList.map((p) => {
      'sku': p.sku,
      'nama': p.nama,
      'kategori': p.kategori,
      'hargaBeli': p.hargaBeli,
      'hargaJual': p.hargaJual,
      'stok': p.stok,
      'marginNominal': p.marginKeuntunganNominal,
      'marginPersen': p.marginKeuntunganPersen,
      'totalNilaiStok': p.totalNilaiStok,
    }).toList();

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      'aplikasi': 'KatalogKu UMKM',
      'totalProduk': produkList.length,
      'totalValuasi': totalNilaiStok,
      'rataRataMargin': rataRataMargin,
      'eksporWaktu': DateTime.now().toIso8601String(),
      'produk': list,
    });
  }

  Future<void> resetSeedData() async {
    final all = _service.getAll();
    for (var p in all) {
      await _service.delete(p.sku);
    }
    _seedInitialData();
    loadData();
    addActivityLog(
      'Reset Data Contoh',
      'Database Hive berhasil di-reset ke 4 produk contoh UMKM default.',
      'system',
    );
    Get.snackbar(
      'Data Di-reset',
      'Katalog telah dikembalikan ke 4 produk contoh default.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0052FF),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }

  // ------------------ VALIDATOR FORM (SESUAI ATURAN PAKET 9) ------------------
  /// Aturan SKU: Unik, format PRD-001 (misal PRD-001, PRD-123)
  String? validateSku(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'SKU wajib diisi';
    }
    final v = value.trim().toUpperCase();
    final formatValid = RegExp(r'^PRD-\d{3,}$').hasMatch(v);
    if (!formatValid) {
      return 'Format SKU harus PRD-001 (contoh: PRD-001, PRD-025)';
    }

    if (!isEdit.value || (_editingSku != null && _editingSku != v)) {
      if (_service.exists(v)) {
        return 'SKU $v sudah digunakan oleh produk lain';
      }
    }
    return null;
  }

  /// Aturan Nama: Wajib diisi (minimal 3 karakter)
  String? validateNama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama produk wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama produk minimal 3 karakter';
    }
    return null;
  }

  /// Aturan Harga Beli: > 0
  String? validateHargaBeli(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harga beli wajib diisi';
    }
    final numVal = double.tryParse(value.trim());
    if (numVal == null) {
      return 'Harga beli harus berupa angka';
    }
    if (numVal <= 0) {
      return 'Harga beli harus lebih besar dari 0';
    }
    return null;
  }

  /// Aturan Harga Jual: Harus > Harga Beli
  String? validateHargaJual(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harga jual wajib diisi';
    }
    final numVal = double.tryParse(value.trim());
    if (numVal == null) {
      return 'Harga jual harus berupa angka';
    }

    final hargaBeli = double.tryParse(hargaBeliC.text.trim()) ?? 0.0;
    if (numVal <= hargaBeli) {
      return 'Harga jual (Rp ${numVal.toStringAsFixed(0)}) harus lebih besar dari modal beli (Rp ${hargaBeli.toStringAsFixed(0)})';
    }
    return null;
  }

  /// Aturan Stok: >= 0
  String? validateStok(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Stok wajib diisi';
    }
    final intVal = int.tryParse(value.trim());
    if (intVal == null) {
      return 'Stok harus berupa bilangan bulat';
    }
    if (intVal < 0) {
      return 'Stok tidak boleh negatif (minimal 0)';
    }
    return null;
  }

  @override
  void onClose() {
    skuC.dispose();
    namaC.dispose();
    hargaBeliC.dispose();
    hargaJualC.dispose();
    stokC.dispose();
    super.onClose();
  }
}
