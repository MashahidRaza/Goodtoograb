import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/discover_bloc.dart';
import '../widgets/category_chip.dart';
import '../widgets/location_picker_sheet.dart';
import '../widgets/store_card.dart';
import 'see_all_page.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: InkWell(
          onTap: () => showLocationPickerSheet(context),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Chosen location', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                    Text('Covent Garden, London', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<DiscoverBloc, DiscoverState>(
        builder: (context, state) {
          if (state.isLoading && state.allStores.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final categories = ['All', 'Meals', 'Bread & pastries', 'Groceries', 'Flowers & plants'];

          return Column(
            children: [
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: categories.map((cat) {
                    return CategoryChip(
                      label: cat,
                      isSelected: state.selectedCategory == cat,
                      onTap: () => context.read<DiscoverBloc>().add(ChangeCategory(cat)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimationLimiter(
                  key: ValueKey(state.selectedCategory),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 500),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          if (state.topPicks.isNotEmpty) ...[
                            _buildSectionHeader(context, 'Top picks near you', state.topPicks),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 340, // INCREASED HEIGHT to fix overflow
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                scrollDirection: Axis.horizontal,
                                itemCount: state.topPicks.length,
                                itemBuilder: (context, index) {
                                  final item = state.topPicks[index];
                                  return StoreCard(
                                    item: item,
                                    isFavorite: state.favoriteIds.contains(item.id),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                          if (state.saveBeforeTooLate.isNotEmpty) ...[
                            _buildSectionHeader(context, 'Save before it\'s too late', state.saveBeforeTooLate),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.saveBeforeTooLate.length,
                                itemBuilder: (context, index) {
                                  final item = state.saveBeforeTooLate[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0), // Fixed constructor
                                    child: StoreCard(
                                      item: item,
                                      isHorizontal: false,
                                      isFavorite: state.favoriteIds.contains(item.id),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          if (state.topPicks.isEmpty && state.saveBeforeTooLate.isEmpty)
                            const Center(child: Padding(padding: EdgeInsets.all(64), child: Text('No stores found for this category'))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, List items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<DiscoverBloc>(),
                  child: SeeAllPage(title: title, items: List.from(items)),
                ),
              ));
            },
            child: const Text('See all', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
