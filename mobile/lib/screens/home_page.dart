import 'dart:async';
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

  // Map que almacena las lecturas usando el ID de la estación como llave
  Map<int, List> lecturasPorEstacion = {};

  bool loading = true;
  String? error;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    _load();

    // Actualización automática cada 3 segundos
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => cargarHistorial(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // =========================
  // CARGAR ESTACIONES
  // =========================
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

      await cargarHistorial();
    } catch (e) {
      setState(() {
        loading = false;
        error = "Servidor no disponible";
        estaciones = [];
      });
    }
  }

  // =========================
  // TELEMETRÍA POR ESTACIÓN
  // =========================
  Future<void> cargarHistorial() async {
    try {
      for (var est in estaciones) {
        final data = await ApiService().fetchHistorial(est.id);
        lecturasPorEstacion[est.id] = data["lecturas"];
      }

      setState(() {});
    } catch (e) {
      print(e);
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
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
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
                      const Icon(Icons.wifi_off, size: 60, color: Colors.red),
                      const SizedBox(height: 10),
                      Text(error!, textAlign: TextAlign.center),
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
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "Estaciones Disponibles",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      // =======================================================
                      // DISEÑO ANIDADO: ESTACIONES + TELEMETRÍA
                      // =======================================================
                      ...estaciones.map((est) {
                        final lecturas = lecturasPorEstacion[est.id] ?? [];

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          elevation: 2,
                          child: ExpansionTile(
                            leading: const Icon(Icons.satellite_alt),
                            title: Text(
                              est.nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(est.ubicacion),
                            
                            // Aquí adentro se renderizan los sensores de esta estación específica
                            children: [
                              if (lecturas.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text("Sin lecturas recientes disponible."),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Divider(),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                                        child: Text(
                                          "Historial de Telemetría IoT",
                                          style: TextStyle(
                                            fontSize: 14, 
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey
                                          ),
                                        ),
                                      ),
                                      
                                      // Lista interna de lecturas
                                      ...lecturas.reversed.map((v) {
                                        final valor = v.toDouble();
                                        final esAlerta = valor > 70;

                                        return Card(
                                          color: esAlerta
                                              ? Colors.red.shade100
                                              : Colors.green.shade50,
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          child: ListTile(
                                            leading: Icon(
                                              esAlerta ? Icons.warning : Icons.water,
                                              color: esAlerta ? Colors.red : Colors.green,
                                            ),
                                            title: Text(
                                              "$valor cm",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: esAlerta ? Colors.red.shade900 : Colors.green.shade900,
                                              ),
                                            ),
                                            subtitle: Text(
                                              esAlerta ? "ALERTA DE INUNDACIÓN" : "Nivel normal",
                                              style: TextStyle(
                                                color: esAlerta ? Colors.red.shade700 : Colors.green.shade700,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}