import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DaftarMenuScreen extends StatefulWidget {
  final String uid;

  const DaftarMenuScreen({super.key, required this.uid});

  @override
  State<DaftarMenuScreen> createState() => _DaftarMenuScreenState();
}

class _DaftarMenuScreenState extends State<DaftarMenuScreen> {
  late CollectionReference<Map<String, dynamic>> _products;
  List<int> quantities = [];
  double totalPrice = 0;
  String searchQuery = '';
  // Add more controllers as needed for other fields
  late File _imageFile;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _products = FirebaseFirestore.instance.collection('products');
    _loadData();
  }

  Future<void> _loadData() async {
    final productsSnapshot = await _products.get();
    quantities = List<int>.filled(productsSnapshot.docs.length, 0);
  }

  Future<void> addProduct(name, price) async {
    try {
      String imageUrl = await _uploadImage();
      await _products.add({
        'name': name,
        'price': int.parse(price),
        'imageUrl': imageUrl,
        // Add other fields as needed
      });
      print("Product Added");
    } catch (error) {
      print("Failed to add product: $error");
    }
  }

  Future<void> editProduct(
      DocumentSnapshot<Object?> product, name, price) async {
    int editedPrice = 0;
    try {
      // Retrieve values from controllers
      String editedName = name;
      editedPrice = int.parse(price);

      // Check if

      await _products.doc(product.id).update({
        'name': editedName,
        'price': editedPrice,
        // Update other fields as needed
      });

      print("Product Updated");
    } catch (error) {
      print("Failed to update product: $error");
    }
  }

  Future<void> deleteProduct(DocumentSnapshot<Object?> product) async {
    try {
      await _products.doc(product.id).delete();
      print("Product Deleted");
    } catch (error) {
      print("Failed to delete product: $error");
    }
  }

  Future<String> _uploadImage() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        throw Exception("No image selected");
      }

      _imageFile = File(pickedFile.path);
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.png');
      UploadTask uploadTask = storageRef.putFile(_imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (error) {
      print("Failed to upload image: $error");
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Daftar Menu'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (searchQuery.isNotEmpty)
            ? _products
                .where('name',
                    isGreaterThanOrEqualTo: searchQuery.toLowerCase())
                .snapshots()
            : _products.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          var products = snapshot.data!.docs;
          print(products);

          if (quantities.length != products.length) {
            // Ensure lengths match, reinitialize quantities
            quantities = List<int>.filled(products.length, 0);
          }

          return SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Column(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(color: Colors.green),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Cari Menu',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12.0,
                        ),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var productData =
                        products[index].data() as Map<String, dynamic>;

                    // Check if 'imageUrl' exists and is not null
                    String imageUrl = productData['imageUrl'] ?? '';

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _showEditDeleteDialog(products[index]);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        height: 60,
                        child: Row(
                          children: [
                            // Use Image.network to fetch and display images from the URL
                            Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(productData['name'] ?? ''),
                                  Text('Rp.${productData['price'] ?? ''}'),
                                ],
                              ),
                            ),
                            Spacer(),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (quantities[index] > 0) {
                                        quantities[index]--;
                                        totalPrice -= productData['price'] ?? 0;
                                      }
                                    });
                                  },
                                  icon: Icon(Icons.remove),
                                ),
                                Text('${quantities[index]}'),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      quantities[index]++;
                                      totalPrice += productData['price'] ?? 0;
                                    });
                                  },
                                  icon: Icon(Icons.add),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
        height: 60,
        width: double.maxFinite,
        color: Colors.green,
        child: ElevatedButton(
          onPressed: () {
            if (totalPrice != 0) {
              setState(() {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Terima kasih! Pembayaran sebesar Rp.${totalPrice.toStringAsFixed(2)} diterima.'),
                    duration: Duration(
                        seconds: 3), // You can adjust the duration as needed
                  ),
                );
                totalPrice = 0;
                quantities = List<int>.filled(quantities.length, 0);
              });
            }
          },
          child: Text("Total Harga: Rp.${totalPrice}"),
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.green),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProductDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _showAddProductDialog() async {
    TextEditingController addNameController = TextEditingController();
    TextEditingController addPriceController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                // Name field
                TextFormField(
                  controller: addNameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 10),
                // Price field
                TextFormField(
                  controller: addPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                SizedBox(height: 10),
                // Image upload button

                SizedBox(height: 20),
                // Save button
                ElevatedButton(
                  onPressed: () {
                    print('$addNameController $addPriceController');

                    // Implement your logic to add a new product
                    addProduct(addNameController.text, addPriceController.text);
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Add + Upload Img'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditDeleteDialog(DocumentSnapshot<Object?> product) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit/Delete Product'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                // Edit button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    _showEditProductDialog(product);
                  },
                  child: Text('Edit'),
                ),
                SizedBox(height: 10),
                // Delete button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    _showDeleteProductDialog(product);
                  },
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditProductDialog(DocumentSnapshot<Object?> product) async {
    TextEditingController editNameController = TextEditingController();
    TextEditingController editPriceController = TextEditingController();

    editNameController.text = product['name'] ?? '';
    editPriceController.text = (product['price'] ?? 0).toString();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                // Name field
                TextFormField(
                  controller: editNameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 10),
                // Price field
                TextFormField(
                  controller: editPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                SizedBox(height: 20),
                // Save button
                ElevatedButton(
                  onPressed: () {
                    // Implement your logic to update the product data
                    editProduct(product, editNameController.text,
                        editPriceController.text);
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to show Delete Product dialog
  Future<void> _showDeleteProductDialog(
      DocumentSnapshot<Object?> product) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete this product?'),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            // Delete button
            ElevatedButton(
              onPressed: () {
                // Implement your logic to delete the product
                deleteProduct(product);
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
