import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/produk_controller.dart';

/// VIEW: Formulir Tambah & Ubah Produk UMKM (KatalogKu Modern Standard)
/// Mengikuti standar resmi Modul Praktikum Bab 7 (GetView<ProdukController>):
/// - Validasi SKU baku PRD-001 & cek keunikan
/// - Pilihan Kategori interaktif dengan ikon
/// - Kalkulasi Margin Keuntungan Otomatis (%) Live (Fitur Khusus 1)
/// - Stepper cepat penyesuaian stok inventori
/// - Estimasi valuasi aset produk seketika
class ProdukFormView extends GetView<ProdukController> {
  const ProdukFormView({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 22),
          onPressed: controller.tutup,
        ),
        title: Obx(() {
          return Text(
            controller.isEdit.value ? 'Ubah Data Produk' : 'Tambah Produk Baru',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          );
        }),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Form(
                  key: controller.formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KARTU 1: INFORMASI IDENTITAS PRODUK
                      _buildSectionCard(
                        title: 'INFORMASI IDENTITAS PRODUK',
                        icon: Icons.badge_outlined,
                        children: [
                          // Field Kode SKU
                          _buildTextField(
                            label: 'Kode SKU *',
                            controller: controller.skuC,
                            hint: 'Contoh: PRD-001',
                            helper: 'Format wajib PRD-001 & unik di database',
                            icon: Icons.qr_code_2_rounded,
                            capitalization: TextCapitalization.characters,
                            validator: controller.validateSku,
                          ),
                          const SizedBox(height: 14),

                          // Field Nama Produk
                          _buildTextField(
                            label: 'Nama Produk *',
                            controller: controller.namaC,
                            hint: 'Contoh: Kripik Tempe Renyah Banyumas',
                            helper: 'Minimal 3 karakter',
                            icon: Icons.inventory_2_outlined,
                            capitalization: TextCapitalization.words,
                            validator: controller.validateNama,
                          ),
                          const SizedBox(height: 14),

                          // Pilihan Kategori
                          _buildCategorySelector(controller),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // KARTU 2: PENETAPAN HARGA & KALKULASI MARGIN (FITUR KHUSUS 1)
                      _buildSectionCard(
                        title: 'PENETAPAN HARGA & MARGIN',
                        icon: Icons.payments_outlined,
                        badge: 'Fitur Khusus 1',
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Harga Modal (Beli / HPP)
                              Expanded(
                                child: _buildTextField(
                                  label: 'Harga Beli (Modal) *',
                                  controller: controller.hargaBeliC,
                                  hint: '12000',
                                  prefix: 'Rp ',
                                  keyboardType: TextInputType.number,
                                  formatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: controller.validateHargaBeli,
                                  onChanged: (_) => controller.update(),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Harga Jual Pelanggan
                              Expanded(
                                child: _buildTextField(
                                  label: 'Harga Jual *',
                                  controller: controller.hargaJualC,
                                  hint: '18000',
                                  prefix: 'Rp ',
                                  keyboardType: TextInputType.number,
                                  formatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: controller.validateHargaJual,
                                  onChanged: (_) => controller.update(),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Dynamic Live Margin & Profit Preview Card
                          _buildLiveMarginPreview(controller),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // KARTU 3: MANAJEMEN STOK INVENTORI
                      _buildSectionCard(
                        title: 'STOK FISIK & VALUASI PERSEDIAAN',
                        icon: Icons.inventory_outlined,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Input Angka Stok
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  label: 'Jumlah Stok (Unit) *',
                                  controller: controller.stokC,
                                  hint: '45',
                                  keyboardType: TextInputType.number,
                                  formatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: controller.validateStok,
                                  onChanged: (_) => controller.update(),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Quick Adjustment Buttons
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Penyesuaian Cepat',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _buildStepperBtn('-10', () => _adjustStock(controller, -10)),
                                        const SizedBox(width: 6),
                                        _buildStepperBtn('-1', () => _adjustStock(controller, -1)),
                                        const SizedBox(width: 6),
                                        _buildStepperBtn('+1', () => _adjustStock(controller, 1)),
                                        const SizedBox(width: 6),
                                        _buildStepperBtn('+10', () => _adjustStock(controller, 10)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Live Subtotal Valuation Preview
                          _buildSubtotalPreview(controller),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // PINNED BOTTOM ACTION BUTTON
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Obx(() {
                    return Text(
                      controller.isEdit.value
                          ? 'Perbarui Data Produk'
                          : 'Simpan ke Katalog Produk',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    String? badge,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF0052FF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF475569),
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? helper,
    String? prefix,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            if (helper != null)
              Text(
                helper,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: capitalization,
          inputFormatters: formatters,
          validator: validator,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            prefixText: prefix,
            prefixStyle: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            prefixIcon: icon != null
                ? Icon(icon, size: 18, color: const Color(0xFF64748B))
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF0052FF), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(ProdukController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Bisnis *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        Obx(() {
          final selected = controller.formKategori.value;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selected,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                items: ProdukController.kategoriList.map((kat) {
                  return DropdownMenuItem<String>(
                    value: kat,
                    child: Text(
                      kat,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) controller.formKategori.value = val;
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLiveMarginPreview(ProdukController controller) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller.hargaBeliC, controller.hargaJualC]),
      builder: (context, _) {
        final beli = double.tryParse(controller.hargaBeliC.text.trim()) ?? 0.0;
        final jual = double.tryParse(controller.hargaJualC.text.trim()) ?? 0.0;

        final isValid = (beli > 0 && jual > beli);
        final marginNominal = jual - beli;
        final marginPersen = isValid ? ((jual - beli) / beli) * 100 : 0.0;

        Color cardBg = const Color(0xFFF8FAFC);
        Color borderColor = const Color(0xFFE2E8F0);
        Color textColor = const Color(0xFF64748B);

        if (isValid) {
          cardBg = const Color(0xFFECFDF5);
          borderColor = const Color(0xFFA7F3D0);
          textColor = const Color(0xFF059669);
        } else if (jual <= beli && beli > 0 && jual > 0) {
          cardBg = const Color(0xFFFEF2F2);
          borderColor = const Color(0xFFFECACA);
          textColor = const Color(0xFFDC2626);
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isValid
                            ? Icons.trending_up_rounded
                            : (jual <= beli && beli > 0 && jual > 0
                                ? Icons.error_outline_rounded
                                : Icons.calculate_outlined),
                        size: 16,
                        color: textColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Kalkulasi Margin Otomatis',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  if (isValid)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+${marginPersen.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isValid
                    ? 'Keuntungan per unit: ${_currencyFormat.format(marginNominal)} (${marginPersen.toStringAsFixed(1)}% dari modal HPP).'
                    : (jual <= beli && beli > 0 && jual > 0
                        ? 'Harga jual wajib lebih besar dari modal beli untuk menghasilkan laba.'
                        : 'Masukkan modal beli dan harga jual untuk melihat proyeksi keuntungan.'),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubtotalPreview(ProdukController controller) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller.hargaBeliC, controller.stokC]),
      builder: (context, _) {
        final beli = double.tryParse(controller.hargaBeliC.text.trim()) ?? 0.0;
        final stok = int.tryParse(controller.stokC.text.trim()) ?? 0;
        final subtotal = beli * stok;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimasi Valuasi Aset Stok:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
              Text(
                _currencyFormat.format(subtotal),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepperBtn(String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _adjustStock(ProdukController controller, int delta) {
    final current = int.tryParse(controller.stokC.text.trim()) ?? 0;
    final next = (current + delta).clamp(0, 999999);
    controller.stokC.text = next.toString();
  }
}
