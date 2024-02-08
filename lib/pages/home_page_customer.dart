import 'package:flutter/material.dart';
import 'package:help_app/objects/service_call.dart';
import 'package:help_app/pages/provider_profile.dart';
import 'package:help_app/pages/customer_history.dart';
import 'package:help_app/pages/service_call_page.dart';
import 'package:help_app/widgets/call_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

String? userId = FirebaseAuth.instance.currentUser?.uid;

class HomePageCustomer extends StatefulWidget {
  const HomePageCustomer({Key? key}) : super(key: key);

  @override
  State<HomePageCustomer> createState() => HomePageCustomerState();
}

class HomePageCustomerState extends State<HomePageCustomer> {
  bool _isLoading = true;
  List<ServiceCall?> allCalls = [];

  @override
  void initState() {
    super.initState();
    fetchCalls();
  }

  Future<void> fetchCalls() async {
    try {
      List<ServiceCall?> calls = await ServiceCall.getAllCustomerPosts(userId!);
      calls = calls.where((call) => call?.isCompleted == false).toList();
      setState(() {
        allCalls = calls;
        _isLoading = false;
      });
      print("fetched all service calls data successfully");
      print(allCalls[1]?.area);
    } catch (e) {
      print("error occurred while fetching all service calls $e");
    }
  }

  Future<void> _refreshHomePage() async {
    setState(() {
      _isLoading = true;
    });
    await fetchCalls();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Posts"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _refreshHomePage,
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : allCalls.isEmpty
              ? Center(
                  child: Text(
                    'No posts available.',
                    style: TextStyle(fontSize: 24),
                  ),
                )
              : ListView.builder(
                  itemCount: allCalls.length,
                  itemBuilder: (context, index) {
                    return CallCard(call: allCalls[index]);
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePageCustomer(),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProviderProfile(),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HistoryPage(customerId: userId.toString()),
                ),
              );
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceCallPage(),
            ),
          );
        },
        tooltip: 'Add Post',
        child: Icon(Icons.add),
      ),
    );
  }
}
