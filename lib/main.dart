import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import untuk QR code

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Shop Cashier',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        hintColor: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Product> products = [
    Product(name: 'Kopi Americano', price: 20000),
    Product(name: 'Kopi Latte', price: 25000),
    Product(name: 'Kopi Cappuccino', price: 30000),
    Product(name: 'French Fries', price: 15000),
    Product(name: 'Milky', price: 25000),
  ];

  List<Product> cart = [];
  double totalAmount = 0;
  double? cashAmount; // Variabel untuk menyimpan input nominal tunai

  // Variabel untuk input kartu kredit
  String cardNumber = '';
  String expirationDate = '';
  String cvv = '';

  void addToCart(Product product) {
    setState(() {
      cart.add(product);
      totalAmount += product.price;
    });
  }

  void removeFromCart(Product product) {
    setState(() {
      cart.remove(product);
      totalAmount -= product.price;
    });
  }

  void clearCart() {
    setState(() {
      cart.clear();
      totalAmount = 0;
    });
  }

  void showPaymentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Metode Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.money, color: Colors.green),
                title: Text('Tunai'),
                onTap: () {
                  Navigator.of(context).pop();
                  showCashPaymentDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.credit_card, color: Colors.blue),
                title: Text('Kartu Kredit/Debit'),
                onTap: () {
                  Navigator.of(context).pop();
                  showCardPaymentDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.money_off, color: Colors.orange),
                title: Text('E-wallet'),
                onTap: () {
                  Navigator.of(context).pop();
                  processPayment('E-wallet');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showCashPaymentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pembayaran Tunai'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Total belanja: Rp ${totalAmount.toStringAsFixed(2)}'),
              SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Masukkan jumlah uang tunai'),
                onChanged: (value) {
                  setState(() {
                    cashAmount = double.tryParse(value) ?? 0;
                  });
                },
              ),
              SizedBox(height: 20),
              if (cashAmount != null && cashAmount! < totalAmount)
                Text(
                  'Jumlah uang tunai tidak cukup.',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (cashAmount != null && cashAmount! >= totalAmount) {
                  processPayment('Tunai');
                }
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void showCardPaymentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pembayaran Kartu Kredit/Debit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Nomor Kartu'),
                onChanged: (value) {
                  setState(() {
                    cardNumber = value;
                  });
                },
              ),
              TextField(
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(labelText: 'Tanggal Kadaluarsa (MM/YY)'),
                onChanged: (value) {
                  setState(() {
                    expirationDate = value;
                  });
                },
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'CVV'),
                onChanged: (value) {
                  setState(() {
                    cvv = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (cardNumber.isNotEmpty && expirationDate.isNotEmpty && cvv.isNotEmpty) {
                  processPayment('Kartu Kredit/Debit');
                }
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void processPayment(String method) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bukti Pembayaran'),
          content: method == 'E-wallet'
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Pembayaran sebesar Rp ${totalAmount.toStringAsFixed(2)} dengan metode $method.'),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8.0)],
                      ),
                      child: SizedBox(
                        width: 200.0,
                        height: 200.0,
                        child: QrImageView(
                          data: 'Pembayaran Rp ${totalAmount.toStringAsFixed(2)}',
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('QR Code ini adalah bukti pembayaran Anda.'),
                  ],
                )
              : Text(
                  method == 'Tunai'
                      ? 'Pembayaran sebesar Rp ${totalAmount.toStringAsFixed(2)} dengan metode $method telah berhasil. Kembalian: Rp ${(cashAmount! - totalAmount).toStringAsFixed(2)}'
                      : 'Pembayaran sebesar Rp ${totalAmount.toStringAsFixed(2)} dengan metode $method telah berhasil.',
                ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                clearCart(); // Bersihkan keranjang setelah pembayaran berhasil
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coffee Shop Cashier'),
        backgroundColor: Colors.brown[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Panduan'),
                    content: Text(
                      'Selamat datang di aplikasi kasir Coffee Shop! '
                      'Pilih produk dari daftar dan tambahkan ke keranjang belanja. '
                      'Klik Checkout untuk menyelesaikan pembayaran.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Tutup'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown[200]!, Colors.brown[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Selamat Datang di Coffee manager!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 8,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.brown[800],
                          child: Icon(Icons.local_cafe, color: Colors.white),
                        ),
                        title: Text(products[index].name, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Rp ${products[index].price.toString()}'),
                        trailing: IconButton(
                          icon: Icon(Icons.add, color: Colors.orange),
                          onPressed: () {
                            addToCart(products[index]);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Keranjang Belanja (${cart.length})',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown[800]),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(cart[index].name),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        removeFromCart(cart[index]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${cart[index].name} dihapus dari keranjang'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        elevation: 8,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Colors.white,
                        child: ListTile(
                          title: Text(cart[index].name, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Rp ${cart[index].price.toString()}'),
                          trailing: IconButton(
                            icon: Icon(Icons.remove, color: Colors.red),
                            onPressed: () {
                              removeFromCart(cart[index]);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total Belanja:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                    ),
                    Text(
                      'Rp ${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 95, 202, 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  showPaymentDialog();
                },
                child: Text('Checkout', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final double price;

  Product({required this.name, required this.price});
}
