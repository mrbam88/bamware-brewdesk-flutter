import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../core/venue_widgets.dart';
import 'discovery_view_model.dart';

/// UI3 parity (brewdesk#118 on iOS, #7 here): the filter button anchors a
/// small popover menu instead of the old flat chip rail. The badge on the
/// button always mirrors [DiscoveryViewModel.activeFilterCount].
class WorkFitFilterButton extends StatefulWidget {
  const WorkFitFilterButton({super.key, required this.model});

  final DiscoveryViewModel model;

  @override
  State<WorkFitFilterButton> createState() => _WorkFitFilterButtonState();
}

class _WorkFitFilterButtonState extends State<WorkFitFilterButton> {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (context) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _controller.hide,
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 8),
              child: Material(
                elevation: 8,
                color: Theme.of(context).colorScheme.surface,
                shadowColor: Colors.black38,
                borderRadius: BorderRadius.circular(18),
                child: WorkFitFilterMenu(model: widget.model),
              ),
            ),
          ],
        ),
        child: ListenableBuilder(
          listenable: widget.model,
          builder: (context, _) {
            final count = widget.model.activeFilterCount;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: l10n.filtersTooltip,
                  onPressed: _controller.toggle,
                  icon: Icon(
                    count > 0
                        ? Icons.filter_alt_rounded
                        : Icons.filter_alt_outlined,
                  ),
                ),
                if (count > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: IgnorePointer(
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: AppColors.green,
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The anchored panel: Laptop friendly toggle, Wi-Fi / Outlets tri-state
/// rows, a venue-type row, the score-tier legend, then Reset. Filters apply
/// live against [model] as each control changes — no separate "Apply" step.
class WorkFitFilterMenu extends StatelessWidget {
  const WorkFitFilterMenu({super.key, required this.model});

  final DiscoveryViewModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final count = model.activeFilterCount;
        return SizedBox(
          width: 296,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: model.laptopFriendly,
                  onChanged: model.setLaptopFriendly,
                  secondary: const Icon(Icons.laptop_mac_rounded, size: 20),
                  title: Text(
                    l10n.filtersLaptopFriendly,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 14),
                _DimensionRow<WifiLevel?>(
                  title: l10n.filtersWifiTitle,
                  icon: Icons.wifi_rounded,
                  value: model.minWifi,
                  options: [
                    (null, l10n.anyOption, 'filter-wifi-any'),
                    (WifiLevel.ok, l10n.filtersWifiOk, 'filter-wifi-ok'),
                    (WifiLevel.fast, l10n.filtersWifiFast, 'filter-wifi-fast'),
                  ],
                  onChanged: model.setMinWifi,
                ),
                const SizedBox(height: 14),
                _DimensionRow<OutletsLevel?>(
                  title: l10n.filtersOutletsTitle,
                  icon: Icons.power_rounded,
                  value: model.minOutlets,
                  options: [
                    (null, l10n.anyOption, 'filter-outlets-any'),
                    (
                      OutletsLevel.some,
                      l10n.filtersOutletsSome,
                      'filter-outlets-some',
                    ),
                    (
                      OutletsLevel.plenty,
                      l10n.filtersOutletsPlenty,
                      'filter-outlets-plenty',
                    ),
                  ],
                  onChanged: model.setMinOutlets,
                ),
                const SizedBox(height: 14),
                _DimensionRow<WorkVenueType?>(
                  title: l10n.filtersVenueTypeTitle,
                  icon: Icons.storefront_rounded,
                  value: model.venueType,
                  options: [
                    (null, l10n.anyOption, 'filter-type-any'),
                    (
                      WorkVenueType.cafe,
                      l10n.filtersVenueTypeCafe,
                      'filter-type-cafe',
                    ),
                    (
                      WorkVenueType.library,
                      l10n.filtersVenueTypeLibrary,
                      'filter-type-library',
                    ),
                    (
                      WorkVenueType.park,
                      l10n.filtersVenueTypePark,
                      'filter-type-park',
                    ),
                  ],
                  onChanged: model.setVenueType,
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                const _ScoreTierLegend(),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('filters-reset'),
                    onPressed: count == 0 ? null : model.resetFilters,
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: Text(l10n.filtersResetCount(count)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One labeled row: an icon + title, then a segmented pick among the row's
/// options. Generic over the filter's nullable value type so Wi-Fi / Outlets
/// / venue-type share one row builder. `null` always renders as "Any".
class _DimensionRow<T> extends StatelessWidget {
  const _DimensionRow({
    required this.title,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final T value;
  final List<(T, String, String)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final option in options)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: option == options.last ? 0 : 6,
                  ),
                  child: _SegmentButton(
                    key: Key(option.$3),
                    label: option.$2,
                    selected: option.$1 == value,
                    onTap: () => onChanged(option.$1),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.green
          : AppColors.sage.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "What the numbers mean" — the same four tiers and colors as
/// [ScoreBadge]/the map pin, spelled out once here since the score itself
/// no longer carries an inline legend anywhere on discovery.
class _ScoreTierLegend extends StatelessWidget {
  const _ScoreTierLegend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.whatNumbersMean,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        _LegendRow(score: 80, range: '75+', label: l10n.tierGreat),
        _LegendRow(score: 65, range: '60–74', label: l10n.tierGood),
        _LegendRow(score: 50, range: '45–59', label: l10n.tierMixed),
        _LegendRow(score: 20, range: '0–44', label: l10n.tierWeak),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.score,
    required this.range,
    required this.label,
  });

  final int score;
  final String range;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: scoreColor(score),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 46,
            child: Text(range, style: const TextStyle(fontSize: 11)),
          ),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
