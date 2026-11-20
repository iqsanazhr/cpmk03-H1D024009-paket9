/// MODEL: Representasi data Produk UMKM (Paket 9).
/// Class ini murni berisi struktur data bisnis (POJO/Dart class),
/// tidak bergantung pada antarmuka (UI) maupun state management GetX.
class Produk {
  final String sku; // Unik, format PRD-001
  final String nama;
  final String kategori;
  final double hargaBeli;
  final double hargaJual;
  final int stok;

  Produk({
    required this.sku,
    required this.nama,
    required this.kategori,
    required this.hargaBeli,
    required this.hargaJual,
    required this.stok,
  });

  /// Fitur Khusus 1: Margin keuntungan nominal (Rp)
  double get marginKeuntunganNominal => hargaJual - hargaBeli;

  /// Fitur Khusus 1: Margin keuntungan persentase (%)
  /// Dihitung otomatis: ((hargaJual - hargaBeli) / hargaBeli) * 100
  double get marginKeuntunganPersen {
    if (hargaBeli <= 0) return 0.0;
    return ((hargaJual - hargaBeli) / hargaBeli) * 100;
  }

  /// Fitur Khusus 3: Total nilai stok per produk (hargaBeli * stok)
  double get totalNilaiStok => hargaBeli * stok;

  /// Memudahkan pembuatan salinan objek dengan modifikasi sebagian field (immutable)
  Produk copyWith({
    String? sku,
    String? nama,
    String? kategori,
    double? hargaBeli,
    double? hargaJual,
    int? stok,
  }) {
    return Produk(
      sku: sku ?? this.sku,
      nama: nama ?? this.nama,
      kategori: kategori ?? this.kategori,
      hargaBeli: hargaBeli ?? this.hargaBeli,
      hargaJual: hargaJual ?? this.hargaJual,
      stok: stok ?? this.stok,
    );
  }
}
