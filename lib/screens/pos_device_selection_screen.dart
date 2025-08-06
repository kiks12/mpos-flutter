
import 'package:flutter/material.dart';
import 'package:mpos/screens/home/home_screen_two.dart';
import 'package:mpos/screens/splash_screen.dart';
import 'package:mpos/services/shared_preferences_service.dart';
import 'package:mpos/types/pos_device.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class PosDeviceSelectionScreen extends StatefulWidget {
  const PosDeviceSelectionScreen({Key? key}) : super(key: key);

  @override
  State<PosDeviceSelectionScreen> createState() => _PosDeviceSelectionScreenState();
}

class _PosDeviceSelectionScreenState extends State<PosDeviceSelectionScreen> {
  List<PosDevice> posDevices = [];
  PosDevice? selectedPosDevice;
  bool isLoading = true;
  bool isSelecting = false;

  @override
  void initState() {
    super.initState();
    fetchPosDevices();
  }

  Future<void> fetchPosDevices() async {
    try {
      final userId = await SharedPreferencesService.get("user_id");
      
      if (userId == null) {
        _showSnackBar("User ID not found. Please login again.", isError: true);
        return;
      }

      final devicesResponse = await Supabase.instance.client
          .from("pos_devices")
          .select("*,locations(*)")
          .eq("user_id", userId);

      setState(() {
        posDevices = devicesResponse
            .map((device) => PosDevice.fromSupabaseRes(device))
            .toList();
        isLoading = false;
      });

      if (posDevices.isEmpty) {
        _showSnackBar("No POS devices found. Please contact support.", isError: true);
      }
    } catch (error) {
      setState(() => isLoading = false);
      _showSnackBar("Failed to load devices. Please try again.", isError: true);
    }
  }

  Future<void> logout() async {
    SharedPreferencesService.clear();

    if (mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const SplashScreen()), (Route<dynamic> route) => false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> selectPosDevice() async {
    if (selectedPosDevice == null) {
      _showSnackBar("Please select a POS device to continue", isError: true);
      return;
    }

    setState(() => isSelecting = true);

    try {
      await SharedPreferencesService.save('device_id', selectedPosDevice!.id);
      await SharedPreferencesService.save('device_name', selectedPosDevice!.name);
      await SharedPreferencesService.save('device_token', selectedPosDevice!.deviceToken);
      await SharedPreferencesService.save('location_name', selectedPosDevice!.location?.name ?? "No Location");
      await SharedPreferencesService.save('location_id', selectedPosDevice!.location?.id ?? "No Location ID");

      _showSnackBar("Device selected successfully!");
      
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const HomeScreenTwo()), (Route<dynamic> route) => false);
      }
    } catch (error) {
      _showSnackBar("Failed to select device. Please try again.", isError: true);
    } finally {
      if (mounted) {
        setState(() => isSelecting = false);
      }
    }
  }

  Widget _buildDeviceCard(PosDevice device) {
    final isSelected = selectedPosDevice?.id == device.id;
    
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            selectedPosDevice = device;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Device Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.point_of_sale,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Device Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Device ID: ${device.id.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Location: ${device.location?.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selection Indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No POS Devices Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please contact support to set up your devices',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: fetchPosDevices,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(onPressed: logout, icon: Icon(Icons.logout)),
        title: const Text('Select POS Device'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey[800],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading your devices...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : posDevices.isEmpty
                    ? _buildEmptyState()
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Section
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.devices,
                                      size: 48,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Choose Your POS Device',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Select the device you want to use for transactions',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Device List
                            Expanded(
                              child: ListView.separated(
                                itemCount: posDevices.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return _buildDeviceCard(posDevices[index]);
                                },
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Continue Button
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: (selectedPosDevice != null && !isSelecting) 
                                    ? selectPosDevice 
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: isSelecting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.arrow_forward),
                                          const SizedBox(width: 8),
                                          Text(
                                            selectedPosDevice != null 
                                                ? 'Continue with ${selectedPosDevice!.name}'
                                                : 'Select a device to continue',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}