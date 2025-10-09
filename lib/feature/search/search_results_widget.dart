import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/search/search_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SearchResultsWidget extends StatelessWidget {
  final List<SearchResult> results;
  final String query;
  final VoidCallback onClear;

  const SearchResultsWidget({
    super.key,
    required this.results,
    required this.query,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty && query.isNotEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.search,
                  size: 18,
                  color: AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    text: 'Search Results for "$query"',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                GestureDetector(
                  onTap: onClear,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.gray300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.x,
                      size: 14,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomText(
              text:
                  '${results.length} result${results.length != 1 ? 's' : ''} found',
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
          ),

          // Results list
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: results.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppColors.gray200,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final result = results[index];
                return _buildResultItem(context, result);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(LucideIcons.searchX, size: 48, color: AppColors.gray400),
          const SizedBox(height: 16),
          CustomText(
            text: 'No results found for "$query"',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          CustomText(
            text:
                'Try searching for posts, alerts, evacuation centers, or activities',
            fontSize: 14,
            color: AppColors.textSecondaryLight,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onClear,
            child: CustomText(
              text: 'Clear Search',
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(BuildContext context, SearchResult result) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _getResultIcon(result.type),
      title: CustomText(
        text: result.title,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          CustomText(
            text: result.description,
            fontSize: 13,
            color: AppColors.textSecondaryLight,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          CustomText(
            text: result.subtitle,
            fontSize: 12,
            color: AppColors.gray500,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 16,
        color: AppColors.gray400,
      ),
      onTap: () => _handleResultTap(context, result),
    );
  }

  Widget _getResultIcon(SearchResultType type) {
    IconData icon;
    Color color;

    switch (type) {
      case SearchResultType.alert:
        icon = LucideIcons.triangle;
        color = Colors.red;
        break;
      case SearchResultType.evacuation:
        icon = LucideIcons.shield;
        color = Colors.blue;
        break;
      case SearchResultType.post:
        icon = LucideIcons.messageCircle;
        color = AppColors.primary;
        break;
      case SearchResultType.activity:
        icon = LucideIcons.activity;
        color = Colors.orange;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  void _handleResultTap(BuildContext context, SearchResult result) {
    // Navigate based on result type
    switch (result.type) {
      case SearchResultType.alert:
        // Navigate to map screen - alerts are shown there
        context.router.push(const MapRoute());
        break;
      case SearchResultType.evacuation:
        // Navigate to map screen and focus on evacuation center
        context.router.push(const MapRoute());
        break;
      case SearchResultType.post:
        // Stay on home screen - posts are shown there
        break;
      case SearchResultType.activity:
        // Navigate to activity screen
        context.router.push(const ActivityRoute());
        break;
    }
  }
}
