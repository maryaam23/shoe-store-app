import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int selectedTabIndex = 0;

  // Notifications for each tab
  final List<Map<String, String>> promotions = const [
    {
      'title': 'Summer Sale',
      'subtitle': 'Limited time offer! Get 20% off on all running shoes.',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDiMr-33X4QDduGDebcdfwMOIDXgAI6qowG7XYx-840QI5DR1-NlVU5RrHBI7B9-d5ZGCq_5mkT76qC3_KYrLOikOzRww1cF8f4HFJSbvv4xUj4yBCuPR4n6sI4Iz7UVsbw_ZVkzVbgYOXwC9uKufS8auJfV4ph-c0sQ1AICzlp7h4S8TsihoqAspH0vQ_Bp77Dn-XS7MFUZNvPge6ZSUqQCyI1L0hoPf6H3jJC6yV5nYnyfyg5WyIe-0wSbdO_WG13CoEF2hqmCN0f',

    },
    {
      'title': 'Loyalty Program',
      'subtitle': 'Exclusive discount for our loyal customers.',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDiMr-33X4QDduGDebcdfwMOIDXgAI6qowG7XYx-840QI5DR1-NlVU5RrHBI7B9-d5ZGCq_5mkT76qC3_KYrLOikOzRww1cF8f4HFJSbvv4xUj4yBCuPR4n6sI4Iz7UVsbw_ZVkzVbgYOXwC9uKufS8auJfV4ph-c0sQ1AICzlp7h4S8TsihoqAspH0vQ_Bp77Dn-XS7MFUZNvPge6ZSUqQCyI1L0hoPf6H3jJC6yV5nYnyfyg5WyIe-0wSbdO_WG13CoEF2hqmCN0f',

    },
  ];

  final List<Map<String, String>> orderUpdates = const [
    {
      'title': 'Order #1234',
      'subtitle': 'Your order has been shipped.',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDiMr-33X4QDduGDebcdfwMOIDXgAI6qowG7XYx-840QI5DR1-NlVU5RrHBI7B9-d5ZGCq_5mkT76qC3_KYrLOikOzRww1cF8f4HFJSbvv4xUj4yBCuPR4n6sI4Iz7UVsbw_ZVkzVbgYOXwC9uKufS8auJfV4ph-c0sQ1AICzlp7h4S8TsihoqAspH0vQ_Bp77Dn-XS7MFUZNvPge6ZSUqQCyI1L0hoPf6H3jJC6yV5nYnyfyg5WyIe-0wSbdO_WG13CoEF2hqmCN0f',

    },
    {
      'title': 'Order #5678',
      'subtitle': 'Your order is out for delivery.',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDiMr-33X4QDduGDebcdfwMOIDXgAI6qowG7XYx-840QI5DR1-NlVU5RrHBI7B9-d5ZGCq_5mkT76qC3_KYrLOikOzRww1cF8f4HFJSbvv4xUj4yBCuPR4n6sI4Iz7UVsbw_ZVkzVbgYOXwC9uKufS8auJfV4ph-c0sQ1AICzlp7h4S8TsihoqAspH0vQ_Bp77Dn-XS7MFUZNvPge6ZSUqQCyI1L0hoPf6H3jJC6yV5nYnyfyg5WyIe-0wSbdO_WG13CoEF2hqmCN0f',

    },
  ];

  final List<Map<String, String>> recommendations = const [
    {
      'title': 'New Sneakers',
      'subtitle': 'Check out our latest basketball sneakers.',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDiMr-33X4QDduGDebcdfwMOIDXgAI6qowG7XYx-840QI5DR1-NlVU5RrHBI7B9-d5ZGCq_5mkT76qC3_KYrLOikOzRww1cF8f4HFJSbvv4xUj4yBCuPR4n6sI4Iz7UVsbw_ZVkzVbgYOXwC9uKufS8auJfV4ph-c0sQ1AICzlp7h4S8TsihoqAspH0vQ_Bp77Dn-XS7MFUZNvPge6ZSUqQCyI1L0hoPf6H3jJC6yV5nYnyfyg5WyIe-0wSbdO_WG13CoEF2hqmCN0f',

    },
    {
      'title': 'Running Shoes',
      'subtitle': 'Top picks for your running sessions.',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDiMr-33X4QDduGDebcdfwMOIDXgAI6qowG7XYx-840QI5DR1-NlVU5RrHBI7B9-d5ZGCq_5mkT76qC3_KYrLOikOzRww1cF8f4HFJSbvv4xUj4yBCuPR4n6sI4Iz7UVsbw_ZVkzVbgYOXwC9uKufS8auJfV4ph-c0sQ1AICzlp7h4S8TsihoqAspH0vQ_Bp77Dn-XS7MFUZNvPge6ZSUqQCyI1L0hoPf6H3jJC6yV5nYnyfyg5WyIe-0wSbdO_WG13CoEF2hqmCN0f',

    },
  ];

  List<Map<String, String>> get currentNotifications {
    switch (selectedTabIndex) {
      case 0:
        return promotions;
      case 1:
        return orderUpdates;
      case 2:
        return recommendations;
      default:
        return promotions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D141C)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF0D141C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTab('Promotions', 0),
                _buildTab('Order Updates', 1),
                _buildTab('Recommendations', 2),
              ],
            ),
          ),
          const Divider(height: 0, color: Color(0xFFCEDAE8)),
          // Notification List
          Expanded(
            child: ListView.builder(
              itemCount: currentNotifications.length,
              itemBuilder: (context, index) {
                final item = currentNotifications[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['image']!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    item['title']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0D141C),
                    ),
                  ),
                  subtitle: Text(
                    item['subtitle']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF49709C),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
     
    );
  }

  Widget _buildTab(String title, int index) {
    bool isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0D141C) : const Color(0xFF49709C),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0D78F2) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
