import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // 🔹 Banner image list
  final List<String> banners = [
    "https://lh3.googleusercontent.com/aida-public/AB6AXuASOQaNhIqQRp7aCIyGH9cNbUd3jR4lEVUaYBNJFlODaw1FGL33Wa6lsYirIMvtI9vRqiiJScdZQrqxoUkAEvXaAGfju8wopOhkDRHJbQBwxGGMt8XzQk0Km0dSRLn7dqsQ0tZnERItnQLsYnq_yCAfRQP0RY07e2sjeTMixAhHP93SFPcUUcODbBPlWMlF6LCo7LmyiTJKMGneN1vBMS_nFzSDExmxHDFOyFmpAs-mg4-um7RW4XHtRHa2YNHa4A3GbXveieDV2IiA",
    "https://lh3.googleusercontent.com/aida-public/AB6AXuAz8vnBNeiQivC99ImfqYb_xZAVrznYzAwqlAzaNwID7HzGQmHFbqEFcLtJGQ96JKztDefkzcK57UfZN5tmqdWgco1clebKFl2J-bC2dWTgdoJqPPZTzLzFfzNeK2tZ6h5KsLwb899WI3lFvBeFB79PBjXnGKdvlyhD3QN2jMwqrHJ0BOEqkvKZ771Vw3KKTRcGKjcsIVktcfK75GFihyV-33L67EcmCUkrWaBPfs-c0-ZPxNuh-6kqnn5_Ssjlj5Cw5GwF2zsGgHVG",
    "https://lh3.googleusercontent.com/aida-public/AB6AXuBbG8ANh7niqXk-d35SY37chOEYRMc-MkUuoPFbLQTO4yoAi4dyITeTgpvp0B-cqaFoM5hp1q4abnzWS4GLSw4eHvpiudV2hEDWMABomU2N3WgSM-sI8qYdAy5fXecPDwrpnlVh3h4cz5IVZi0OvmQe2K1TQpO7Frhdlq4PeFK0X6qlr6mvw9hRI-JShmj25GhyR98XyyjsHlwuV-oqfQkfNATa87UiXW9kkG5QIUZMGr2NKkPsEg8cKrTUH93kIl_yjjG2R4noz73h",
  ];

  // 🔹 Featured products
  final List<Map<String, String>> featured = [
    {
      "title": "Running Shoes",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuDIKf1N2DKiqvwECraEYWv5D24JkygksmINEu_xAMxf6jfGuNilrJP10hdg2_HmKoV13_oAAzI-qnBU7AWtyQPivv6isU2cu3xLs6-YIZYhhii2wYWLksyCwMhjSdEfGXiYUwVCxcjRFT6E0djn1LF33Zd3-o2EWonrHiAK8qBt1KA3DdCWSKv7okIjen1vlt4QvjvIt2rSxmqexw2kLScNM2PU4u4KZVG846xWRFsepmGGH1VnNhey0e-AyoSoFEK5BydIdzTR1hBS",
    },
    {
      "title": "Basketball Shoes",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuAWWdvqVFZfsiEORBv69-iUOG2rVvv7mRW-2NHSt72Awk2BeeCwR3X5zpZbem2JgwmKoKNum_Xj_qRtItE5I3UtX8dkcO_2MVFumcLZIKNBgQgkJfoSryyB_9fKhZi7zKMOkQftTotn0Z1M_q5Rd7A16XJsb1TI9Uk8kArcuc-a7mzUzZ80uKTXaqEKnZ1I0xGmKSiAjuHOCtxrsaTS_OIjyrwxjhFNy3xr375asUjrj1x_JNQu1Jhhi0SuYacD67Q8JEoeKxV1YmEn",
    },
    {
      "title": "Casual Shoes",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuD37XXNDMtA5wKdS-bGNBvY_9hF7pKNyC_dd-Zbh8wY5nWsmPNC8Uta1WjDD--VNzPoFxJeKypPy3CBfdMIhQ6kRCzV7sMOhPo7a7S672j0aAXdI4uz5EU4RrIFMIC9uLL56UlgJsrlUaSAfKJuW764xS8taF2f1KLujdxAxZSZZ4n9-Tl933NTtTv8J2q5nwHZovIuEF3rPxS4YtzTQkN6d95PiSPk27JgAO4wnPbpczLU2GKE_6m9IwHqmdaDBf-gMcvePIKDHtgZ",
    },
    {
      "title": "Training Shoes",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuDqwRMIz9aChKp3neOwhTDaYB9byCUtIwO2H87UHp-a3-PEXBSXGZWN4dS0rH2j3At_74oCyyXgAn82LxnsTFWIbQVNkPbTBEEWNpsBXy0wy3t4ekYmbukDU-WkPeQ9BdMiGOeTR7ySC04Jj69Uh6qTbY_W1u0RnhE4mEM2Ny9WlAqo2qHa9ShUKK5JJLgq5xPi0dR8oJQpqBvyZzwn9dwMIALFHAoTWEOq8f3L3-8SJzJv3TtI7pcXr2mGiSX7UBF0ifSedDaCXCTO",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 🔹 Screen size
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    double logoSize = w * 0.15;

    return GestureDetector(
      onTap: () {
        // 🔹 dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // ✅ avoids overlap with keyboard
        backgroundColor: Colors.grey[50],

        // 🔹 AppBar
        appBar: AppBar(
  elevation: 0,
  backgroundColor: Colors.grey[50],
  centerTitle: true,
  title: Row(
    mainAxisSize: MainAxisSize.min, // keep them centered together
    children: [
      Image.asset(
        "assets/logoImage.png",
        width: logoSize,
        height: logoSize,
      ),
      const SizedBox(width: 8), // space between logo and text
      Text(
        "Sport Brands",
        style: TextStyle(
          fontSize: w * 0.05,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),


          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.shopping_bag_outlined,
                size: w * 0.07,
                color: Colors.black,
              ),
            ),
          ],
        ),

        // 🔹 Body
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Search bar (smaller height)
                Padding(
                  padding: EdgeInsets.all(w * 0.03),
                  child: SizedBox(
                    height: h * 0.075, // ✅ reduced height
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: h * 0.01, // ✅ shrink inside padding
                        ),
                        hintText: "Search for shoes",
                        hintStyle: TextStyle(fontSize: w * 0.04),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.blueGrey,
                          size: w * 0.06,
                        ),
                        filled: true,
                        fillColor: const Color(0xffe7edf4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(w * 0.03),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // 🔹 Horizontal banners
                SizedBox(
                  height: h * 0.2,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                    scrollDirection: Axis.horizontal,
                    itemCount: banners.length,
                    separatorBuilder: (_, __) => SizedBox(width: w * 0.03),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(w * 0.03),
                        child: Image.network(
                          banners[index],
                          width: w * 0.6,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),

                // 🔹 Categories section title
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04,
                    vertical: h * 0.015,
                  ),
                  child: Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: w * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                // 🔹 Category tabs
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Men",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: w * 0.04)),
                      Text("Women",
                          style: TextStyle(
                              color: Colors.grey, fontSize: w * 0.04)),
                      Text("Kids",
                          style: TextStyle(
                              color: Colors.grey, fontSize: w * 0.04)),
                      Text("Sports",
                          style: TextStyle(
                              color: Colors.grey, fontSize: w * 0.04)),
                    ],
                  ),
                ),

                // 🔹 Featured section title
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04,
                    vertical: h * 0.015,
                  ),
                  child: Text(
                    "Featured",
                    style: TextStyle(
                      fontSize: w * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                // 🔹 Featured Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: h * 0.015,
                    crossAxisSpacing: w * 0.03,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: featured.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(w * 0.03),
                          child: Image.network(
                            featured[index]["img"]!,
                            height: h * 0.15,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: h * 0.01),
                        Text(
                          featured[index]["title"]!,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: w * 0.04,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // 🔹 Bottom Navigation
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedFontSize: w * 0.035,
          unselectedFontSize: w * 0.032,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: "Categories",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: "Wishlist",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
