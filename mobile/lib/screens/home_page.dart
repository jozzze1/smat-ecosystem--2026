import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/estacion.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Estacion> estaciones = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await ApiService().fetchEstaciones();

      setState(() {
        estaciones = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = "Servidor no disponible";
        estaciones = [];
      });
    }
  }

  Future<void> refresh() async {
    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMAT - Monitoreo Móvil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off,
                          size: 60, color: Colors.red),
                      const SizedBox(height: 10),
                      Text(error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: loadData,
                        child: const Text("Reintentar"),
                      )
                    ],
                  ),
                )

              : RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: estaciones.length,
                    itemBuilder: (context, index) {
                      final est = estaciones[index];

                      return ListTile(
                        leading: const Icon(Icons.satellite_alt),
                        title: Text(est.nombre),
                        subtitle: Text(est.ubicacion),
                      );
                    },
                  ),
                ),

      floatingActionButton: FloatingActionButton(
        onPressed: refresh,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}