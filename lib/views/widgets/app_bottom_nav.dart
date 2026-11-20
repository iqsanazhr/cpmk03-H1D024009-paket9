import 'package:flutter/material.dart';

/// WIDGET: Navigation Bar Resmi KatalogKu
/// Menggantikan 5-Tab Coinbase Dock dan Home Indicator palsu dengan
/// navigasi bottom bar yang ergonomis, bersih, dan fungsional:
/// - 3 Tab Terfokus: Katalog, Analitik Finansial, dan Riwayat Mutasi
/// - Bebas bar imitasi iOS yang mengotori tampilan Android
/// - Respon instan mikro-interaksi Emil Kowalski (durasi 140ms)
class AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.storefront_rounded,
                activeIcon: Icons.storefront_rounded,
                label: 'Katalog',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.insights_rounded,
                activeIcon: Icons.insights_rounded,
                label: 'Analitik',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.history_rounded,
                activeIcon: Icons.history_rounded,
                label: 'Riwayat',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = (selectedIndex == index);

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEEF4FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive
                  ? const Color(0xFF0052FF) // Royal Blue
                  : const Color(0xFF64748B), // Slate 500
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? const Color(0xFF0052FF)
                    : const Color(0xFF64748B),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
