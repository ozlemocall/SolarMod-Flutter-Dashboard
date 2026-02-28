import 'package:flutter/material.dart';
git clone https://github.com/ozlemocall/SolarMod-Flutter-Dashboard.git
void main() {
  runApp(const SolarModApp());
}

class SolarModApp extends StatelessWidget {
  const SolarModApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SolarMod Kontrol Merkezi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SolarDashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SolarDashboardScreen extends StatefulWidget {
  const SolarDashboardScreen({super.key});

  @override
  State<SolarDashboardScreen> createState() => _SolarDashboardScreenState();
}

class _SolarDashboardScreenState extends State<SolarDashboardScreen> {
  // Sistem verileri
  double _batteryLevel = 75.0;
  double _solarPower = 1240.5;
  double _consumption = 850.2;
  double _temperature = 28.7;
  double _panelEfficiency = 82.3;
  double _panelTilt = 30.0;
  double nominalVerim = 100;
  double verimEsigi = 70;
  bool _gridConnection = true;
  bool _systemStatus = true;
  DateTime _lastUpdate = DateTime.now();

  // Panel verimliliğini kontrol eden fonksiyon
  void verimKontrol(double anlikVerim) {
    if (anlikVerim < verimEsigi) {

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEfficiencyWarning();
      });
      print("⚠️ Panel verimliliği düştü, temizlenmesi önerilir!");
    }
  }

  void _showEfficiencyWarning() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Panel Verimlilik Uyarısı'),
          content: const Text(
              'Panel verimliliği düştü, temizlenmesi önerilir!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  // Panel eğim kontrolü
  void _increaseTilt() {
    setState(() {
      _panelTilt = (_panelTilt + 5).clamp(0, 90);
      _lastUpdate = DateTime.now();
    });
  }

  void _decreaseTilt() {
    setState(() {
      _panelTilt = (_panelTilt - 5).clamp(0, 90);
      _lastUpdate = DateTime.now();
    });
  }

  // Batarya kontrol
  void _increaseBattery() {
    setState(() {
      if (_batteryLevel < 100) _batteryLevel += 2.5;
      _lastUpdate = DateTime.now();
    });
  }

  void _decreaseBattery() {
    setState(() {
      if (_batteryLevel > 0) _batteryLevel -= 2.5;
      _lastUpdate = DateTime.now();
    });
  }

  // Sistem ve şebeke kontrol
  void _toggleSystem() {
    setState(() {
      _systemStatus = !_systemStatus;
      _lastUpdate = DateTime.now();
    });
  }

  void _toggleGrid() {
    setState(() {
      _gridConnection = !_gridConnection;
      _lastUpdate = DateTime.now();
    });
  }

  Color _getStatusColor() => _systemStatus ? Colors.green : Colors.red;

  String _getTimeAgo() {
    final difference = DateTime.now().difference(_lastUpdate);
    if (difference.inMinutes < 1) return 'Şimdi';
    if (difference.inMinutes < 60) return '${difference.inMinutes} dk önce';
    return '${difference.inHours} sa önce';
  }

  String _getBatteryStatusText() {
    if (_batteryLevel >= 80) return 'Dolu';
    if (_batteryLevel >= 50) return 'Orta';
    return 'Düşük';
  }

  Color _getBatteryColor() {
    if (_batteryLevel >= 80) return Colors.green;
    if (_batteryLevel >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    // Panel verimliliğini kontrol et
    verimKontrol(_panelEfficiency);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('SolarMod Kontrol Merkezi'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _lastUpdate = DateTime.now()),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSystemStatusCard(),
            const SizedBox(height: 20),
            _buildMetricsRow(),
            const SizedBox(height: 20),
            _buildPanelTiltCard(),
            const SizedBox(height: 20),
            _buildBatteryControlCard(),
            const SizedBox(height: 20),
            _buildEnergyFlowCard(),
            const SizedBox(height: 20),
            _buildStatisticsCard(),
            const SizedBox(height: 20),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  // Widget metotları
  Widget _buildSystemStatusCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(_systemStatus ? Icons.power : Icons.power_off,
                size: 40, color: _getStatusColor()),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_systemStatus ? 'Sistem Aktif' : 'Sistem Kapalı',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_systemStatus ? 'Optimal çalışıyor' : 'Beklemede',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            Switch(
              value: _systemStatus,
              onChanged: (value) => _toggleSystem(),
              activeThumbColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
            child: _buildMetricCard(
                title: 'Üretim',
                value: '${_solarPower.toStringAsFixed(1)} W',
                icon: Icons.wb_sunny,
                color: Colors.orangeAccent)),
        const SizedBox(width: 10),
        Expanded(
            child: _buildMetricCard(
                title: 'Tüketim',
                value: '${_consumption.toStringAsFixed(1)} W',
                icon: Icons.bolt,
                color: Colors.blueAccent)),
        const SizedBox(width: 10),
        Expanded(
            child: _buildMetricCard(
                title: 'Verimlilik',
                value: '${_panelEfficiency.toStringAsFixed(1)}%',
                icon: Icons.show_chart,
                color: Colors.greenAccent)),
      ],
    );
  }

  Widget _buildMetricCard(
          {required String title,
          required String value,
          required IconData icon,
          required Color color}) =>
      Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: color)),
              Text(title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      );

  Widget _buildPanelTiltCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PANEL EĞİM KONTROLÜ',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Eğim: ${_panelTilt.toStringAsFixed(0)}°',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Icon(Icons.explore, color: Colors.grey[700]),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: _panelTilt,
              min: 0,
              max: 90,
              divisions: 18,
              label: '${_panelTilt.toStringAsFixed(0)}°',
              onChanged: (value) {
                setState(() {
                  _panelTilt = value;
                  _lastUpdate = DateTime.now();
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilledButton.icon(
                    onPressed: _decreaseTilt,
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('Aşağı'),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.orangeAccent)),
                FilledButton.icon(
                    onPressed: _increaseTilt,
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Yukarı'),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.greenAccent)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryControlCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('BATARYA DURUMU',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent)),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: _batteryLevel / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(_getBatteryColor()),
                  ),
                ),
                Column(
                  children: [
                    Text('${_batteryLevel.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(_getBatteryStatusText(),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilledButton.icon(
                    onPressed: _decreaseBattery,
                    icon: const Icon(Icons.remove),
                    label: const Text('Azalt'),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent)),
                FilledButton.icon(
                    onPressed: _increaseBattery,
                    icon: const Icon(Icons.add),
                    label: const Text('Arttır'),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.greenAccent)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyFlowCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ENERJİ AKIŞ DİYAGRAMI',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEnergyNode('Güneş Paneli', Icons.wb_sunny, Colors.orange),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                _buildEnergyNode('Batarya', Icons.battery_charging_full, Colors.green),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                _buildEnergyNode('Ev', Icons.home, Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Chip(
                  label: Text('${_solarPower.toStringAsFixed(0)}W'),
                  backgroundColor: Colors.orange[100],
                ),
                Chip(
                  label: Text('${(_solarPower - _consumption).toStringAsFixed(0)}W'),
                  backgroundColor: Colors.green[100],
                ),
                Chip(
                  label: Text('${_consumption.toStringAsFixed(0)}W'),
                  backgroundColor: Colors.blue[100],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyNode(String title, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SİSTEM İSTATİSTİKLERİ',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent)),
            const SizedBox(height: 16),
            _buildStatItem('Sıcaklık', '${_temperature.toStringAsFixed(1)}°C',
                Icons.thermostat),
            _buildStatItem(
                'Şebeke Bağlantısı', _gridConnection ? 'Bağlı' : 'Kesik', Icons.power),
            _buildStatItem('Son Güncelleme', _getTimeAgo(), Icons.access_time),
            _buildStatItem('Panel Verimliliği',
                '${_panelEfficiency.toStringAsFixed(1)}%', Icons.show_chart),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('HIZLI EYLEMLER',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.offline_bolt, size: 16),
                  label: const Text('Şebeke Değiştir'),
                  onPressed: _toggleGrid,
                ),
                ActionChip(
                  avatar: const Icon(Icons.history, size: 16),
                  label: const Text('Geçmiş Veriler'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.warning, size: 16),
                  label: const Text('Uyarılar'),
                  onPressed: () {},
                ),
                ActionChip(
                avatar: const Icon(Icons.show_chart, size: 16),
                label: const Text('Verimliliği Düşür (Test)'),
                onPressed: () {
                setState(() {
                _panelEfficiency = 65; // test için eşikten düşük bir değer
                verimKontrol(_panelEfficiency); // uyarı fonksiyonunu çağır
    });
  },
),

                ActionChip(
                  avatar: const Icon(Icons.bar_chart, size: 16),
                  label: const Text('Raporlar'),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
