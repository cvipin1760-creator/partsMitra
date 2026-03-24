import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class StaffMechanicLocationsScreen extends StatefulWidget {
  const StaffMechanicLocationsScreen({super.key});

  @override
  State<StaffMechanicLocationsScreen> createState() =>
      _StaffMechanicLocationsScreenState();
}

class _StaffMechanicLocationsScreenState
    extends State<StaffMechanicLocationsScreen> {
  final _auth = AuthService();
  List<User> _mechanics = [];
  bool _loading = true;
  Position? _myPos;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final users = await _auth.getAllUsers();
      final ms = users
          .where((u) =>
              u.roles.contains(Constants.roleMechanic) &&
              u.latitude != null &&
              u.longitude != null)
          .toList();
      Position? pos;
      try {
        final enabled = await Geolocator.isLocationServiceEnabled();
        if (enabled) {
          LocationPermission perm = await Geolocator.checkPermission();
          if (perm == LocationPermission.denied) {
            perm = await Geolocator.requestPermission();
          }
          if (perm == LocationPermission.always ||
              perm == LocationPermission.whileInUse) {
            pos = await Geolocator.getCurrentPosition();
          }
        }
      } catch (_) {}
      if (mounted) {
        setState(() {
          _mechanics = ms;
          _myPos = pos;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  double? _distanceKm(User u) {
    if (_myPos == null || u.latitude == null || u.longitude == null) return null;
    final d = Geolocator.distanceBetween(
        _myPos!.latitude, _myPos!.longitude, u.latitude!, u.longitude!);
    return d / 1000.0;
    }

  Future<void> _openMap(User u) async {
    if (u.latitude == null || u.longitude == null) return;
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${u.latitude},${u.longitude}');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_mechanics.isEmpty) {
      return const Center(child: Text('No mechanics have shared location yet.'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, i) {
          final u = _mechanics[i];
          final km = _distanceKm(u);
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(u.name ?? u.email),
            subtitle: Text(
                'Lat: ${u.latitude?.toStringAsFixed(5) ?? '-'}, Lng: ${u.longitude?.toStringAsFixed(5) ?? '-'}'
                '${km != null ? ' • ${km.toStringAsFixed(1)} km away' : ''}'),
            trailing: IconButton(
              icon: const Icon(Icons.map),
              onPressed: () => _openMap(u),
              tooltip: 'Open in Maps',
            ),
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: _mechanics.length,
      ),
    );
  }
}
