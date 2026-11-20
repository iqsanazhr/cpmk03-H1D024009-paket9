import os
from PIL import Image, ImageDraw, ImageFont

out_dir = r"docs\video_assets\code_slices"
os.makedirs(out_dir, exist_ok=True)

def make_code_card(title, tag, lines, filename, width=1280, height=840):
    img = Image.new("RGB", (width, height), (30, 30, 30))
    draw = ImageDraw.Draw(img)

    # Header Bar
    draw.rectangle([(0, 0), (width, 54)], fill=(40, 44, 52))
    # Window buttons
    draw.ellipse([(18, 20), (30, 32)], fill=(255, 95, 86))
    draw.ellipse([(38, 20), (50, 32)], fill=(255, 189, 46))
    draw.ellipse([(58, 20), (70, 32)], fill=(39, 201, 63))

    # Title & Tag
    draw.text((90, 18), title, fill=(171, 178, 191))
    draw.rectangle([(width - 250, 12), (width - 24, 42)], fill=(0, 82, 255))
    draw.text((width - 238, 18), tag, fill=(255, 255, 255))

    # Divider
    draw.line([(0, 54), (width, 54)], fill=(55, 60, 70), width=1)

    # Code body
    y = 78
    for i, line in enumerate(lines):
        line_num = f"{i+1:2d}  "
        draw.text((24, y), line_num, fill=(92, 99, 112))
        
        # Syntax styling
        color = (220, 223, 228)
        sline = line.strip()
        if sline.startswith("//") or sline.startswith("/*") or sline.startswith("*"):
            color = (127, 132, 142)
        elif "class " in line or "extends " in line or "with " in line or "implements " in line:
            color = (229, 192, 123)
        elif line.strip().startswith("@"):
            color = (97, 175, 239)
        elif any(k in line for k in ["return ", "final ", "static ", "const ", "get ", "var ", "set "]):
            color = (198, 120, 221)
        elif any(k in line for k in ["String", "double", "int", "bool", "void", "Future", "RxList", "RxString", "RxBool", "RxInt"]):
            color = (86, 182, 194)
            
        draw.text((70, y), line, fill=color)
        y += 24
        if y > height - 35:
            break

    out_path = os.path.join(out_dir, filename)
    img.save(out_path, "PNG")
    print(f"Generated: {out_path}")

# 1. Directory Tree
tree_lines = [
    "cpmk3/ (KatalogKu - CPMK 03 Paket 9)",
    "├── lib/",
    "│   ├── bindings/",
    "│   │   └── produk_binding.dart          # Dependency Injection GetX (lazyPut)",
    "│   ├── controllers/",
    "│   │   └── produk_controller.dart        # Logika Bisnis, CRUD, .obs, & Validasi",
    "│   ├── models/",
    "│   │   ├── produk_model.dart             # Model Data Produk UMKM & Fitur Khusus 1",
    "│   │   └── produk_adapter.dart           # TypeAdapter Hive Biner (typeId: 9)",
    "│   ├── routes/",
    "│   │   ├── app_routes.dart               # Konstanta Named Routes (/splash, /daftar, /form)",
    "│   │   └── app_pages.dart                # Pendaftaran Rute GetPage & Binding",
    "│   ├── services/",
    "│   │   └── hive_service.dart             # Lapisan Akses Database Hive NoSQL (CRUD)",
    "│   ├── views/",
    "│   │   ├── widgets/",
    "│   │   │   ├── app_bottom_nav.dart       # Navigasi 3 Tab (Katalog, Analitik, Riwayat)",
    "│   │   │   ├── katalog_logo_widget.dart  # Identitas Brand Toko UMKM",
    "│   │   │   ├── produk_card_item.dart     # Kartu Produk + Margin % (Fitur Khusus 1)",
    "│   │   │   └── valuation_bento_card.dart # Bento Card Valuasi Stok (Fitur Khusus 3)",
    "│   │   ├── produk_form_view.dart         # Formulir Input & Validasi Real-Time",
    "│   │   ├── produk_list_view.dart         # Halaman Utama Katalog & Sort (Fitur Khusus 2)",
    "│   │   └── splash_view.dart              # Layar Pembuka Animasi Brand",
    "│   └── main.dart                         # Inisialisasi Hive, Adapter, & GetMaterialApp",
    "└── test/",
    "    ├── hive_service_test.dart            # 4 Unit Test CRUD & Persistensi Hive",
    "    └── produk_controller_test.dart       # 5 Unit Test Logika Fitur Khusus & Validasi",
]
make_code_card("STRUKTUR DIREKTORI PROYEK (MVC PATTERN)", "Bagian 2: MVC Structure", tree_lines, "01_tree_mvc_architecture.png")

# 2. Model & TypeAdapter
model_lines = [
    "// lib/models/produk_model.dart",
    "@HiveType(typeId: 9) // Sesuai ketentuan Paket 9 (typeId = 9 unik)",
    "class Produk extends HiveObject {",
    "  @HiveField(0) String sku;       // Format PRD-001 & unik",
    "  @HiveField(1) String nama;      // Wajib diisi, min. 3 karakter",
    "  @HiveField(2) String kategori;  // Minimal 3 kategori",
    "  @HiveField(3) double hargaBeli; // Modal HPP (> 0)",
    "  @HiveField(4) double hargaJual; // Harga jual konsumen (> hargaBeli)",
    "  @HiveField(5) int stok;         // Jumlah unit fisik (>= 0)",
    "",
    "  Produk({required this.sku, required this.nama, required this.kategori,",
    "          required this.hargaBeli, required this.hargaJual, required this.stok});",
    "",
    "  // FITUR KHUSUS 1: Margin keuntungan (%) dihitung otomatis",
    "  double get marginKeuntunganPersen {",
    "    if (hargaBeli <= 0) return 0.0;",
    "    return ((hargaJual - hargaBeli) / hargaBeli) * 100.0;",
    "  }",
    "",
    "  // Total nilai stok satuan barang (hargaBeli * stok)",
    "  double get totalNilaiStok => hargaBeli * stok;",
    "}",
    "",
    "// lib/models/produk_adapter.dart",
    "class ProdukAdapter extends TypeAdapter<Produk> {",
    "  @override final int typeId = 9;",
    "  @override Produk read(BinaryReader reader) { ... readByte() urut 0-5 ... }",
    "  @override void write(BinaryWriter writer, Produk obj) { ... writeByte() urut 0-5 ... }",
    "}",
]
make_code_card("MODEL PRODUK & TYPEADAPTER HIVE", "Bagian 3: Model & Hive", model_lines, "02_model_and_typeadapter.png")

# 3. Hive Service
service_lines = [
    "// lib/services/hive_service.dart",
    "class HiveService {",
    "  static const String boxName = 'produk_box';",
    "  Box<Produk> get _box => Hive.box<Produk>(boxName);",
    "",
    "  // 1. READ: Mengambil seluruh koleksi objek produk dari Box",
    "  List<Produk> getAll() => _box.values.toList();",
    "",
    "  // 2. READ BY SKU: Mengambil satu produk berdasarkan primary key SKU",
    "  Produk? getBySku(String sku) => _box.get(sku);",
    "",
    "  // 3. CREATE: Menyimpan produk baru dengan key SKU",
    "  Future<void> create(Produk produk) => _box.put(produk.sku, produk);",
    "",
    "  // 4. UPDATE: Memperbarui data produk pada key SKU yang sama",
    "  Future<void> update(Produk produk) => _box.put(produk.sku, produk);",
    "",
    "  // 5. DELETE: Menghapus data produk berdasarkan key SKU",
    "  Future<void> delete(String sku) => _box.delete(sku);",
    "",
    "  // 6. VALIDASI KEUNIKAN: Memeriksa apakah SKU sudah terdaftar di database",
    "  bool exists(String sku) => _box.containsKey(sku);",
    "}",
    "// Aturan Modul Terpenuhi: View sama sekali TIDAK mengakses Hive secara langsung!",
]
make_code_card("HIVE SERVICE (LAPISAN AKSES DATA TERISOLASI)", "Bagian 3: Service Layer", service_lines, "03_hive_service.png")

# 4. Controller & GetX
controller_lines = [
    "// lib/controllers/produk_controller.dart",
    "class ProdukController extends GetxController {",
    "  final HiveService _service = HiveService();",
    "",
    "  // STATE REAKTIF (.obs)",
    "  final RxList<Produk> produkList = <Produk>[].obs; // Koleksi data reaktif",
    "  final RxString keyword = ''.obs;                 // Kata kunci pencarian",
    "  final RxString selectedKategori = 'Semua'.obs;   // Filter kategori",
    "  final RxBool sortAscending = true.obs;           // Fitur Khusus 2 (Sort Harga Jual)",
    "  final RxInt activeDockTab = 0.obs;               // Tab aktif (0: Katalog, 1: Analitik)",
    "",
    "  // FITUR KHUSUS 2: Pengurutan Naik / Turun Berdasarkan Harga Jual",
    "  void toggleSort() => sortAscending.value = !sortAscending.value;",
    "",
    "  // FITUR KHUSUS 3: Total Nilai Stok (hargaBeli * stok) Tampil di Atas Daftar",
    "  double get totalNilaiStok => produkList.fold(0.0, (t, p) => t + p.totalNilaiStok);",
    "",
    "  // VALIDASI FORM SESUAI ATURAN TABEL PAKET",
    "  String? validateSku(String? v) {",
    "    if (!RegExp(r'^PRD-[0-9]{3}$').hasMatch(v!)) return 'Format wajib PRD-001';",
    "    if (!isEdit.value && _service.exists(v)) return 'SKU sudah terdaftar!';",
    "    return null;",
    "  }",
    "  String? validateHargaJual(String? v) {",
    "    final jual = double.tryParse(v ?? '') ?? 0;",
    "    final beli = double.tryParse(hargaBeliC.text) ?? 0;",
    "    if (jual <= beli) return 'Harga jual harus > harga beli (modal)!';",
    "    return null;",
    "  }",
    "  // CRUD Methods + Get.dialog konfirmasi hapus + Get.snackbar notifikasi sukses",
    "}",
]
make_code_card("PRODUK CONTROLLER & LOGIKA BISNIS GETX", "Bagian 4: Controller & GetX", controller_lines, "04_produk_controller_obs.png")

# 5. Binding & Routes
routes_lines = [
    "// lib/bindings/produk_binding.dart",
    "class ProdukBinding extends Bindings {",
    "  @override",
    "  void dependencies() {",
    "    // Lazy Put: Controller hanya diinisialisasi saat halaman dibuka",
    "    Get.lazyPut<ProdukController>(() => ProdukController());",
    "  }",
    "}",
    "",
    "// lib/routes/app_routes.dart",
    "abstract class AppRoutes {",
    "  static const splash = '/splash';",
    "  static const daftar = '/daftar';",
    "  static const form = '/form';",
    "}",
    "",
    "// lib/routes/app_pages.dart",
    "class AppPages {",
    "  static const initial = AppRoutes.splash;",
    "  static final routes = [",
    "    GetPage(name: AppRoutes.splash, page: () => const SplashView(), binding: ProdukBinding()),",
    "    GetPage(name: AppRoutes.daftar, page: () => const ProdukListView(), binding: ProdukBinding(), transition: Transition.fadeIn),",
    "    GetPage(name: AppRoutes.form, page: () => const ProdukFormView(), transition: Transition.rightToLeft),",
    "  ];",
    "}",
]
make_code_card("BINDING & NAMED ROUTES (GETX ROUTING)", "Bagian 4: Binding & Routes", routes_lines, "05_binding_and_routes.png")

# 6. View & Obx
view_lines = [
    "// lib/views/produk_list_view.dart (GetView<ProdukController>)",
    "class ProdukListView extends GetView<ProdukController> {",
    "  @override",
    "  Widget build(BuildContext context) {",
    "    return Scaffold(",
    "      appBar: _buildAppBar(context, controller),",
    "      body: Obx(() {",
    "        switch (controller.activeDockTab.value) {",
    "          case 1: return _buildTabAnalitik(context, controller);",
    "          case 2: return _buildTabRiwayat(controller);",
    "          case 0: default: return _buildTabKatalog(context, controller);",
    "        }",
    "      }),",
    "      // Sliver Bento Card (Fitur Khusus 3): Total Nilai Stok di Atas Daftar",
    "      // Filter & Sort Bar (Fitur Khusus 2): Toggle Termurah / Termahal",
    "      // Daftar Kartu Produk (Fitur Khusus 1): Margin Keuntungan (%) Otomatis",
    "    );",
    "  }",
    "}",
    "",
    "// lib/views/produk_form_view.dart",
    "class ProdukFormView extends GetView<ProdukController> {",
    "  // Form(key: controller.formKey, autovalidateMode: AutovalidateMode.onUserInteraction)",
    "  // Dynamic Live Margin Preview saat harga beli & harga jual diketik",
    "}",
]
make_code_card("VIEW & OBX REAKTIF (MODUL BAB 7 GETVIEW)", "Bagian 5: View Layer", view_lines, "06_view_obx_reactive.png")

# 7. Flutter Test Output
test_lines = [
    "$ flutter test",
    "00:00 +0: loading D:/Pemrograman Mobile/cpmk3/test/hive_service_test.dart",
    "00:00 +0: D:/Pemrograman Mobile/cpmk3/test/hive_service_test.dart: (setUpAll)",
    "00:00 +0: D:/Pemrograman Mobile/cpmk3/test/hive_service_test.dart: 1. CREATE & READ: Menambah dan membaca produk dari Hive",
    "00:00 +1: D:/Pemrograman Mobile/cpmk3/test/hive_service_test.dart: 2. UPDATE: Memperbarui data produk (harga jual dan stok)",
    "00:00 +2: D:/Pemrograman Mobile/cpmk3/test/hive_service_test.dart: 3. PERSISTENSI: Data tetap utuh setelah box ditutup & dibuka kembali",
    "00:00 +3: D:/Pemrograman Mobile/cpmk3/test/hive_service_test.dart: 4. DELETE: Menghapus data produk dari Hive",
    "00:00 +4: D:/Pemrograman Mobile/cpmk3/test/hive_service_test.dart: (tearDownAll)",
    "00:00 +4: D:/Pemrograman Mobile/cpmk3/test/produk_controller_test.dart: (setUpAll)",
    "00:00 +4: D:/Pemrograman Mobile/cpmk3/test/produk_controller_test.dart: 5. FITUR KHUSUS 1: Margin Keuntungan (%) dihitung otomatis",
    "00:00 +5: D:/Pemrograman Mobile/cpmk3/test/produk_controller_test.dart: 6. FITUR KHUSUS 2: Pengurutan berdasarkan Harga Jual (Termurah <-> Termahal)",
    "00:00 +6: D:/Pemrograman Mobile/cpmk3/test/produk_controller_test.dart: 7. FITUR KHUSUS 3: Total Nilai Stok tampil di atas daftar",
    "00:00 +7: D:/Pemrograman Mobile/cpmk3/test/produk_controller_test.dart: 8. VALIDASI FORM: SKU, Nama, Harga Beli, Harga Jual, dan Stok",
    "00:00 +8: D:/Pemrograman Mobile/cpmk3/test/produk_controller_test.dart: 9. SEARCH & FILTER: Pencarian berdasarkan Nama / SKU & Kategori",
    "00:00 +9: D:/Pemrograman Mobile/cpmk3/test/produk_controller_test.dart: (tearDownAll)",
    "00:00 +9: All tests passed!",
    "",
    "STATUS: 9/9 UNIT TEST BERHASIL LULUS 100% (SESUAI SYARAT MINIMAL 3 UNIT TEST MODUL)",
]
make_code_card("BUKTI KELULUSAN FLUTTER TEST (9/9 PASSED)", "Bagian 8: Unit Test Proof", test_lines, "07_flutter_test_passed.png")
print("All code slices generated successfully!")
