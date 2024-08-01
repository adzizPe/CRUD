import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'item_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ItemProvider(),
      child: MaterialApp(
        home: HomeScreen(),
        debugShowCheckedModeBanner: false, // Hilangkan label debug
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hilangkan ikon kembali
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Text('CRUD App'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text;
              if (name.isNotEmpty) {
                Provider.of<ItemProvider>(context, listen: false).addItem(name);
                _nameController.clear();
              }
            },
            child: Text('Add Item'),
          ),
          Expanded(
            child: Consumer<ItemProvider>(
              builder: (context, provider, _) {
                final items = provider.searchItems(_searchQuery);
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _nameController.text = item.name;
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Edit Item'),
                                  content: TextField(
                                    controller: _nameController,
                                    decoration: InputDecoration(labelText: 'New Name'),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        final newName = _nameController.text;
                                        if (newName.isNotEmpty) {
                                          Provider.of<ItemProvider>(context, listen: false)
                                              .updateItem(item.id, newName);
                                          _nameController.clear();
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: Text('Update'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              Provider.of<ItemProvider>(context, listen: false).deleteItem(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Item deleted'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      Provider.of<ItemProvider>(context, listen: false).undoDelete();
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
