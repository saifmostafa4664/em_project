import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/theme/app_colors.dart';
import '../../core/services/serial_service.dart';
import '../../core/services/local_db_service.dart';
import '../../core/services/sync_service.dart';

class RfidMonitorScreen extends StatefulWidget {
  const RfidMonitorScreen({super.key});

  @override
  State<RfidMonitorScreen> createState() => _RfidMonitorScreenState();
}

class _RfidMonitorScreenState extends State<RfidMonitorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  final _serial = SerialService.instance;
  final _localDb = LocalDbService.instance;
  final _sync = SyncService.instance;

  List<String> _availablePorts = [];
  String? _selectedPort;
  StreamSubscription<RfidScanEvent>? _scanSub;

  List<Map<String, dynamic>> _recentScans = [];
  int _todayCount = 0;
  int _unsyncedCount = 0;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _refreshPorts();
    _loadLocalData();

    // Listen to scan events
    _scanSub = _serial.scanStream.listen(_onScan);
    _serial.addListener(_onSerialStateChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scanSub?.cancel();
    _serial.removeListener(_onSerialStateChange);
    super.dispose();
  }

  void _onSerialStateChange() {
    if (mounted) setState(() {});
  }

  void _refreshPorts() {
    setState(() {
      _availablePorts = _serial.getAvailablePorts();
      if (_availablePorts.isNotEmpty && _selectedPort == null) {
        // Auto-select first port that looks like Arduino (cu.usbmodem or cu.usbserial)
        _selectedPort = _availablePorts.firstWhere(
          (p) => p.contains('usbmodem') || p.contains('usbserial'),
          orElse: () => _availablePorts.first,
        );
      }
    });
  }

  Future<void> _loadLocalData() async {
    final scans = await _localDb.getTodayScans();
    final count = await _localDb.getTodayScanCount();
    final unsynced = await _localDb.getUnsyncedCount();
    if (mounted) {
      setState(() {
        _recentScans = scans;
        _todayCount = count;
        _unsyncedCount = unsynced;
      });
    }
  }

  Future<void> _onScan(RfidScanEvent event) async {
    // Store in local DB
    await _localDb.insertScan(
      cardUid: event.cardUid,
      scanTime: event.timestamp,
    );

    // Reload data
    await _loadLocalData();

    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  void _toggleConnection() {
    if (_serial.isConnected) {
      _serial.disconnect();
    } else if (_selectedPort != null) {
      _serial.connect(_selectedPort!);
    }
  }

  Future<void> _syncToFirebase() async {
    setState(() => _isSyncing = true);
    try {
      final count = await _sync.syncToFirebase();
      await _loadLocalData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              count > 0
                  ? '✅ تم رفع $count سجل على Firebase بنجاح'
                  : 'لا توجد سجلات جديدة للرفع',
              style: const TextStyle(fontFamily: 'Zain'),
            ),
            backgroundColor:
                count > 0 ? AppColors.statusPresent : AppColors.textMedium,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ في الرفع: $e',
                style: const TextStyle(fontFamily: 'Zain')),
            backgroundColor: AppColors.alertDanger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: FadeTransition(
          opacity: _fade,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildConnectionCard(),
                      const SizedBox(height: 16),
                      _buildStatsRow(),
                      const SizedBox(height: 16),
                      _buildSyncCard(),
                      const SizedBox(height: 16),
                      _buildRecentScansCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Bar ──
  Widget _buildTopBar() {
    return Container(
      color: AppColors.darkNavy,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primary, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.nfc_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مراقبة RFID',
                    style: TextStyle(
                      fontFamily: 'Zain',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                    ),
                  ),
                  Text(
                    'RFID Live Monitor',
                    style: TextStyle(
                      fontFamily: 'Zain',
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Connection status dot
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (_serial.isConnected
                          ? AppColors.connected
                          : AppColors.disconnected)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _serial.isConnected
                            ? AppColors.connected
                            : AppColors.disconnected,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _serial.isConnected ? 'متصل' : 'غير متصل',
                      style: TextStyle(
                        fontFamily: 'Zain',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _serial.isConnected
                            ? AppColors.connected
                            : AppColors.disconnected,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Connection Card ──
  Widget _buildConnectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.usb_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'اتصال الأردوينو',
                style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _refreshPorts,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.refresh_rounded,
                          size: 14, color: AppColors.textMedium),
                      SizedBox(width: 4),
                      Text('تحديث',
                          style: TextStyle(
                              fontFamily: 'Zain',
                              fontSize: 12,
                              color: AppColors.textMedium)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Port selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPort,
                isExpanded: true,
                hint: const Text('اختر المنفذ',
                    style: TextStyle(
                        fontFamily: 'Zain',
                        fontSize: 14,
                        color: AppColors.textGrey)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textGrey),
                items: _availablePorts.map((port) {
                  final desc = _serial.getPortDescription(port);
                  return DropdownMenuItem(
                    value: port,
                    child: Text(
                      desc.isNotEmpty ? '$desc ($port)' : port,
                      style: const TextStyle(
                        fontFamily: 'Zain',
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: _serial.isConnected
                    ? null
                    : (val) => setState(() => _selectedPort = val),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Connect / Disconnect button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _selectedPort == null ? null : _toggleConnection,
              icon: Icon(
                _serial.isConnected
                    ? Icons.link_off_rounded
                    : Icons.link_rounded,
                size: 20,
              ),
              label: Text(
                _serial.isConnected ? 'قطع الاتصال' : 'اتصال',
                style: const TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _serial.isConnected
                    ? AppColors.alertDanger
                    : AppColors.primary,
                foregroundColor:
                    _serial.isConnected ? AppColors.textWhite : AppColors.textDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),

          // Error message
          if (_serial.lastError.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.alertDangerBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.alertDanger, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _serial.lastError,
                      style: const TextStyle(
                        fontFamily: 'Zain',
                        fontSize: 12,
                        color: AppColors.alertDanger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Stats Row ──
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.nfc_rounded,
            iconColor: AppColors.primary,
            iconBg: AppColors.primary.withValues(alpha: 0.12),
            title: 'مسحات اليوم',
            value: '$_todayCount',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.cloud_upload_outlined,
            iconColor: AppColors.alertWarning,
            iconBg: AppColors.alertWarningBg,
            title: 'في انتظار الرفع',
            value: '$_unsyncedCount',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: _serial.isConnected
                ? Icons.sensors_rounded
                : Icons.sensors_off_rounded,
            iconColor: _serial.isConnected
                ? AppColors.connected
                : AppColors.disconnected,
            iconBg: (_serial.isConnected
                    ? AppColors.connected
                    : AppColors.disconnected)
                .withValues(alpha: 0.12),
            title: 'حالة الجهاز',
            value: _serial.isConnected ? 'نشط' : 'معطل',
          ),
        ),
      ],
    );
  }

  // ── Sync Card ──
  Widget _buildSyncCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud_sync_rounded,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مزامنة مع Firebase',
                  style: TextStyle(
                    fontFamily: 'Zain',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                  ),
                ),
                Text(
                  '$_unsyncedCount سجل في الانتظار',
                  style: const TextStyle(
                    fontFamily: 'Zain',
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed:
                  _isSyncing || _unsyncedCount == 0 ? null : _syncToFirebase,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: _isSyncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textDark,
                      ),
                    )
                  : const Text(
                      'رفع الآن',
                      style: TextStyle(
                        fontFamily: 'Zain',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent Scans Card ──
  Widget _buildRecentScansCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'آخر المسحات',
                style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_recentScans.length} سجل',
                  style: const TextStyle(
                    fontFamily: 'Zain',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Table header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('#', style: _headerStyle)),
                Expanded(
                    flex: 5,
                    child: Text('رقم الكارت', style: _headerStyle)),
                Expanded(
                    flex: 4,
                    child: Text('التاريخ', style: _headerStyle)),
                Expanded(
                    flex: 3,
                    child: Text('الوقت', style: _headerStyle)),
                Expanded(
                    flex: 2,
                    child: Text('الحالة',
                        style: _headerStyle, textAlign: TextAlign.center)),
              ],
            ),
          ),

          if (_recentScans.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.nfc_rounded,
                        size: 48, color: AppColors.textGrey),
                    SizedBox(height: 8),
                    Text(
                      'في انتظار مسح كارت...',
                      style: TextStyle(
                        fontFamily: 'Zain',
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                    Text(
                      'قم بتوصيل الأردوينو ومسح كارت RFID',
                      style: TextStyle(
                        fontFamily: 'Zain',
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(
              _recentScans.length > 20 ? 20 : _recentScans.length,
              (i) => _ScanRow(
                index: i + 1,
                data: _recentScans[i],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Header Style ──
const _headerStyle = TextStyle(
  fontFamily: 'Zain',
  fontSize: 12,
  fontWeight: FontWeight.w700,
  color: AppColors.textLight,
);

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 11,
                  color: AppColors.textLight)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark)),
        ],
      ),
    );
  }
}

// ── Scan Row ──
class _ScanRow extends StatelessWidget {
  final int index;
  final Map<String, dynamic> data;
  const _ScanRow({required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    final scanTime = DateTime.tryParse(data['scan_time'] ?? '');
    final dateStr = scanTime != null
        ? DateFormat('dd/MM/yyyy').format(scanTime)
        : '--';
    final timeStr = scanTime != null
        ? DateFormat('hh:mm:ss a').format(scanTime)
        : '--';
    final synced = (data['synced'] as int?) == 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$index',
              style: const TextStyle(
                fontFamily: 'Zain',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                data['card_uid'] ?? '--',
                style: const TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 4,
            child: Text(
              dateStr,
              style: const TextStyle(
                fontFamily: 'Zain',
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              timeStr,
              style: const TextStyle(
                fontFamily: 'Zain',
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: synced
                      ? AppColors.statusPresentBg
                      : AppColors.alertWarningBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  synced
                      ? Icons.cloud_done_rounded
                      : Icons.cloud_upload_outlined,
                  size: 14,
                  color: synced
                      ? AppColors.statusPresent
                      : AppColors.alertWarning,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
