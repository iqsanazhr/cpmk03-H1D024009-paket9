# 🎬 PANDUAN STORYBOARD & NASKAH REKAMAN VIDEO CPMK 03
## Katalog Produk UMKM — Paket 9 (NIM Berakhiran 9)

---

### 📋 Metadata & Ketentuan Resmi Video YouTube
* **Judul Video Resmi**: `CPMK 03 - Paket 9 - Iqsan Azhar Nuryadi - H1D024009`
* **Mata Kuliah**: Pemrograman Mobile (IF21507 Kelas A)
* **Program Studi**: S1 Informatika — Universitas Jenderal Soedirman (UNSOED)
* **Dosen Pengampu**: Mohammad Irham, S.Kom., M.Cs.
* **Format Unggah**: YouTube (Visibilitas: **Unlisted** atau **Public**, dilarang *Private*)
* **Durasi Target**: **5 Menit 30 Detik** (330 Detik — Memenuhi syarat batas minimal $\ge$ 5 menit)
* **Resolusi & Frame Rate**: Full HD (1920x1080) @ 60 FPS
* **Layout Rekaman yang Disarankan**: Split-screen (Sisi kiri: Visual Studio Code, Sisi kanan: Layar HP/Emulator Aplikasi KatalogKu)

---

## ⏱️ TABEL TIMELINE & RENCANA DURASI 8 BAGIAN

| No | Bagian Video | Rentang Waktu | Durasi | Aset Visual Mentahan | Fokus Bahasan |
|:---:|:---|:---:|:---:|:---|:---|
| **1** | **Pembuka** | `00:00 - 00:25` | 25 detik | `00_splash.png`, Mockup Panorama | Perkenalan identitas mahasiswa, NIM, paket soal, dan latar belakang studi kasus UMKM. |
| **2** | **Struktur MVC** | `00:25 - 01:00` | 35 detik | `01_tree_mvc_architecture.png` | Penjelasan struktur folder 6 lapisan arsitektur MVC dan isolasi View dari Hive. |
| **3** | **Model & Hive** | `01:00 - 01:45` | 45 detik | `02_model_and_typeadapter.png`, `03_hive_service.png` | Model `Produk`, `ProdukAdapter` (`typeId = 9`, read/write biner), dan `HiveService` (CRUD). |
| **4** | **Controller & GetX** | `01:45 - 02:35` | 50 detik | `04_produk_controller_obs.png`, `05_binding_and_routes.png` | Variabel reaktif `.obs`, method CRUD, validasi regex SKU & harga, `Get.dialog`, `Get.snackbar`, Named Routes & Binding. |
| **5** | **View (UI)** | `02:35 - 03:20` | 45 detik | `06_view_obx_reactive.png`, `real_katalog.png`, `real_form.png` | Pewarisan `GetView<ProdukController>`, reaktivitas widget `Obx`, CustomScrollView, dan Form terstruktur. |
| **6** | **Demo CRUD & Validasi** | `03:20 - 04:15` | 55 detik | `clip_02_demo_crud_dan_validasi.mp4` | Simulasi validasi gagal saat kosong/harga jual $\le$ modal, tambah produk baru, cari kata kunci, edit data, dan konfirmasi hapus. |
| **7** | **Demo Fitur Khusus** | `04:15 - 04:55` | 40 detik | `clip_03_demo_fitur_khusus_paket9.mp4` | Pembuktian Fitur Khusus 1 (Margin %), Fitur Khusus 2 (Sort Termurah/Termahal), dan Fitur Khusus 3 (Total Nilai Stok Bento Card). |
| **8** | **Bukti Persistensi & Test** | `04:55 - 05:30` | 35 detik | `clip_04_bukti_persistensi.mp4`, `07_flutter_test_passed.png` | Bukti persistensi Hive (cold restart aplikasi data tetap utuh) dan eksekusi `flutter test` lulus 100% (9/9 passed). |

---

## 🎙️ NASKAH NARASI KATA DEMI KATA (WORD-BY-WORD VOICEOVER SCRIPT)

### BAGIAN 1: PEMBUKA (`00:00 - 00:25`)
* **Visual di Layar**: Tampilkan kamera wajah (picture-in-picture) bersama layar pembuka (*Splash Screen*) aplikasi KatalogKu yang berwarna Royal Blue bersih dan judul presentasi.
* **Aset File**: `docs/mockups/real_splash.png` dan `docs/app_showcase_grid.png`.
* **Naskah Narasi**:
  > *"Halo semuanya, perkenalkan saya **Iqsan Azhar Nuryadi**, dengan NIM **H1D024009**, mahasiswa Program Studi S1 Informatika, Fakultas Teknik, Universitas Jenderal Soedirman.*
  >
  > *Pada video kali ini, saya akan mendemonstrasikan implementasi tugas akhir evaluasi **CPMK 03 Pemrograman Mobile Kelas A**, di mana berdasarkan digit terakhir NIM saya yaitu angka 9, saya mengerjakan **Paket 9: Katalog Produk UMKM**.*
  >
  > *Aplikasi yang saya bangun bernama **KatalogKu**, sebuah solusi digital yang memfasilitasi pelaku UMKM untuk mencatat produk, mengendalikan stok fisik, menetapkan harga, serta menghitung margin keuntungan dan total valuasi aset secara otomatis dan persisten."*

---

### BAGIAN 2: STRUKTUR ARSITEKTUR MVC (`00:25 - 01:00`)
* **Visual di Layar**: Tampilkan jendela Visual Studio Code, sorot panel *Explorer* di sebelah kiri yang memperlihatkan hierarki folder `lib/`.
* **Aset File**: `docs/video_assets/code_slices/01_tree_mvc_architecture.png`.
* **Naskah Narasi**:
  > *"Kita mulai dari struktur arsitektur proyek. Sesuai dengan standarisasi praktikum Modul Bab 7, aplikasi ini menerapkan pola arsitektur **Model-View-Controller (MVC)** yang bersih dan terisolasi.*
  >
  > *Mari kita perhatikan susunan direktori pada folder `lib`:*
  > 1. *Pertama, folder **`models/`**, menampung entitas data produk dan serializer TypeAdapter Hive biner.*
  > 2. *Kedua, folder **`services/`**, mengkapsulasi seluruh akses database Hive NoSQL sehingga View tidak pernah menyentuh database secara langsung.*
  > 3. *Ketiga, folder **`controllers/`**, menjadi otak pengendali logika bisnis, kalkulasi finansial, dan *state management* reaktif menggunakan GetX.*
  > 4. *Keempat, folder **`views/`**, berisi antarmuka pengguna berbasis `GetView` yang hanya bertugas me-render widget secara reaktif melalui `Obx`.*
  > 5. *Kelima, folder **`bindings/`**, mengelola dependency injection melalui `Get.lazyPut`.*
  > 6. *Dan keenam, folder **`routes/`**, mengatur navigasi rute bernama terpusat (*named routes*).*
  >
  > *Struktur ini menjamin kode terstruktur rapi, *scalable*, dan mudah diuji."*

---

### BAGIAN 3: MODEL & DATABASE HIVE (`01:00 - 01:45`)
* **Visual di Layar**: Buka file `lib/models/produk_model.dart`, lalu beralih ke `lib/models/produk_adapter.dart` dan `lib/services/hive_service.dart`.
* **Aset File**: `docs/video_assets/code_slices/02_model_and_typeadapter.png` dan `03_hive_service.png`.
* **Naskah Narasi**:
  > *"Selanjutnya, mari kita bedah lapisan data model dan penyimpanan lokal Hive.*
  >
  > *Pada file `produk_model.dart`, kelas `Produk` didaftarkan dengan anotasi `@HiveType(typeId: 9)`. Angka 9 ini unik dan merepresentasikan identitas Paket 9. Terdapat enam atribut wajib: `sku` bertipe String, `nama` bertipe String, `kategori` bertipe String, `hargaBeli` bertipe double, `hargaJual` bertipe double, dan `stok` bertipe integer.*
  >
  > *Di dalam model ini juga tertanam implementasi **Fitur Khusus 1**, yaitu *getter* `marginKeuntunganPersen` yang menghitung rasio laba secara otomatis menggunakan rumus `((hargaJual - hargaBeli) / hargaBeli) * 100%`.*
  >
  > *Untuk serialisasi data, kita menggunakan `ProdukAdapter` pada file `produk_adapter.dart`. Adapter ini membaca dan menulis field biner secara berurutan dari indeks 0 hingga 5, sehingga kompatibel dengan format penyimpanan Hive.*
  >
  > *Seluruh operasi database kemudian dikapsulasi di dalam `HiveService`. Terdapat metode `getAll()`, `getBySku()`, `create()`, `update()`, `delete()`, dan `exists()` untuk memeriksa keunikan SKU. Tidak ada satu pun baris kode di View yang mengakses box Hive secara langsung."*

---

### BAGIAN 4: CONTROLLER & GETX REAKTIVITAS (`01:45 - 02:35`)
* **Visual di Layar**: Buka file `lib/controllers/produk_controller.dart`, scroll menunjukkan variabel `.obs`, metode validasi, dan rute di `app_pages.dart`.
* **Aset File**: `docs/video_assets/code_slices/04_produk_controller_obs.png` dan `05_binding_and_routes.png`.
* **Naskah Narasi**:
  > *"Sekarang kita beralih ke lapisan logika bisnis di `ProdukController` yang mewarisi `GetxController`.*
  >
  > *Di sini kita mendefinisikan beberapa variabel reaktif menggunakan akhiran `.obs`, seperti `produkList` berupa `RxList<Produk>`, `keyword` untuk pencarian, `selectedKategori` untuk filter kategori, dan `sortAscending` bertipe `RxBool` untuk mengendalikan **Fitur Khusus 2**, yaitu pengurutan harga.*
  >
  > *Untuk **Fitur Khusus 3**, terdapat getter `totalNilaiStok` yang mengkalkulasi akumulasi modal gudang melalui fungsi `fold` dengan rumus `hargaBeli * stok`.*
  >
  > *Validasi form juga dikontrol penuh di controller:*
  > * *SKU divalidasi dengan regular expression wajib berformat `PRD-` diikuti 3 digit angka, serta diverifikasi keunikannya di Hive.*
  > * *Nama wajib diisi minimal 3 karakter.*
  > * *Harga beli wajib lebih besar dari 0.*
  > * *Dan harga jual wajib lebih tinggi dari harga beli modal.*
  >
  > *Controller ini juga mengintegrasikan interaksi GetX seperti dialog konfirmasi `Get.dialog()` saat menghapus produk dan notifikasi feedback `Get.snackbar()` saat transaksi berhasil.*
  >
  > *Semua ini di-inject secara efisien melalui `ProdukBinding` menggunakan `Get.lazyPut` dan didaftarkan pada named routes di `AppPages`."*

---

### BAGIAN 5: VIEW (ANTARMUKA PENGGUNA) (`02:35 - 03:20`)
* **Visual di Layar**: Tampilkan kode `lib/views/produk_list_view.dart` dan `produk_form_view.dart`, berdampingan dengan tampilan aplikasi yang sedang aktif.
* **Aset File**: `docs/video_assets/code_slices/06_view_obx_reactive.png`, `real_katalog.png`, dan `real_form.png`.
* **Naskah Narasi**:
  > *"Masuk ke lapisan antarmuka pengguna (*View*).*
  >
  > *Halaman utama `ProdukListView` meng-extend `GetView<ProdukController>`. Mengikuti kaidah resmi modul praktikum, seluruh komponen yang reaktif dibungkus dengan widget `Obx` sehingga antarmuka akan ter-render ulang secara otomatis dan instan saat nilai `.obs` di controller berubah tanpa perlu memanggil `setState` manual.*
  >
  > *Layar ini tersusun secara terstruktur menggunakan `CustomScrollView`:*
  > * *Di bagian paling atas, terdapat **Valuation Bento Card** yang menyajikan total nilai persediaan gudang (Fitur Khusus 3), estimasi laba kas, rata-rata margin, serta diagram proporsi sebaran kategori.*
  > * *Di bawahnya terdapat *Search Bar* instan dan tombol toggle *Urutkan Harga Jual* (Fitur Khusus 2).*
  > * *Kemudian chip filter kategori horizontal.*
  > * *Dan daftar kartu produk di mana setiap kartu menampilkan label SKU, kategori, stok fisik, serta badge pill persentase margin keuntungan (Fitur Khusus 1).*
  >
  > *Sedangkan halaman `ProdukFormView` dirancang sebagai formulir native terpadu yang dilengkapi kalkulasi live margin preview dan stepper penyesuaian stok cepat."*

---

### BAGIAN 6: DEMO CRUD LENGKAP & VALIDASI FORM (`03:20 - 04:15`)
* **Visual di Layar**: Putar rekaman layar interaksi aplikasi secara langsung (*full live demonstration*).
* **Aset File**: `docs/video_assets/raw_clips/clip_02_demo_crud_dan_validasi.mp4`.
* **Naskah Narasi**:
  > *"Mari kita saksikan demonstrasi fungsionalitas CRUD secara menyeluruh beserta pembuktian validasi form.*
  >
  > *Pertama, saya menekan tombol **Tambah Produk**. Jika formulir dikirim dalam kondisi kosong, sistem validasi langsung aktif: muncul pesan error merah pada SKU, nama, harga, dan stok.*
  >
  > *Sekarang mari kita uji validasi logika harga: saya masukkan SKU `PRD-005`, nama `Kopi Robusta Banyumas 250g`, kategori `Makanan & Minuman`, modal beli Rp 30.000, tetapi harga jual saya isi Rp 20.000—lebih murah dari modal. Sistem secara tegas menolak dan memunculkan pesan: 'Harga jual harus lebih besar dari modal!'.*
  >
  > *Setelah harga jual saya perbaiki menjadi Rp 45.000, indikator margin langsung menghitung otomatis keuntungan +50.0%. Kita isi stok 25 unit lalu klik Simpan. Muncul snackbar GetX hijau, dan produk baru langsung terdaftar di katalog.*
  >
  > *Kedua, kita uji fitur pencarian: saya ketik 'Robusta' di search bar, katalog menyaring data seketika.*
  >
  > *Ketiga, operasi Ubah: saya edit produk ini, menaikkan harga jual menjadi Rp 50.000. Tersimpan sukses dan margin otomatis naik menjadi +66.7%.*
  >
  > *Keempat, operasi Hapus: saat tombol hapus ditekan, muncul `Get.dialog` konfirmasi untuk mencegah ketidaksengajaan. Begitu dikonfirmasi, produk terhapus bersih dari basis data."*

---

### BAGIAN 7: DEMO SELURUH FITUR KHUSUS PAKET 9 (`04:15 - 04:55`)
* **Visual di Layar**: Sorot secara mendalam ketiga fitur khusus paket 9 secara berurutan.
* **Aset File**: `docs/video_assets/raw_clips/clip_03_demo_fitur_khusus_paket9.mp4`.
* **Naskah Narasi**:
  > *"Sekarang mari kita review pemenuhan seluruh **Fitur Khusus Paket 9**:*
  >
  > 1. *Yang pertama, **Margin Keuntungan (%) Dihitung Otomatis**: Setiap kartu barang di katalog memiliki badge hijau emerald yang menampilkan persentase margin secara presisi, misalnya `+50.0%` pada Kripik Tempe, `+57.1%` pada Tas Anyaman, dan seterusnya.*
  > 2. *Yang kedua, **Urutkan Berdasarkan Harga Jual**: Di samping kolom pencarian, terdapat tombol toggle. Saat ditekan, katalog seketika mengurutkan data dari **Termurah** mulai Rp 18.000 hingga Rp 225.000. Ditekan sekali lagi, urutan langsung berbalik menjadi **Termahal** tanpa ada jeda atau reload halaman.*
  > 3. *Dan yang ketiga, **Total Nilai Stok Tampil di Atas Daftar**: Di bagian atas layar, Bento Card Valuasi menampilkan akumulasi modal persediaan sebesar **Rp 3.160.000**, dihitung dari perkalian harga beli dan sisa stok seluruh produk, lengkap dengan breakdown proporsi per sektor usaha UMKM.*
  >
  > *Seluruh fitur khusus Paket 9 telah terpenuhi 100% secara sempurna."*

---

### BAGIAN 8: BUKTI PERSISTENSI DATA & HASIL UNIT TEST (`04:55 - 05:30`)
* **Visual di Layar**: Tampilkan penutupan dan pembukaan kembali aplikasi (refresh / cold start), dilanjutkan dengan eksekusi perintah terminal `flutter test`.
* **Aset File**: `docs/video_assets/raw_clips/clip_04_bukti_persistensi.mp4` dan `07_flutter_test_passed.png`.
* **Naskah Narasi**:
  > *"Sebagai pembuktian keandalan sistem, kita masuk ke tahap pengujian persistensi data dan unit test.*
  >
  > *Pertama, bukti persistensi: Saya tutup aplikasi ini sepenuhnya, kemudian saya buka kembali dari kondisi *cold start*. Dapat kita lihat bersama, seluruh data produk UMKM, harga, dan riwayat stok tetap tersimpan utuh dan tidak hilang, membuktikan persistensi database lokal Hive NoSQL bekerja secara sempurna.*
  >
  > *Kedua, bukti unit test: Sekarang saya beralih ke terminal Visual Studio Code dan menjalankan perintah `flutter test`.*
  >
  > *Hasilnya, seluruh 9 skenario unit testing berhasil lulus 100% tanpa kendala:*
  > * *4 unit test untuk HiveService (Create, Read, Update, Persistensi, dan Delete).*
  > * *Serta 5 unit test untuk ProdukController (Fitur Khusus 1 Margin %, Fitur Khusus 2 Sort, Fitur Khusus 3 Valuasi Stok, Validasi Form, dan Filter Pencarian).*
  >
  > *Demikian penjelasan dan demonstrasi lengkap implementasi CPMK 03 Paket 9 aplikasi KatalogKu. Terima kasih atas perhatian Bapak Dosen dan rekan-rekan sekalian. Wassalamualaikum warahmatullahi wabarakatuh."*

---

## 📁 DAFTAR ASET MENTAHAN VIDEO YANG TERSEDIA

Seluruh berkas aset rekaman mentah video dan tangkapan visual potongan kode telah tersedia dan siap dipakai untuk *editing*:

### 1. Klip Rekaman Video Nyata (.mp4 Full HD)
* 📹 [clip_01_overview_katalog.mp4](file:///d:/Pemrograman%20Mobile/cpmk3/docs/video_assets/raw_clips/clip_01_overview_katalog.mp4) — *Overview navigasi katalog, bento card, kategori filter, dan bottom nav.*
* 📹 [clip_02_demo_crud_dan_validasi.mp4](file:///d:/Pemrograman%20Mobile/cpmk3/docs/video_assets/raw_clips/clip_02_demo_crud_dan_validasi.mp4) — *Demo CRUD lengkap, validasi gagal, form input produk baru, pencarian, dan dialog konfirmasi.*
* 📹 [clip_03_demo_fitur_khusus_paket9.mp4](file:///d:/Pemrograman%20Mobile/cpmk3/docs/video_assets/raw_clips/clip_03_demo_fitur_khusus_paket9.mp4) — *Demo Fitur Khusus 1 (Margin %), Fitur Khusus 2 (Sort Harga Jual), dan Fitur Khusus 3 (Total Nilai Stok).*
* 📹 [clip_04_bukti_persistensi.mp4](file:///d:/Pemrograman%20Mobile/cpmk3/docs/video_assets/raw_clips/clip_04_bukti_persistensi.mp4) — *Simulasi cold restart aplikasi membuktikan data Hive tetap utuh.*

### 2. Potongan Visual Source Code & Struktur Direktori (High-Res Code Slices)
* 🖼️ [01_tree_mvc_architecture.png](file:///d:/Pemrograman%20Mobile/cpmk3/docs/video_assets/code_slices/01_tree_mvc_architecture.png) — *Pohon direktori arsitektur MVC proyek.*
* 🖼️ [02_model_and_typeadapter.png](file:///d:/Pemrograman%20Mobile/cpmk3/docs/video_assets/code_slices/02_model_and_typeadapter.png) — *Model Produk & TypeAdapter biner (typeId: 9).*
* 🖼️ [03_hive_service.png](file:///d:/Pemrograman%20Mobile/cpmk3/docs/video_assets/code_slices/03_hive_service.png) — *Lapisan HiveService terisolasi tanpa sentuhan View.*
* 🖼️ [04_produk_controller_obs.png](file:///d:/Pemrograman%20Mobile/cpmk3/docs/video_assets/code_slices/04_produk_controller_obs.png) — *Controller, variabel .obs, sorting, dan validasi.*
* 🖼️ [05_binding_and_routes.png](file:///d:/Pemrograman%20Mobile/cpmk3/docs/video_assets/code_slices/05_binding_and_routes.png) — *Dependency injection ProdukBinding & AppPages.*
* 🖼️ [06_view_obx_reactive.png](file:///d:/Pemrograman%20Mobile/cpmk3/docs/video_assets/code_slices/06_view_obx_reactive.png) — *Pewarisan GetView dan widget Obx reaktif.*
* 🖼️ [07_flutter_test_passed.png](file:///d:/Pemrograman%20Mobile/cpmk3/docs/video_assets/code_slices/07_flutter_test_passed.png) — *Bukti kelulusan 9/9 unit test di terminal.*

### 3. Tangkapan Layar Aplikasi Nyata (App Screens)
* 📱 [real_katalog.png](file:///d:/Pemrograman%20Mobile/cpmk3/docs/mockups/real_katalog.png) — *Halaman Katalog & Valuasi Bento Card.*
* 📱 [real_form.png](file:///d:/Pemrograman%20Mobile/cpmk3/docs/mockups/real_form.png) — *Formulir input produk & kalkulator margin.*
* 📱 [real_analitik.png](file:///d:/Pemrograman%20Mobile/cpmk3/docs/mockups/real_analitik.png) — *Dashboard analitik finansial toko UMKM.*
* 📱 [real_riwayat.png](file:///d:/Pemrograman%20Mobile/cpmk3/docs/mockups/real_riwayat.png) — *Audit trail riwayat mutasi stok.*
* 📱 [real_splash.png](file:///d:/Pemrograman%20Mobile/cpmk3/docs/mockups/real_splash.png) — *Splash screen resmi KatalogKu.*
