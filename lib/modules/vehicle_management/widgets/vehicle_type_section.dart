import 'package:flutter/material.dart';

import '/modules/dashboard/view/dashboard_tokens.dart';
import '../models/admin_vehicle_row.dart';
import '../models/vehicle_type_entry.dart';

/// Expandable card showing a vehicle type and its sub-vehicles.
class VehicleTypeSection extends StatelessWidget {
  const VehicleTypeSection({
    super.key,
    required this.entry,
    required this.actionVehicleIds,
    required this.onEdit,
    required this.onSetPricing,
  });

  final VehicleTypeEntry entry;
  final List<int> actionVehicleIds;
  final void Function(AdminVehicleRow vehicle) onEdit;
  final void Function(AdminVehicleRow vehicle) onSetPricing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DashboardTokens.cardRadius),
        border: const Border(
          left: BorderSide(color: DashboardTokens.primaryOrange, width: 4),
        ),
        boxShadow: DashboardTokens.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DashboardTokens.cardRadius),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: _typeLeading(),
          title: Text(
            entry.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          subtitle: Text(
            '${entry.subVehicles.length} sub-vehicle${entry.subVehicles.length != 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          children: [
            if (entry.subVehicles.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No sub-vehicles added yet.',
                  style: TextStyle(color: Colors.black45),
                ),
              )
            else
              ...entry.subVehicles.map(
                (v) => _SubVehicleTile(
                  vehicle: v,
                  isInAction: actionVehicleIds.contains(v.id),
                  onEdit: () => onEdit(v),
                  onSetPricing: () => onSetPricing(v),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _typeLeading() {
    if (entry.imageUrl.isEmpty) {
      return const Icon(Icons.category_rounded,
          size: 36, color: DashboardTokens.primaryOrange);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        entry.imageUrl,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.category_rounded,
          size: 36,
          color: DashboardTokens.primaryOrange,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SubVehicleTile extends StatelessWidget {
  const _SubVehicleTile({
    required this.vehicle,
    required this.isInAction,
    required this.onEdit,
    required this.onSetPricing,
  });

  final AdminVehicleRow vehicle;
  final bool isInAction;
  final VoidCallback onEdit;
  final VoidCallback onSetPricing;

  String _formatAmount(num value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: vehicle.imageUrl.isNotEmpty
                ? Image.network(
                    vehicle.imageUrl,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallback(),
                  )
                : _fallback(),
          ),
          const SizedBox(width: 12),
          // Name + chips
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (vehicle.rideCategory.isNotEmpty)
                      _Chip(
                          label: vehicle.rideCategory,
                          color: const Color(0xFFF0F4FF)),
                    if (vehicle.seatingCapacity > 0)
                      _Chip(
                          label: '${vehicle.seatingCapacity} seats',
                          color: const Color(0xFFF0FFF4)),
                    if (vehicle.luggageCapacity > 0)
                      _Chip(
                          label: '${vehicle.luggageCapacity} bags',
                          color: const Color(0xFFFFF8F0)),
                    if (vehicle.baseFare != null)
                      _Chip(
                          label: 'Base Rs ${_formatAmount(vehicle.baseFare!)}',
                          color: const Color(0xFFE8F5E9)),
                    if (vehicle.pricePerKm != null)
                      _Chip(
                          label: 'Rs ${_formatAmount(vehicle.pricePerKm!)}/km',
                          color: const Color(0xFFEDE7F6)),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          if (isInAction)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: 'Set Pricing',
                  child: IconButton(
                    onPressed: onSetPricing,
                    icon: const Icon(Icons.price_change_rounded, size: 20),
                    color: DashboardTokens.metricOnlineAccent,
                  ),
                ),
                Tooltip(
                  message: 'Edit Vehicle',
                  child: IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    color: DashboardTokens.metricUsersAccent,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _fallback() => Container(
        width: 52,
        height: 52,
        color: const Color(0xFFF5F5F5),
        child: const Icon(
          Icons.directions_car_rounded,
          size: 28,
          color: Colors.black26,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
