import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/produk_controller.dart';

/// WIDGET: Bento Card Valuasi Stok & Analitik Inventori UMKM (Fitur Khusus 3)
/// Menggantikan grafik sparkline kripto Coinbase yang dummy (fluktuasi jam acak)
/// dengan visualisasi data stok nyata berbasis database Hive:
/// - Total Nilai Stok (Fitur Khusus 3): Akumulasi hargaBeli * stok
/// - Potensi Keuntungan Kas: Akumulasi (hargaJual - hargaBeli) * stok
/// - Rata-rata Margin Keuntungan (%): Rata-rata margin seluruh produk
/// - Sebaran Valuasi per Kategori: Progress bar proporsional dinamis riil
class ValuationBentoCard extends StatelessWidget {
  final ProdukController controller;

  const ValuationBentoCard({
    super.key,
    required this.controller,
  });

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalSku = controller.produkList.length;
      final totalValuasi = controller.totalNilaiStok;
      final potensiLaba = controller.potensiLabaKumulatif;
      final rataMargin = controller.rataRataMargin;
      final totalUnit = controller.totalKuantitasStok;

      return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // Slate 900
            Color(0xFF1E293B), // Slate 800
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Label Header & Badge Fitur Khusus 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFF60A5FA),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TOTAL NILAI STOK GUDANG',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.35),
                  ),
                ),
                child: const Text(
                  'Fitur Khusus 3',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF34D399),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 2. Angka Valuasi Raksasa (Giant Valuation Currency)
          Text(
            _currencyFormat.format(totalValuasi),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.0,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 14),

          // 3. Grid Metrik Ringkas: Potensi Laba, Rata Margin, Unit Stok
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                // Metrik 1: Potensi Laba
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Potensi Laba',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '+${_currencyFormat.format(potensiLaba)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF34D399),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.12),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),

                // Metrik 2: Rata-rata Margin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rata-rata Margin',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '+${rataMargin.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF60A5FA),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.12),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),

                // Metrik 3: SKU & Unit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventori Fisik',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$totalSku SKU • $totalUnit Unit',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Bar Sebaran Valuasi per Kategori Riil (Real Distribution Bar)
          _buildCategoryDistribution(context, totalValuasi),
        ],
      ),
    );
    });
  }

  Widget _buildCategoryDistribution(BuildContext context, double totalValuasi) {
    const palette = [
      Color(0xFF3B82F6), // Blue
      Color(0xFF10B981), // Emerald
      Color(0xFFF59E0B), // Amber
      Color(0xFFEC4899), // Pink
    ];

    const categories = ProdukController.kategoriList;
    final portions = <Map<String, dynamic>>[];

    for (int i = 0; i < categories.length; i++) {
      final kat = categories[i];
      final items = controller.produkList.where((p) => p.kategori == kat).toList();
      final val = items.fold(0.0, (t, p) => t + p.totalNilaiStok);
      final pct = totalValuasi > 0 ? (val / totalValuasi) : 0.0;
      if (pct > 0) {
        portions.add({
          'kategori': kat,
          'valuasi': val,
          'pct': pct,
          'color': palette[i % palette.length],
        });
      }
    }

    if (portions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Komposisi Valuasi per Kategori',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.65),
              ),
            ),
            Text(
              'Data Riil Hive',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Multi-segment progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 7,
            color: Colors.white.withOpacity(0.1),
            child: Row(
              children: portions.map((item) {
                final pct = item['pct'] as double;
                final color = item['color'] as Color;
                return Expanded(
                  flex: (pct * 1000).toInt().clamp(1, 1000),
                  child: Container(color: color),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Legend Pills
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: portions.map((item) {
            final kat = item['kategori'] as String;
            final pct = item['pct'] as double;
            final color = item['color'] as Color;

            return GestureDetector(
              onTap: () {
                controller.setKategori(kat);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$kat ${(pct * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
