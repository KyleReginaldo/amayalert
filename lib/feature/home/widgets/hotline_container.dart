// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HotlineContainer extends StatefulWidget {
  const HotlineContainer({super.key});

  @override
  State<HotlineContainer> createState() => _HotlineContainerState();
}

class _HotlineContainerState extends State<HotlineContainer> {
  String _selectedCategory = 'All';
  bool _showAll = false;
  static const _categories = ['All', 'Hospital', 'Ambulance', 'Police', 'Fire'];
  static const _previewCount = 3;

  List<Hotline> get _filteredHotlines {
    final filtered = _selectedCategory == 'All'
        ? hotlines
        : hotlines.where((h) => h.category == _selectedCategory).toList();
    return _showAll ? filtered : filtered.take(_previewCount).toList();
  }

  bool get _hasMore {
    final totalFiltered = _selectedCategory == 'All'
        ? hotlines.length
        : hotlines.where((h) => h.category == _selectedCategory).length;
    return totalFiltered > _previewCount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 12),
            child: CustomText(
              text: 'Emergency Hotline Services',
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Category selector chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                          _showAll = false;
                        });
                      }
                    },
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Hotline list
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return Container(
      key: ValueKey('$_selectedCategory-$_showAll'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ..._filteredHotlines.map((h) => _HotlineListItem(h)),
          if (_hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: TextButton(
                onPressed: () => setState(() => _showAll = !_showAll),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _showAll ? 'See less' : 'See all',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showAll ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HotlineListItem extends StatelessWidget {
  final Hotline hotline;
  const _HotlineListItem(this.hotline);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showModalBottomSheet(
            enableDrag: true,
            showDragHandle: true,
            elevation: 10,
            context: context,
            builder: (context) => HotlineSheet(hotline: hotline),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon with gradient background
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: hotline.gradient,
                  color: hotline.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(hotline.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              // Label and quick contact info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: hotline.label,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      text: _getQuickContact(),
                      fontSize: 11.5,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getQuickContact() {
    if (hotline.phoneNumbers.isNotEmpty) {
      return hotline.phoneNumbers.first;
    }
    if (hotline.landlines.isNotEmpty) {
      return hotline.landlines.first;
    }
    return 'Tap for details';
  }
}

class HotlineSheet extends StatelessWidget {
  final Hotline hotline;
  const HotlineSheet({super.key, required this.hotline});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple header: icon + title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(hotline.icon, size: 18, color: Colors.black87),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomText(
                    text: hotline.label,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Numbers list
          if (hotline.phoneNumbers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: _SectionHeader(
                icon: Icons.smartphone,
                label: 'Mobile Numbers',
              ),
            ),
          if (hotline.phoneNumbers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: hotline.phoneNumbers
                    .map((n) => _NumberRow(number: n, isMobile: true))
                    .toList(),
              ),
            ),

          if (hotline.landlines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: _SectionHeader(icon: Icons.call, label: 'Landlines'),
            ),
          if (hotline.landlines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: hotline.landlines
                    .map((n) => _NumberRow(number: n, isMobile: false))
                    .toList(),
              ),
            ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 6),
        CustomText(
          text: label,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ],
    );
  }
}

class _NumberRow extends StatelessWidget {
  final String number;
  final bool isMobile;
  const _NumberRow({required this.number, required this.isMobile});

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: number));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied $number')));
  }

  Future<void> _call(BuildContext context) async {
    await _callNumber(context, number);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Call $number',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _call(context),
        onLongPress: () => _copy(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Icon(
                isMobile ? Icons.smartphone : Icons.call,
                size: 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomText(
                  text: number,
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _callNumber(BuildContext context, String number) async {
  final uri = Uri.parse('tel:$number');
  try {
    final ok = await launchUrl(uri);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to start call for $number')),
      );
    }
  } catch (_) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Unable to start call for $number')));
  }
}
