import 'package:flutter/material.dart';

class UsersManagementPage extends StatelessWidget {
  const UsersManagementPage({super.key});

  final List<Map<String, String>> users = const [
    {
      "name": "Ethan Carter",
      "role": "Admin",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuCzDUG9QMStUaCjlZfNGbug4-KWcdMCdTXRxwfL9agbK71e7WLufjliO_aNwOxzM6V7pu9zCVlc7eiVJ0RCDYTWCc512VTho78i332ZGHB5rIZIQdOFdfRg8knVRj-LdDX6z6tKdPN0HiJZeWSBztgxlRRIWqgVtxfN-KpwjoswfljfXQQnDN7Ebg5sH9KJuo7FOIh1uO190Pdg5AlkNwSVjT6pvtl89PtrrVRvzBC4HTQNJujI7u2RGsAQ9yiKc3scjZ727wvWTX-4"
    },
    {
      "name": "Sophia Clark",
      "role": "User",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuC6FoO3fOkNCcCJa48q4y6XtnM2veamFkZTqV1RtUSDj5SZhIaeNoSznudLDdodkoh7-RqOOGLSc7mP9zUG6OztqqC8a5RvKnHalnUm6HhXmv3_AXDTrS22gWsa5PQNYB6PafjcLmAKs3VnzrEFZ9ZyZClZmQs9-tNdjAFZx00XGPIzr3eW02jle9iF3-Xo-jDEEcZ_0qM4SoUNB8jci0Tqnz5iYBhNo7VFot9GfBjyjJ3RUCH_h5lXMHRZ7RFkmVH3B9eRQdmJlQ7q"
    },
    {
      "name": "Liam Walker",
      "role": "User",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuD0OG4rFYyq-vJ_eQuZr2bDluw_wyeiP3Bcrx6sYWk3Yuq20eXuJS0Owf83RiWeB0itUhJpywNKMFqJT4sDA97o4tkMQO0qFw0XLewU7wSyOLVdo9BcLu9xQvp-P38MWvMlmLUnocH_nTvbSRLlEGMTpmTxVzBy8q0hlrPDmhKz-B4Fvm5BhssZKB030HKCJ0GRVXXHJXdOw0qPnLsMaWNKIYH7fC81I4KJuLXe5dbigJRIoM_AYHj5Hk1dE_wPML3rqfb2KRD8N3b4"
    },
    // Add remaining users similarly...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D141C)),
          onPressed: () {},
        ),
        title: const Text(
          'Users',
          style: TextStyle(
            color: Color(0xFF0D141C),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFF49709C)),
                hintText: 'Search users',
                fillColor: const Color(0xFFE7EDF4),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE7EDF4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Role',
                          style: TextStyle(
                              color: Color(0xFF0D141C),
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            size: 20, color: Color(0xFF0D141C)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE7EDF4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Status',
                          style: TextStyle(
                              color: Color(0xFF0D141C),
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            size: 20, color: Color(0xFF0D141C)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  tileColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(user['image']!),
                  ),
                  title: Text(
                    user['name']!,
                    style: const TextStyle(
                        color: Color(0xFF0D141C), fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    user['role']!,
                    style: const TextStyle(
                        color: Color(0xFF49709C), fontWeight: FontWeight.normal),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Color(0xFF0D141C), size: 24),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
