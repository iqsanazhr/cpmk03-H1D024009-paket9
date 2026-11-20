import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/produk_model.dart';
import '../../controllers/produk_controller.dart';

/// WIDGET: Kartu Produk Katalog UMKM
/// Menggantikan baris aset kripto Coinbase (yang bergaya koin BTC/ETH) dengan
/// kartu produk fisik UMKM yang kaya informasi dan fungsional:
/// - Ikon kategori kontekstual (Kuliner, Busana, Kriya, Herbal)
/// - Badge SKU resmi & Status Stok Real-Time (Kritis jika <= 5)
/// - Harga Jual Konsumen & Modal HPP
/// - Margin Keuntungan Otomatis (%) (Fitur Khusus 1)
/// - Aksi Cepat: Edit, Quick Restock (+10), Hapus Produk
class ProdukCardItem extends StatelessWidget {
  final Produk produk;
  final ProdukController controller;

  const ProdukCardItem({
    super.key,
    required this.produk,
    required this.controller,
  });

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final isCritical = produk.stok <= 5;
    final catMeta = _getCategoryMeta(produk.kategori);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCritical
              ? const Color(0xFFFCA5A5) // Subtle red border for low stock
              : const Color(0xFFE2E8F0), // Slate 200
          width: isCritical ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Kategori Icon + Nama + SKU + More Menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Kategori
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: catMeta.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    catMeta.icon,
                    color: catMeta.iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Nama & SKU & Kategori
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produk.nama,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF4FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              produk.sku,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0052FF),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            produk.kategori,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // More Menu Button (Edit, Restock, Delete)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 19,
                    color: Color(0xFF94A3B8),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (val) {
                    if (val == 'edit') {
                      controller.openEditForm(produk);
                    } else if (val == 'restock') {
                      controller.quickRestock(produk, 10);
                    } else if (val == 'delete') {
                      controller.confirmDelete(produk);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0F172A)),
                          SizedBox(width: 10),
                          Text('Ubah Produk', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'restock',
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF0052FF)),
                          SizedBox(width: 10),
                          Text('Restock (+10 Unit)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0052FF))),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                          SizedBox(width: 10),
                          Text('Hapus Produk', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFFEF4444))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Row 2: Harga Jual, Modal HPP, Margin Keuntungan & Stok Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Info Harga Jual & Beli
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currencyFormat.format(produk.hargaJual),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Modal HPP: ${_currencyFormat.format(produk.hargaBeli)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Pill Margin Keuntungan (%) (Fitur Khusus 1) & Badge Stok
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Margin Keuntungan (Fitur Khusus 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.trending_up_rounded,
                            size: 14,
                            color: Color(0xFF059669),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '+${produk.marginKeuntunganPersen.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Badge Stok (Kritis atau Aman)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCritical
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCritical
                              ? const Color(0xFFFECACA)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCritical
                                ? Icons.warning_amber_rounded
                                : Icons.inventory_2_outlined,
                            size: 13,
                            color: isCritical
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isCritical ? '${produk.stok} (Kritis)' : '${produk.stok} unit',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isCritical
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _CategoryMeta _getCategoryMeta(String kategori) {
    switch (kategori) {
      case 'Makanan & Minuman':
        return _CategoryMeta(
          icon: Icons.restaurant_rounded,
          iconColor: const Color(0xFFEA580C),
          bgColor: const Color(0xFFFFF7ED),
        );
      case 'Pakaian & Tekstil':
        return _CategoryMeta(
          icon: Icons.checkroom_rounded,
          iconColor: const Color(0xFF0284C7),
          bgColor: const Color(0xFFF0F9FF),
        );
      case 'Kerajinan Tangan':
        return _CategoryMeta(
          icon: Icons.brush_rounded,
          iconColor: const Color(0xFFD97706),
          bgColor: const Color(0xFFFFFBEB),
        );
      case 'Kecantikan & Herbal':
        return _CategoryMeta(
          icon: Icons.spa_rounded,
          iconColor: const Color(0xFF059669),
          bgColor: const Color(0xFFECFDF5),
        );
      default:
        return _CategoryMeta(
          icon: Icons.inventory_2_rounded,
          iconColor: const Color(0xFF0052FF),
          bgColor: const Color(0xFFEEF4FF),
        );
    }
  }
}

class _CategoryMeta {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  _CategoryMeta({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}
