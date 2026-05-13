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
    _load();
  }

  Future<void> _load() async {
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

  Future<void> _refresh() async {
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("SMAT - Monitoreo"),
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
          )
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
                          textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text("Reintentar"),
                      )
                    ],
                  ),
                )

              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: estaciones.length,
                    itemBuilder: (context, index) {
                      final e = estaciones[index];

                      return ListTile(
                        leading: const Icon(Icons.satellite_alt),
                        title: Text(e.nombre),
                        subtitle: Text(e.ubicacion),
                      );
                    },
                  ),
                ),

      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}