import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const AutoVentasApp());
}
const String kScriptUrl = "https://script.google.com/macros/s/AKfycbwCJoLUxBHrlJd7Rz4VTyiptxNmVJSUP77oYjR3om2rUHwovWxsuiulQfeefcTp4ZZZ/exec";

class AutoVentasApp extends StatelessWidget {
  const AutoVentasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoVentas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// ============================================================================
// SERVICIO DE CONEXIÓN CON GOOGLE SHEETS (LAS 7 PESTAÑAS)
// ============================================================================
class SheetsService {
  static List<dynamic> usuarios = [];
  static List<dynamic> productos = [];
  static List<dynamic> clientes = [];
  static Map<String, dynamic>? usuarioActivo;

  static Future<bool> sincronizarTodo() async {
    final res = await http.get(Uri.parse("$kScriptUrl?action=sync"));
    if (res.statusCode == 200 || res.statusCode == 302) {
      final data = json.decode(res.body);
      usuarios = data['usuarios'] ?? [];
      productos = data['productos'] ?? [];
      clientes = data['clientes'] ?? [];
      return true;
    }
    return false;
  }

  static Future<bool> enviarPost(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(kScriptUrl),
      headers: {"Content-Type": "text/plain"},
      body: json.encode(payload),
    );
    return (res.statusCode == 200 || res.statusCode == 302);
  }
}

// ============================================================================
// 1. PANTALLA DE LOGIN Y SINCRONIZACIÓN INICIAL
// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _cargando = false;
  String _mensaje = "";

  Future<void> _iniciarRuta() async {
    setState(() {
      _cargando = true;
      _mensaje = "Sincronizando con Google Sheets...";
    });
    try {
      await SheetsService.sincronizarTodo();
      final user = SheetsService.usuarios.firstWhere(
        (u) =>
            u['Usuario'].toString().trim() == _userCtrl.text.trim() &&
            u['Password'].toString().trim() == _passCtrl.text.trim() &&
            u['Estado'].toString() == "Activo",
        orElse: () => null,
      );

      if (user != null) {
        SheetsService.usuarioActivo = user;
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() => _mensaje = "Usuario o contraseña incorrectos");
      }
    } catch (e) {
      setState(() => _mensaje = "Error de conexión: verifica la URL del Script");
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_shipping, size: 72, color: Color(0xFF1A73E8)),
              const SizedBox(height: 12),
              const Text("AutoVentas",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text("Ventas en Ruta y Distribución",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextField(
                controller: _userCtrl,
                decoration: const InputDecoration(
                  labelText: "Usuario",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (_mensaje.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_mensaje,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _iniciarRuta,
                  child: _cargando
                      ? const CircularProgressIndicator()
                      : const Text("INICIAR RUTA", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. CONTENEDOR PRINCIPAL (4 MÓDULOS EN ESPAÑOL)
// ============================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final List<Widget> _pantallas = const [
    NuevaVentaTab(),
    ClientesRutaTab(),
    CobrosGastosTab(),
    DevolucionesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final vendedor = SheetsService.usuarioActivo?['Nombre'] ?? 'Vendedor';
    return Scaffold(
      appBar: AppBar(
        title: Text("AutoVentas - $vendedor", style: const TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: "Actualizar datos de Google Sheets",
            onPressed: () async {
              await SheetsService.sincronizarTodo();
              setState(() {});
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Datos sincronizados con Google Sheets")),
              );
            },
          )
        ],
      ),
      body: _pantallas[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: "Vender"),
          NavigationDestination(icon: Icon(Icons.store), label: "Clientes/GPS"),
          NavigationDestination(icon: Icon(Icons.payments), label: "Cobros/Gastos"),
          NavigationDestination(icon: Icon(Icons.assignment_return), label: "Mermas"),
        ],
      ),
    );
  }
}

// ============================================================================
// MÓDULO A: CATÁLOGO CON BOTONES + / - Y CARRITO AUTOMÁTICO
// ============================================================================
class NuevaVentaTab extends StatefulWidget {
  const NuevaVentaTab({super.key});

  @override
  State<NuevaVentaTab> createState() => _NuevaVentaTabState();
}

class _NuevaVentaTabState extends State<NuevaVentaTab> {
  Map<String, dynamic>? _clienteSeleccionado;
  final Map<String, int> _carrito = {}; // ID_Producto -> Cantidad
  String _tipoPago = "Contado";
  bool _enviando = false;

  double get _totalCarrito {
    double total = 0;
    _carrito.forEach((idProd, cant) {
      final prod = SheetsService.productos.firstWhere((p) => p['ID_Producto'].toString() == idProd);
      final precio = double.tryParse(prod['Precio_Venta'].toString()) ?? 0;
      total += precio * cant;
    });
    return total;
  }

  void _modificarCantidad(String idProd, int delta, int stockMax) {
    setState(() {
      final actual = _carrito[idProd] ?? 0;
      final nuevo = actual + delta;
      if (nuevo <= 0) {
        _carrito.remove(idProd);
      } else if (nuevo <= stockMax) {
        _carrito[idProd] = nuevo;
      }
    });
  }

  Future<void> _finalizarVenta() async {
    if (_clienteSeleccionado == null || _carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona un cliente y al menos 1 producto")),
      );
      return;
    }

    if (_tipoPago == "Credito") {
      final deuda = double.tryParse(_clienteSeleccionado!['Deuda_Actual'].toString()) ?? 0;
      final limite = double.tryParse(_clienteSeleccionado!['Limite_Credito'].toString()) ?? 0;
      if ((deuda + _totalCarrito) > limite) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Supera el límite de crédito disponible (\$${(limite - deuda).toStringAsFixed(2)})")),
        );
        return;
      }
    }

    setState(() => _enviando = true);

    final items = _carrito.entries.map((e) {
      final p = SheetsService.productos.firstWhere((prod) => prod['ID_Producto'].toString() == e.key);
      return {
        "idProducto": e.key,
        "nombre": p['Nombre'],
        "cantidad": e.value,
        "precio": double.tryParse(p['Precio_Venta'].toString()) ?? 0,
      };
    }).toList();

    final ok = await SheetsService.enviarPost({
      "action": "registrar_venta",
      "idVendedor": SheetsService.usuarioActivo!['ID_Usuario'],
      "idCliente": _clienteSeleccionado!['ID_Cliente'],
      "tipoPago": _tipoPago,
      "subtotal": _totalCarrito,
      "descuento": 0,
      "total": _totalCarrito,
      "estadoEntrega": "Entregado",
      "items": items,
    });

    if (ok) {
      await SheetsService.sincronizarTodo();
      setState(() => _carrito.clear());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Venta registrada en Google Sheets!")),
      );
    }
    setState(() => _enviando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue.shade50,
          child: Column(
            children: [
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _clienteSeleccionado,
                hint: const Text("Seleccionar Cliente / Tienda"),
                isExpanded: true,
                items: SheetsService.clientes.map((c) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: c,
                    child: Text("${c['Nombre_Tienda']} (Deuda: \$${c['Deuda_Actual']})"),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _clienteSeleccionado = val),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("Pago: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  ChoiceChip(
                    label: const Text("Contado"),
                    selected: _tipoPago == "Contado",
                    onSelected: (_) => setState(() => _tipoPago = "Contado"),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("Crédito"),
                    selected: _tipoPago == "Credito",
                    onSelected: (_) => setState(() => _tipoPago = "Credito"),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: SheetsService.productos.length,
            itemBuilder: (ctx, i) {
              final p = SheetsService.productos[i];
              final id = p['ID_Producto'].toString();
              final stock = int.tryParse(p['Stock_Actual'].toString()) ?? 0;
              final cant = _carrito[id] ?? 0;
              return ListTile(
                title: Text(p['Nombre'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Precio: \$${p['Precio_Venta']} | Stock: $stock"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: cant > 0 ? () => _modificarCantidad(id, -1, stock) : null,
                    ),
                    Text("$cant", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: cant < stock ? () => _modificarCantidad(id, 1, stock) : null,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TOTAL: \$${_totalCarrito.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _enviando ? null : _finalizarVenta,
                icon: const Icon(Icons.check),
                label: Text(_enviando ? "Guardando..." : "CONFIRMAR VENTA"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// MÓDULO B: CLIENTES, DEUDAS Y MAPA GPS
// ============================================================================
class ClientesRutaTab extends StatelessWidget {
  const ClientesRutaTab({super.key});

  Future<void> _abrirMapa(dynamic lat, dynamic lng) async {
    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: SheetsService.clientes.length,
      itemBuilder: (ctx, i) {
        final c = SheetsService.clientes[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(c['Nombre_Tienda'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              "Prop: ${c['Propietario']} | Tel: ${c['Telefono']}\n"
              "Deuda: \$${c['Deuda_Actual']} / Límite: \$${c['Limite_Credito']}",
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.location_on, color: Colors.red, size: 32),
              tooltip: "Navegar con GPS",
              onPressed: () => _abrirMapa(c['Latitud'], c['Longitud']),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// MÓDULO C: COBROS DE DEUDA Y GASTOS DIARIOS DEL VENDEDOR
// ============================================================================
class CobrosGastosTab extends StatefulWidget {
  const CobrosGastosTab({super.key});

  @override
  State<CobrosGastosTab> createState() => _CobrosGastosTabState();
}

class _CobrosGastosTabState extends State<CobrosGastosTab> {
  String _tipo = "Cobro";
  Map<String, dynamic>? _cliente;
  final _montoCtrl = TextEditingController();
  final _conceptoCtrl = TextEditingController();
  bool _guardando = false;

  Future<void> _guardar() async {
    if (_montoCtrl.text.isEmpty) return;
    setState(() => _guardando = true);
    await SheetsService.enviarPost({
      "action": "registrar_cobro_gasto",
      "idVendedor": SheetsService.usuarioActivo!['ID_Usuario'],
      "tipoMovimiento": _tipo,
      "idCliente": _tipo == "Cobro" ? _cliente?['ID_Cliente'] : "N/A",
      "monto": double.tryParse(_montoCtrl.text) ?? 0,
      "concepto": _conceptoCtrl.text,
    });
    await SheetsService.sincronizarTodo();
    _montoCtrl.clear();
    _conceptoCtrl.clear();
    setState(() => _guardando = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Movimiento guardado en Google Sheets")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: "Cobro", label: Text("Cobrar Deuda")),
              ButtonSegment(value: "Gasto", label: Text("Gasto Ruta")),
            ],
            selected: {_tipo},
            onSelectionChanged: (s) => setState(() => _tipo = s.first),
          ),
          const SizedBox(height: 16),
          if (_tipo == "Cobro")
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _cliente,
              hint: const Text("Seleccionar Cliente que abona"),
              isExpanded: true,
              items: SheetsService.clientes.map((c) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: c,
                  child: Text("${c['Nombre_Tienda']} (Debe: \$${c['Deuda_Actual']})"),
                );
              }).toList(),
              onChanged: (v) => setState(() => _cliente = v),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _montoCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Monto (\$)", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _conceptoCtrl,
            decoration: const InputDecoration(
                labelText: "Concepto (Ej. Gasolina, Abono efectivo)",
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(_guardando ? "Guardando..." : "REGISTRAR MOVIMIENTO"),
            ),
          )
        ],
      ),
    );
  }
}

// ============================================================================
// MÓDULO D: DEVOLUCIONES Y MERMAS DE PRODUCTO
// ============================================================================
class DevolucionesTab extends StatefulWidget {
  const DevolucionesTab({super.key});

  @override
  State<DevolucionesTab> createState() => _DevolucionesTabState();
}

class _DevolucionesTabState extends State<DevolucionesTab> {
  Map<String, dynamic>? _cliente;
  Map<String, dynamic>? _producto;
  String _tipoIncidencia = "Merma_Danado";
  final _cantCtrl = TextEditingController(text: "1");
  final _motivoCtrl = TextEditingController();
  bool _guardando = false;

  Future<void> _registrarDevolucion() async {
    if (_producto == null) return;
    setState(() => _guardando = true);
    await SheetsService.enviarPost({
      "action": "registrar_devolucion",
      "idVendedor": SheetsService.usuarioActivo!['ID_Usuario'],
      "idCliente": _cliente?['ID_Cliente'] ?? "Ruta",
      "idProducto": _producto!['ID_Producto'],
      "cantidad": int.tryParse(_cantCtrl.text) ?? 1,
      "tipoIncidencia": _tipoIncidencia,
      "motivo": _motivoCtrl.text,
    });
    await SheetsService.sincronizarTodo();
    _motivoCtrl.clear();
    setState(() => _guardando = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Devolución/Merma registrada")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _cliente,
            hint: const Text("Cliente (Opcional)"),
            isExpanded: true,
            items: SheetsService.clientes.map((c) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: c,
                child: Text(c['Nombre_Tienda'].toString()),
              );
            }).toList(),
            onChanged: (v) => setState(() => _cliente = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _producto,
            hint: const Text("Seleccionar Producto"),
            isExpanded: true,
            items: SheetsService.productos.map((p) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: p,
                child: Text(p['Nombre'].toString()),
              );
            }).toList(),
            onChanged: (v) => setState(() => _producto = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _tipoIncidencia,
            items: const [
              DropdownMenuItem(value: "Merma_Danado", child: Text("Merma / Producto Dañado")),
              DropdownMenuItem(value: "Devolucion_Buen_Estado", child: Text("Devolución en Buen Estado")),
              DropdownMenuItem(value: "Cambio", child: Text("Cambio Mano a Mano")),
            ],
            onChanged: (v) => setState(() => _tipoIncidencia = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cantCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Cantidad", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _motivoCtrl,
            decoration: const InputDecoration(labelText: "Motivo (Ej. Empaque roto)", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _guardando ? null : _registrarDevolucion,
              child: Text(_guardando ? "Guardando..." : "REGISTRAR INCIDENCIA"),
            ),
          )
        ],
      ),
    );
  }
}
