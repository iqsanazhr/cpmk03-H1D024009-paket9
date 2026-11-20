import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/produk_controller.dart';
import 'widgets/katalog_logo_widget.dart';
import 'widgets/valuation_bento_card.dart';
import 'widgets/produk_card_item.dart';
import 'widgets/app_bottom_nav.dart';

/// VIEW: Halaman Utama Katalog Produk UMKM (KatalogKu Modern Standard)
/// Mengikuti standar resmi Modul Praktikum Bab 7 (GetView<ProdukController>):
/// 1. App Bar Bersih: Logo KatalogKu, Peringatan Stok Kritis Riil, & Menu Eksekutif
/// 2. Bento Card Valuasi Stok (Fitur Khusus 3): Total nilai stok tampil di atas daftar
/// 3. Filter & Sort Bar (Fitur Khusus 2): Toggle interaktif Termurah (Asc) / Termahal (Desc)
/// 4. Kategori & Status Filter: Filter instan tanpa jeda (.obs reaktif GetX)
/// 5. Kartu Produk Informatif (Fitur Khusus 1): Margin keuntungan (%) terpampang jelas
/// 6. Tab Analitik & Riwayat Mutasi: Pembukuan dan audit trail transaksi katalog
class ProdukListView extends GetView<ProdukController> {
  const ProdukListView({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: _buildAppBar(context, controller),
      body: Obx(() {
        switch (controller.activeDockTab.value) {
          case 1:
            return _buildTabAnalitik(context, controller);
          case 2:
            return _buildTabRiwayat(controller);
          case 0:
          default:
            return _buildTabKatalog(context, controller);
        }
      }),
      bottomNavigationBar: Obx(() {
        return AppBottomNav(
          selectedIndex: controller.activeDockTab.value,
          onTabSelected: (idx) {
            controller.activeDockTab.value = idx;
          },
        );
      }),
      floatingActionButton: Obx(() {
        // FAB Tambah Produk hanya tampil di tab Katalog (0)
        if (controller.activeDockTab.value != 0) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: controller.openAddForm,
          backgroundColor: const Color(0xFF0052FF),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text(
            'Tambah Produk',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: -0.2),
          ),
        );
      }),
    );
  }

  // ===========================================================================
  // 1. APP BAR RESMI KATALOGKU
  // ===========================================================================
  PreferredSizeWidget _buildAppBar(BuildContext context, ProdukController controller) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 16,
      title: Row(
        children: [
          const KatalogLogoWidget(size: 34, showBackground: true),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'KatalogKu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Paket 9 • Manajemen Stok & Margin',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Alert Stok Kritis Button dengan Badge Riil
        Obx(() {
          final count = controller.criticalStockCount;

          return IconButton(
            tooltip: 'Peringatan Stok Kritis',
            onPressed: () => _showCriticalStockSheet(context, controller),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: count > 0 ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    count > 0 ? Icons.warning_amber_rounded : Icons.notifications_none_rounded,
                    size: 20,
                    color: count > 0 ? const Color(0xFFDC2626) : const Color(0xFF475569),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),

        // Menu Opsi Tambahan (Ekspor, Reset, Info)
        IconButton(
          tooltip: 'Menu & Cadangan',
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.more_horiz_rounded, size: 20, color: Color(0xFF475569)),
          ),
          onPressed: () => _showOperationalMenuSheet(context, controller),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ===========================================================================
  // TAB 0: KATALOG PRODUK UTAMA
  // ===========================================================================
  Widget _buildTabKatalog(BuildContext context, ProdukController controller) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. BENTO CARD VALUASI TOTAL STOK (FITUR KHUSUS 3)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: ValuationBentoCard(controller: controller),
          ),
        ),

        // 2. SEARCH & SORT BAR (FITUR KHUSUS 2)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchAndSortBar(controller),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // 3. HORIZONTAL CATEGORY FILTER PILLS
        SliverToBoxAdapter(
          child: SizedBox(
            height: 36,
            child: Obx(() {
              final activeKat = controller.selectedKategori.value;
              final allCats = ['Semua', ...ProdukController.kategoriList];

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: allCats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = allCats[index];
                  final isSelected = (activeKat == cat);

                  return GestureDetector(
                    onTap: () => controller.setKategori(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 10)),

        // 4. QUICK STATUS FILTER CHIPS (Semua / Stok Kritis / Margin Tinggi)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildQuickFilterChip(
                  label: 'Semua Stok',
                  filterVal: 'Semua Aset',
                  controller: controller,
                ),
                const SizedBox(width: 8),
                _buildQuickFilterChip(
                  label: 'Stok Kritis (<= 5)',
                  filterVal: 'Stok Kritis (<= 5)',
                  controller: controller,
                  icon: Icons.warning_amber_rounded,
                  alertColor: const Color(0xFFDC2626),
                ),
                const SizedBox(width: 8),
                _buildQuickFilterChip(
                  label: 'Margin Tinggi (> 40%)',
                  filterVal: 'Margin Tinggi (> 40%)',
                  controller: controller,
                  icon: Icons.trending_up_rounded,
                  alertColor: const Color(0xFF059669),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // 5. DAFTAR KARTU PRODUK
        Obx(() {
          final items = controller.filteredList;

          if (items.isEmpty) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
                child: _buildEmptyState(controller),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final produk = items[index];
                  return ProdukCardItem(produk: produk, controller: controller);
                },
                childCount: items.length,
              ),
            ),
          );
        }),
      ],
    );
  }

  // SEARCH AND SORT CONTROL (FITUR KHUSUS 2)
  Widget _buildSearchAndSortBar(ProdukController controller) {
    return Row(
      children: [
        // Input Pencarian
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              onChanged: (val) => controller.keyword.value = val,
              decoration: InputDecoration(
                hintText: 'Cari nama atau SKU...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                suffixIcon: Obx(() {
                  return controller.keyword.value.isNotEmpty
                      ? GestureDetector(
                          onTap: () => controller.keyword.value = '',
                          child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
                        )
                      : const SizedBox.shrink();
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Tombol Urutkan Harga Jual (Fitur Khusus 2)
        Obx(() {
          final isAsc = controller.sortAscending.value;

          return InkWell(
            onTap: controller.toggleSort,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC7D9FE)),
              ),
              child: Row(
                children: [
                  Icon(
                    isAsc ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 16,
                    color: const Color(0xFF0052FF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isAsc ? 'Termurah' : 'Termahal',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0052FF),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuickFilterChip({
    required String label,
    required String filterVal,
    required ProdukController controller,
    IconData? icon,
    Color? alertColor,
  }) {
    return Obx(() {
      final isSelected = controller.watchlistFilter.value == filterVal;

      return GestureDetector(
        onTap: () => controller.setWatchlistFilter(filterVal),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? (alertColor != null ? alertColor.withOpacity(0.12) : const Color(0xFFEEF4FF))
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? (alertColor ?? const Color(0xFF0052FF))
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: isSelected ? (alertColor ?? const Color(0xFF0052FF)) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? (alertColor ?? const Color(0xFF0052FF)) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ===========================================================================
  // TAB 1: ANALITIK FINANSIAL UMKM
  // ===========================================================================
  Widget _buildTabAnalitik(BuildContext context, ProdukController controller) {
    return Obx(() {
      final totalAset = controller.totalNilaiStok;
      final potensiLaba = controller.potensiLabaKumulatif;
      final totalJual = totalAset + potensiLaba;
      final rataMargin = controller.rataRataMargin;
      final totalUnit = controller.totalKuantitasStok;

      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Finansial Toko',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Rekapitulasi modal persediaan, valuasi penjualan, dan performa margin usaha.',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),

                  // Hero Financial Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL ESTIMASI NILAI JUAL KATALOG',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currencyFormat.format(totalJual),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFF334155)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Modal Persediaan (HPP)', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                const SizedBox(height: 2),
                                Text(_currencyFormat.format(totalAset), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Proyeksi Laba Bersih', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                const SizedBox(height: 2),
                                Text('+${_currencyFormat.format(potensiLaba)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF34D399))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Grid 2x2 Metrik
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Rata-rata Margin',
                          val: '+${rataMargin.toStringAsFixed(1)}%',
                          color: const Color(0xFF059669),
                          icon: Icons.trending_up_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Total Unit Stok',
                          val: '$totalUnit Unit',
                          color: const Color(0xFF0052FF),
                          icon: Icons.inventory_2_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          label: 'SKU Terdaftar',
                          val: '${controller.produkList.length} Produk',
                          color: const Color(0xFF0F172A),
                          icon: Icons.qr_code_2_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Stok Kritis (<= 5)',
                          val: '${controller.criticalStockCount} Item',
                          color: controller.criticalStockCount > 0 ? const Color(0xFFDC2626) : const Color(0xFF059669),
                          icon: Icons.warning_amber_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sebaran per Sektor Kategori
                  const Text(
                    'Sebaran Modal per Kategori',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...ProdukController.kategoriList.map((kat) {
                    final prods = controller.produkList.where((p) => p.kategori == kat).toList();
                    final valKat = prods.fold(0.0, (t, p) => t + p.totalNilaiStok);
                    final unitKat = prods.fold(0, (t, p) => t + p.stok);
                    final pct = (totalAset > 0) ? (valKat / totalAset) : 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(kat, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                              Text(_currencyFormat.format(valKat), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0052FF))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${prods.length} Jenis Produk • $unitKat Unit', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              Text('${(pct * 100).toStringAsFixed(1)}% dari Total Modal', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct.clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: const AlwaysStoppedAnimation(Color(0xFF0052FF)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Ekspor Data Laporan JSON
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _showExportDialog(context, controller),
                      icon: const Icon(Icons.file_download_outlined, size: 20),
                      label: const Text('Ekspor Laporan Finansial (JSON)', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0052FF),
                        side: const BorderSide(color: Color(0xFF0052FF)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMetricTile({
    required String label,
    required String val,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 2: RIWAYAT MUTASI & AKTIVITAS KATALOG
  // ===========================================================================
  Widget _buildTabRiwayat(ProdukController controller) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Riwayat & Log Mutasi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.6,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Audit jejak perubahan data produk, harga jual, dan restock stok secara persisten.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
        Obx(() {
          final logs = controller.activityLogs.toList();

          if (logs.isEmpty) {
            return const SliverFillRemaining(
              child: Center(
                child: Text('Belum ada riwayat aktivitas.', style: TextStyle(color: Color(0xFF94A3B8))),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = logs[index];
                  final type = item['type'] as String;
                  final time = item['time'] as DateTime;
                  final timeStr = DateFormat('HH:mm - dd/MM/yyyy').format(time);

                  Color badgeColor = const Color(0xFF0052FF);
                  IconData icon = Icons.history_rounded;
                  if (type == 'create') {
                    badgeColor = const Color(0xFF059669);
                    icon = Icons.add_circle_outline_rounded;
                  } else if (type == 'update') {
                    badgeColor = const Color(0xFF0052FF);
                    icon = Icons.edit_note_rounded;
                  } else if (type == 'delete') {
                    badgeColor = const Color(0xFFDC2626);
                    icon = Icons.delete_outline_rounded;
                  } else if (type == 'restock') {
                    badgeColor = const Color(0xFFD97706);
                    icon = Icons.inventory_2_outlined;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: badgeColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['title'],
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    timeStr,
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item['desc'],
                                style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: logs.length,
              ),
            ),
          );
        }),
      ],
    );
  }

  // ===========================================================================
  // EMPTY STATE
  // ===========================================================================
  Widget _buildEmptyState(ProdukController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 44, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          const Text(
            'Katalog Kosong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Belum ada produk yang cocok dengan filter atau kata kunci pencarian Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.4),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: controller.openAddForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Tambah Produk Baru', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MODALS & DIALOGS
  // ===========================================================================
  void _showCriticalStockSheet(BuildContext context, ProdukController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Obx(() {
        final criticals = controller.criticalStockList;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                    child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text('Peringatan Stok Kritis (<= 5)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Produk-produk berikut mendekati habis dan perlu segera di-restock ke suplier.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 16),

              if (criticals.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('Seluruh stok produk berada dalam kondisi aman (> 5 unit).', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w700)),
                  ),
                )
              else
                ...criticals.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.nama, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                          Text('${p.sku} • Sisa ${p.stok} unit', style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.quickRestock(p, 10);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0052FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          elevation: 0,
                        ),
                        child: const Text('+10 Unit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                )),

              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showOperationalMenuSheet(BuildContext context, ProdukController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                KatalogLogoWidget(size: 38, showBackground: true),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KatalogKu UMKM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    Text('Sistem Manajemen Inventori & Valuasi Stok', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF1F5F9)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFEEF4FF), shape: BoxShape.circle),
                child: const Icon(Icons.file_download_outlined, color: Color(0xFF0052FF), size: 20),
              ),
              title: const Text('Ekspor Data Katalog (JSON)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0052FF))),
              subtitle: const Text('Salin cadangan data katalog lokal ke clipboard', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
              onTap: () {
                Navigator.pop(ctx);
                _showExportDialog(context, controller);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                child: const Icon(Icons.refresh_rounded, color: Color(0xFFDC2626), size: 20),
              ),
              title: const Text('Reset ke Data Contoh Default', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFDC2626))),
              subtitle: const Text('Kembalikan katalog ke 4 data produk contoh awal', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
              onTap: () {
                Navigator.pop(ctx);
                controller.resetSeedData();
              },
            ),
            const SizedBox(height: 8),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 4),
            _buildInfoRow('Pengembang', 'Iqsan Azhar Nuryadi'),
            _buildInfoRow('NIM Mahasiswa', 'H1D024009 (Paket 9)'),
            _buildInfoRow('Arsitektur', 'Pure MVC + GetX + Hive NoSQL'),
          ],
        ),
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, ProdukController controller) {
    final jsonStr = controller.exportJsonData();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.code_rounded, color: Color(0xFF0052FF)),
            SizedBox(width: 10),
            Text('Ekspor Data JSON', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 260,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                jsonStr,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFF0F172A)),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.pop(ctx);
              Get.snackbar(
                'Tersalin',
                'Data JSON katalog berhasil disalin ke clipboard.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF0052FF),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 14,
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Salin JSON'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052FF),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
