import 'package:flutter/material.dart';

import 'services/api_service.dart';
import 'services/auth_service.dart';

import 'models/estacion.dart';

import 'screens/login_screen.dart';

void main() => runApp(const SMATApp());

class SMATApp extends StatelessWidget {
  const SMATApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'SMAT Mobile',

      // =====================================
      // VERIFICACIÓN DE TOKEN
      // =====================================

      home: FutureBuilder<String?>(
        future: AuthService().getToken(),

        builder: (context, snapshot) {

          // Loading inicial
          if (
              snapshot.connectionState ==
              ConnectionState.waiting
          ) {

            return const Scaffold(
              body: Center(
                child:
                    CircularProgressIndicator(),
              ),
            );
          }

          // Si existe token -> HOME
          if (
              snapshot.hasData &&
              snapshot.data != null
          ) {

            return const HomePage();
          }

          // Si no existe token -> LOGIN
          return const LoginScreen();
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {

  late Future<List<Estacion>>
      futureEstaciones;

  @override
  void initState() {

    super.initState();

    futureEstaciones =
        ApiService().fetchEstaciones();
  }

  // =====================================
  // REFRESH
  // =====================================

  Future<void> refrescar() async {

     print("REFRESH EJECUTADO");

    setState(() {

      futureEstaciones =
          ApiService()
              .fetchEstaciones();
    });

    await futureEstaciones;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // ===================================
      // APPBAR
      // ===================================

      appBar: AppBar(

        title: const Text(
          'SMAT - Monitoreo Móvil',
        ),

        actions: [

          // LOGOUT
          IconButton(

            icon: const Icon(
              Icons.logout,
            ),

            onPressed: () async {

              await AuthService()
                  .logout();

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
          ),
        ],
      ),

      // ===================================
      // BODY
      // ===================================

      body:
          FutureBuilder<List<Estacion>>(

        future: futureEstaciones,

        builder: (
          context,
          snapshot,
        ) {

          // ===============================
          // LOADING
          // ===============================

          if (
              snapshot.connectionState ==
              ConnectionState.waiting
          ) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          // ===============================
          // ERROR
          // ===============================

          if (snapshot.hasError) {

            return const Center(

              child: Padding(

                padding: EdgeInsets.all(20),

                child: Text(

                  "No se pudo conectar con el servidor. Verifica tu conexión o intenta más tarde.",
                  style: TextStyle(

                    color: Colors.red,
                    fontSize: 16,
                  ),

                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          // ===============================
          // LISTA VACÍA
          // ===============================

          if (
              !snapshot.hasData ||
              snapshot.data!.isEmpty
          ) {

            return const Center(

              child: Text(
                "No hay estaciones registradas",
              ),
            );
          }

          // ===============================
          // PULL TO REFRESH
          // ===============================

          return RefreshIndicator(

            onRefresh: refrescar,

            child: ListView.builder(

              // IMPORTANTE:
              // permite refresh aunque
              // haya pocos elementos

              physics:
                  const AlwaysScrollableScrollPhysics(),

              itemCount:
                  snapshot.data!.length,

              itemBuilder: (
                context,
                index,
              ) {

                final est =
                    snapshot.data![index];

                return ListTile(

                  leading: const Icon(
                    Icons.satellite_alt,
                  ),

                  title:
                      Text(est.nombre),

                  subtitle:
                      Text(est.ubicacion),
                );
              },
            ),
          );
        },
      ),

      // ===================================
      // BOTÓN REFRESH MANUAL
      // ===================================

      floatingActionButton:
          FloatingActionButton(

        onPressed: refrescar,

        child: const Icon(
          Icons.refresh,
        ),
      ),
    );
  }
}