import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<String> banners = [
    "https://lh3.googleusercontent.com/aida-public/AB6AXuASOQaNhIqQRp7aCIyGH9cNbUd3jR4lEVUaYBNJFlODaw1FGL33Wa6lsYirIMvtI9vRqiiJScdZQrqxoUkAEvXaAGfju8wopOhkDRHJbQBwxGGMt8XzQk0Km0dSRLn7dqsQ0tZnERItnQLsYnq_yCAfRQP0RY07e2sjeTMixAhHP93SFPcUUcODbBPlWMlF6LCo7LmyiTJKMGneN1vBMS_nFzSDExmxHDFOyFmpAs-mg4-um7RW4XHtRHa2YNHa4A3GbXveieDV2IiA",
    "https://lh3.googleusercontent.com/aida-public/AB6AXuAz8vnBNeiQivC99ImfqYb_xZAVrznYzAwqlAzaNwID7HzGQmHFbqEFcLtJGQ96JKztDefkzcK57UfZN5tmqdWgco1clebKFl2J-bC2dWTgdoJqPPZTzLzFfzNeK2tZ6h5KsLwb899WI3lFvBeFB79PBjXnGKdvlyhD3QN2jMwqrHJ0BOEqkvKZ771Vw3KKTRcGKjcsIVktcfK75GFihyV-33L67EcmCUkrWaBPfs-c0-ZPxNuh-6kqnn5_Ssjlj5Cw5GwF2zsGgHVG",
    "https://lh3.googleusercontent.com/aida-public/AB6AXuBbG8ANh7niqXk-d35SY37chOEYRMc-MkUuoPFbLQTO4yoAi4dyITeTgpvp0B-cqaFoM5hp1q4abnzWS4GLSw4eHvpiudV2hEDWMABomU2N3WgSM-sI8qYdAy5fXecPDwrpnlVh3h4cz5IVZi0OvmQe2K1TQpO7Frhdlq4PeFK0X6qlr6mvw9hRI-JShmj25GhyR98XyyjsHlwuV-oqfQkfNATa87UiXW9kkG5QIUZMGr2NKkPsEg8cKrTUH93kIl_yjjG2R4noz73h",
  ];

  final List<Map<String, String>> featured = [
    {
      "title": "Running Shoes",
      "img": "https://lh3.googleusercontent.com/aida-public/AB6AXuDIKf1N2DKiqvwECraEYWv5D24JkygksmINEu_xAMxf6jfGuNilrJP10hdg2_HmKoV13_oAAzI-qnBU7AWtyQPivv6isU2cu3xLs6-YIZYhhii2wYWLksyCwMhjSdEfGXiYUwVCxcjRFT6E0djn1LF33Zd3-o2EWonrHiAK8qBt1KA3DdCWSKv7okIjen1vlt4QvjvIt2rSxmqexw2kLScNM2PU4u4KZVG846xWRFsepmGGH1VnNhey0e-AyoSoFEK5BydIdzTR1hBS"
    },
    {
      "title": "Basketball Shoes",
      "img": "https://lh3.googleusercontent.com/aida-public/AB6AXuAWWdvqVFZfsiEORBv69-iUOG2rVvv7mRW-2NHSt72Awk2BeeCwR3X5zpZbem2JgwmKoKNum_Xj_qRtItE5I3UtX8dkcO_2MVFumcLZIKNBgQgkJfoSryyB_9fKhZi7zKMOkQftTotn0Z1M_q5Rd7A16XJsb1TI9Uk8kArcuc-a7mzUzZ80uKTXaqEKnZ1I0xGmKSiAjuHOCtxrsaTS_OIjyrwxjhFNy3xr375asUjrj1x_JNQu1Jhhi0SuYacD67Q8JEoeKxV1YmEn"
    },
    {
      "title": "Casual Shoes",
      "img": "https://lh3.googleusercontent.com/aida-public/AB6AXuD37XXNDMtA5wKdS-bGNBvY_9hF7pKNyC_dd-Zbh8wY5nWsmPNC8Uta1WjDD--VNzPoFxJeKypPy3CBfdMIhQ6kRCzV7sMOhPo7a7S672j0aAXdI4uz5EU4RrIFMIC9uLL56UlgJsrlUaSAfKJuW764xS8taF2f1KLujdxAxZSZZ4n9-Tl933NTtTv8J2q5nwHZovIuEF3rPxS4YtzTQkN6d95PiSPk27JgAO4wnPbpczLU2GKE_6m9IwHqmdaDBf-gMcvePIKDHtgZ"
    },
    {
      "title": "Training Shoes",
      "img": "https://lh3.googleusercontent.com/aida-public/AB6AXuDqwRMIz9aChKp3neOwhTDaYB9byCUtIwO2H87UHp-a3-PEXBSXGZWN4dS0rH2j3At_74oCyyXgAn82LxnsTFWIbQVNkPbTBEEWNpsBXy0wy3t4ekYmbukDU-WkPeQ9BdMiGOeTR7ySC04Jj69Uh6qTbY_W1u0RnhE4mEM2Ny9WlAqo2qHa9ShUKK5JJLgq5xPi0dR8oJQpqBvyZzwn9dwMIALFHAoTWEOq8f3L3-8SJzJv3TtI7pcXr2mGiSX7UBF0ifSedDaCXCTO"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[50],
        title: const Text("Shop",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.shopping_bag_outlined,
                  color: Colors.black))
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for shoes",
                prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
                filled: true,
                fillColor: const Color(0xffe7edf4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Horizontal banners
          SizedBox(
            height: 160,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: banners.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(banners[index],
                      width: 200, fit: BoxFit.cover),
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text("Categories",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),

          // Tabs (Men, Women, Kids, Sports)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text("Men", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Women", style: TextStyle(color: Colors.grey)),
                Text("Kids", style: TextStyle(color: Colors.grey)),
                Text("Sports", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text("Featured",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),

          // Featured Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8),
              itemCount: featured.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(featured[index]["img"]!,
                          height: 120, width: double.infinity, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    Text(featured[index]["title"]!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home", backgroundColor: Colors.black),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Categories"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: "Wishlist"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
