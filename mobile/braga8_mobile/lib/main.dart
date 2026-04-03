import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

/// ===========================
/// API SERVICE
/// ===========================
/// 127.0.0.1 IP Adress Mac
class ApiService {
  final Dio dio = Dio(
    BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/'), 
  );

  // Login
  Future<String?> login(String email, String password) async {
    try {
      final response = await dio.post('login', data: {
        'email': email,
        'password': password,
      });
      return response.data['token']; 
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Fetch tenants
  Future<List<dynamic>> getTenants(String token) async {
    try {
      final response = await dio.get(
        'tenants',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      print('Fetch tenants error: $e');
      return [];
    }
  }
}

/// ===========================
/// MAIN APP
/// ===========================
class MyApp extends StatelessWidget {
  final ApiService api = ApiService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Braga 8 App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(api: api),
    );
  }
}

/// ===========================
/// LOGIN SCREEN
/// ===========================
class LoginScreen extends StatefulWidget {
  final ApiService api;
  LoginScreen({required this.api});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? token;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Braga 8 Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                token = await widget.api.login(
                  emailController.text,
                  passwordController.text,
                );
                if (token != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TenantScreen(api: widget.api, token: token!),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login gagal')));
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===========================
/// TENANT SCREEN
/// ===========================
class TenantScreen extends StatefulWidget {
  final ApiService api;
  final String token;

  TenantScreen({required this.api, required this.token});

  @override
  State<TenantScreen> createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  List tenants = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTenants();
  }

  void loadTenants() async {
    final data = await widget.api.getTenants(widget.token);
    setState(() {
      tenants = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tenants')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tenants.length,
              itemBuilder: (context, index) {
                final tenant = tenants[index];
                return ListTile(
                  title: Text(tenant['nama_tenant'] ?? 'No Name'),
                  subtitle: Text('Unit: ${tenant['nomor_unit'] ?? '-'}'),
                );
              },
            ),
    );
  }
}