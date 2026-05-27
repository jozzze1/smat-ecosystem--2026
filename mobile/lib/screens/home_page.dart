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

  List lecturas = [];

  bool loading = true;

  String? error;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    _load();

    // REFRESH AUTOMÁTICO
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        cargarHistorial();
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ==============================
  // CARGAR ESTACIONES
  // ==============================

  Future<void> _load() async {

    setState(() {
      loading = true;
      error = null;
    });

    try {

      final data =
          await ApiService().fetchEstaciones();

      setState(() {
        estaciones = data;
        loading = false;
      });

      // CARGAR HISTORIAL
      await cargarHistorial();

    } catch (e) {

      setState(() {
        loading = false;
        error = "Servidor no disponible";
        estaciones = [];
      });
    }
  }

  // ==============================
  // CARGAR TELEMETRÍA
  // ==============================

  Future<void> cargarHistorial() async {

    try {

      final data =
          await ApiService().fetchHistorial(1);

      setState(() {

        lecturas = data["lecturas"];
      });

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
                  builder: (_) =>
                      const LoginScreen(),
                ),

                (route) => false,
              );
            },
          )
        ],
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : error != null

              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      const Icon(
                        Icons.wifi_off,
                        size: 60,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        error!,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: _load,
                        child: const Text(
                          "Reintentar",
                        ),
                      )
                    ],
                  ),
                )

              : RefreshIndicator(

                  onRefresh: _refresh,

                  child: ListView(

                    physics:
                        const AlwaysScrollableScrollPhysics(),

                    children: [

                      // =========================
                      // ESTACIONES
                      // =========================

                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "Estaciones",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      ...estaciones.map((e) {

                        return ListTile(
                          leading: const Icon(
                            Icons.satellite_alt,
                          ),

                          title: Text(e.nombre),

                          subtitle:
                              Text(e.ubicacion),
                        );
                      }),

                      const Divider(),

                      // =========================
                      // TELEMETRÍA IoT
                      // =========================

                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "Telemetría IoT",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      ...lecturas.reversed.map((v) {

                        final valor =
                            v.toDouble();

                        return Card(

                          color: valor > 70
                              ? Colors.red.shade200
                              : Colors.green.shade100,

                          child: ListTile(

                            leading: Icon(
                              valor > 70
                                  ? Icons.warning
                                  : Icons.water,
                            ),

                            title: Text(
                              "$valor cm",
                            ),

                            subtitle: Text(
                              valor > 70
                                  ? "ALERTA DE INUNDACIÓN"
                                  : "Nivel normal",
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

      floatingActionButton:
          FloatingActionButton(

        onPressed: _refresh,

        child: const Icon(Icons.refresh),
      ),
    );
  }
}