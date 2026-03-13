import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/machine_provider.dart';
import '../../models/models.dart';
import '../../utils/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  ROmachine? _selectedMachine;

  // Default center - Chennai
  static const _defaultCenter = LatLng(11.0168, 76.9558);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MachineProvider>().fetchMachines();
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _currentPosition = position);

      _mapController.move(
        LatLng(position.latitude, position.longitude),
        14,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Machine Locator'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'My Location',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MachineProvider>().fetchMachines(),
          ),
        ],
      ),
      body: Consumer<MachineProvider>(
        builder: (context, provider, _) {
          final machines = provider.machines;
          final onlineCount = machines.where((m) => m.isOnline).length;

          return Stack(
            children: [
              // ── Real OpenStreetMap ──
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPosition != null
                      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                      : _defaultCenter,
                  initialZoom: 13,
                  onTap: (_, __) => setState(() => _selectedMachine = null),
                ),
                children: [
                  // Tile layer - OpenStreetMap
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.rovending.app',
                  ),

                  // Current location marker
                  if (_currentPosition != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          width: 24,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Machine markers
                  MarkerLayer(
                    markers: machines
                        .where((m) => m.latitude != 0 && m.longitude != 0)
                        .map((machine) {
                      final isOnline = machine.isOnline && machine.isAvailable;
                      return Marker(
                        point: LatLng(machine.latitude, machine.longitude),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedMachine = machine);
                            _mapController.move(
                              LatLng(machine.latitude, machine.longitude),
                              15,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isOnline ? AppTheme.primaryBlue : AppTheme.error,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: (isOnline ? AppTheme.primaryBlue : AppTheme.error)
                                      .withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.water_drop,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // ── Online count badge (top left) ──
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.success, shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$onlineCount machines online',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Legend (top right) ──
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      _legendDot(AppTheme.primaryBlue, 'Available'),
                      const SizedBox(height: 6),
                      _legendDot(AppTheme.error, 'Offline'),
                      const SizedBox(height: 6),
                      _legendDot(AppTheme.primaryBlue, 'You', isYou: true),
                    ],
                  ),
                ),
              ),

              // ── Loading indicator ──
              if (provider.isLoading)
                const Positioned(
                  bottom: 80,
                  left: 0, right: 0,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              // ── Selected machine bottom card ──
              if (_selectedMachine != null)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: _buildMachineCard(_selectedMachine!, context),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _legendDot(Color color, String label, {bool isYou = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: isYou ? BoxShape.circle : BoxShape.circle,
            border: isYou ? Border.all(color: Colors.white, width: 2) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildMachineCard(ROmachine machine, BuildContext context) {
    final isOnline = machine.isOnline && machine.isAvailable;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(machine.name,
                        style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700,
                          color: AppTheme.deepBlue,
                        )),
                    const SizedBox(height: 3),
                    Text(machine.address,
                        style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedMachine = null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _chip(
                isOnline ? Icons.wifi : Icons.wifi_off,
                isOnline ? 'Online' : 'Offline',
                isOnline ? AppTheme.success : AppTheme.error,
              ),
              const SizedBox(width: 8),
              _chip(Icons.water_drop,
                  'Rs.${machine.pricePerLitre.toStringAsFixed(0)}/L',
                  AppTheme.primaryBlue),
              const SizedBox(width: 8),
              _chip(Icons.people, '${machine.totalUsers} users', AppTheme.textGrey),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isOnline
                  ? () {
                      context.read<MachineProvider>().selectMachine(machine);
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Use This Machine',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}