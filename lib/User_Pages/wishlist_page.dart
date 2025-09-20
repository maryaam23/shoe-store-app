import 'package:flutter/material.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  final List<Map<String, String>> items = const [
    {
      "name": "Nike Air Max 90",
      "price": "\$120",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuC_I--bfuX8YKdPr40ejYniOehTxRMbi_CzyDr7PGfJ8cVeK9pcKsvU9aXQiJaoJA3AHQp190uqtmpaqURN1felyFg1fxNE17SW-TJYik2Z-I3Xaulxt2WaAhtRqizyFP8nBgl1Ngr6jmybSZMconjy8KGaOmNUCq04-zHrJQg8FOWcCh8EXYONV-BhprpnxRF5mLzkfWeelSmIJcXJwLrFnl4LXkEwLc-ol4A2yACARt7x_hM2MWwjIHb7GU3NctTxuZgf9PGr7zQC",
    },
    {
      "name": "Adidas Ultraboost",
      "price": "\$150",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuBaWH-_9hu43yAM3-ViGA6FCCaC8qrrxrSOqqkydkVQA0SQZcKm6pJUrmd_CghK4_EyVkaj07bgJHxV7EzlIQ7v1I_rxmG-FhKFMWMJBzKaOO_59vKrCCqTvMUFWaULEuER01dmH0MjYX3vUFKT3XQ3Ifs2_RShXuk12HC_4ykjaqK_vuRMGQ6KaaAwwwH9TjEkPnlPkhSv5tOWLPYJHdzdAtMkpUtWSJgLzEgc9NsuF5vwSAim0m6MFOVYcRCkgFgKI9b0bFnwzw-u",
    },
    {
      "name": "Puma RS-X",
      "price": "\$110",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuD3dRwxBm2CoSeFlCL_dII1NYHrm9KBT74Qv8gw8OWUzvx4_4xRcEHDBasnTfMOoykIBgrUuIWpLEpiBqi02WOdkgICHaB92WHu6NIHjE_QBnY7-JQCTjw6Di0icGl6Kh1ZdAWqEg_08pFoypNnUYcfK1wU54gcMRKbnIctD_47_hdjMcYfRwY1WK_cGhpTrtbdxy-ibwwPMbnqbeyH_rCm8xnw92L7ADOGbQDyV7ivbJvagtwjQm5U-s-mRIsYHRdXDRS2Plq8oqw8",
    },
    {
      "name": "New Balance 990v5",
      "price": "\$130",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuC6W8VFxHMAoIzKS6_MKTyHzseV95Ld9soTloYWRzgdJJfNR8faL7i1KiPd29EEqas_b8lvSr-DuVLhx_W819ewRGDGPNnYL2A3s4WnNEQcNrfvNW-MC-8Zj_TosqraODrZBs2hXLtDX-dSRV_V7f2d2w2OfMP02hYgTVD3fULv-EGwCxE7w_NmuaAIvc9z2VxXgucgUZM8DvOPmgwMytOb7jvs05wCum6ZgHU2eEn6LJT6Be7sVtsPSQeqRS88t5bQf76yacnF_VPu",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "12 items",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D141C),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFE7EDF4)),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item["image"]!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    item["name"]!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0D141C),
                    ),
                  ),
                  subtitle: Text(
                    item["price"]!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF49709C),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Color(0xFF0D141C)),
                    onPressed: () {
                      // TODO: remove item from wishlist
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
