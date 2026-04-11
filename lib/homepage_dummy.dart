import 'dart:async';
import 'package:appweb/regiter.dart';
import 'package:flutter/material.dart';
import 'package:appweb/workers/modelworkers.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Worker> workers = [];
  List<Worker> filteredWorkers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWorkers();
  }

  Future<void> callNumber(String phone) async {
    final Uri uri = Uri.parse("tel:$phone");
    if (!await launchUrl(uri)) throw Exception('Cannot launch dialer');
  }

  void loadWorkers() async {
    try {
      final fetchedWorkers = await fetchWorkers();
      setState(() {
        workers = fetchedWorkers;
        filteredWorkers = [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching workers: $e");
    }
  }

  void searchWorker(String query) {
    if (query.isEmpty) {
      setState(() => filteredWorkers = []);
      return;
    }
    setState(() {
      filteredWorkers = workers
          .where(
            (w) =>
                w.fullname.toLowerCase().contains(query.toLowerCase()) ||
                w.job.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEFF5), // خلفية هادئة
      appBar: AppBar(
        title: const Text("Find a Worker"),
        centerTitle: true,
        backgroundColor: const Color(0xFF3949AB),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Box
            TextField(
              controller: _searchController,
              onChanged: searchWorker,
              decoration: InputDecoration(
                hintText: "Search by job or name...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Workers List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredWorkers.isEmpty
                  ? const Center(
                      child: Text(
                        "No results found",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      itemCount: filteredWorkers.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.65,
                          ),
                      itemBuilder: (context, index) {
                        final w = filteredWorkers[index];

                        // 🌈 Gradient colors based on index
                        final gradientColors = [
                          [Colors.blue.shade400, Colors.blue.shade600],
                          [Colors.purple.shade400, Colors.purple.shade600],
                          [Colors.orange.shade400, Colors.orange.shade600],
                          [Colors.green.shade400, Colors.green.shade600],
                        ];
                        final colors =
                            gradientColors[index % gradientColors.length];

                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white70,
                                child: Text(
                                  w.fullname.isNotEmpty ? w.fullname[0] : '?',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                w.fullname,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                w.job,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                w.phoneNumber,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                w.address,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.phone,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => callNumber(w.phoneNumber),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
