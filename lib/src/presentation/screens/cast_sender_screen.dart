import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../controllers/playback_controller.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

/// Main screen for Cast n Play application.
class CastSenderScreen extends StatefulWidget {
  const CastSenderScreen({super.key});

  @override
  State<CastSenderScreen> createState() => _CastSenderScreenState();
}

class _CastSenderScreenState extends State<CastSenderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late PlaybackController _playbackController;

  final List<CastDevice> _availableDevices = const [
    CastDevice(
      id: '1',
      name: DeviceNames.livingRoomTV,
      type: DeviceType.chromecast,
      isConnected: true,
    ),
    CastDevice(
      id: '2',
      name: DeviceNames.bedroomSpeaker,
      type: DeviceType.airplay,
      isConnected: false,
    ),
    CastDevice(
      id: '3',
      name: DeviceNames.kitchenDisplay,
      type: DeviceType.chromecast,
      isConnected: false,
    ),
    CastDevice(
      id: '4',
      name: DeviceNames.patioSpeaker,
      type: DeviceType.airplay,
      isConnected: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDurations.animationDuration,
      vsync: this,
    )..repeat();

    final initialState = PlaybackState(
      progress: MediaContent.initialProgress,
      isPlaying: false,
      currentPosition: MediaContent.initialPosition,
      totalDuration: MediaContent.totalDuration,
      castingMode: CastingMode.audio,
      selectedDevice: _availableDevices.first.id,
    );

    _playbackController = PlaybackController(initialState);
    _playbackController.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _playbackController.removeListener(_onStateChanged);
    _playbackController.dispose();
    super.dispose();
  }

  void _showDeviceSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DeviceSelectorWidget(
        availableDevices: _availableDevices,
        selectedDeviceId: _playbackController.state.selectedDevice,
        onDeviceSelected: _playbackController.selectDevice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.bgDark, AppColors.bgDarkSecondary.fade(0.8)],
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                HeaderWidget(
                  onCastPressed: _showDeviceSelector,
                  isDeviceSelected:
                      _playbackController.state.selectedDevice != null,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          NowPlayingCardWidget(
                            state: _playbackController.state,
                            availableDevices: _availableDevices,
                            onModeChanged: _playbackController.switchMode,
                            onPlayPause: _playbackController.togglePlayPause,
                            onSkipPrevious: _playbackController.skipPrevious,
                            onSkipNext: _playbackController.skipNext,
                            onProgressChanged:
                                _playbackController.updateProgress,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

