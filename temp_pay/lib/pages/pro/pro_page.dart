import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ProPage extends StatefulWidget {
  const ProPage({super.key});

  @override
  State<ProPage> createState() => _ProPageState();
}

class _ProPageState extends State<ProPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      setState(() {
        _isAvailable = false;
      });
      return;
    }

    setState(() {
      _isAvailable = true;
    });

    const Set<String> _kIds = <String>{
      'com.your.app.subscription.yearly',
      'com.your.app.subscription.weekly',
    };

    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error.
    }

    setState(() {
      _products = response.productDetails;
    });
  }

  Future<void> _buyProduct(ProductDetails product) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      // Handle the error.
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('高效手机管理工具'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('恢复', style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 顶部图片区域
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/images/pro_banner.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // 功能列表
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildFeatureItem(
                          icon: Icons.people,
                          title: '定制专属联系人组件',
                          subtitle: '桌面组件可一键联系朋友',
                        ),
                        const SizedBox(height: 20),
                        _buildFeatureItem(
                          icon: Icons.photo_library,
                          title: '智能相册管理',
                          subtitle: '清理相册节省存储空间',
                        ),
                        const SizedBox(height: 20),
                        _buildFeatureItem(
                          icon: Icons.security,
                          title: '安全应用管理',
                          subtitle: '应用上锁保护手机隐私',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 底部订阅区域
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // 年度订阅选项
                _buildSubscriptionOption(
                  isSelected: true,
                  product: _products.isNotEmpty ? _products[0] : null,
                  description: '订阅试用3天，然后¥288.00/年',
                ),
                const SizedBox(height: 12),
                // 周订阅选项
                _buildSubscriptionOption(
                  isSelected: false,
                  product: _products.length > 1 ? _products[1] : null,
                  description: '',
                ),
                const SizedBox(height: 20),
                // 订阅按钮
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading || _products.isEmpty
                            ? null
                            : () => _buyProduct(_products[0]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4169E1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              '现在订阅',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 12),
                // 用户协议
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(value: true, onChanged: (value) {}),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '已阅读并同意',
                      style: TextStyle(color: Colors.black54),
                    ),
                    TextButton(onPressed: () {}, child: const Text('《付费会员协议》')),
                  ],
                ),
                // 底部链接
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '用户条款',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 12,
                      color: Colors.black26,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '隐私政策',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF4169E1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF4169E1), size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionOption({
    required bool isSelected,
    required ProductDetails? product,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isSelected
                ? const Color(0xFF4169E1).withOpacity(0.1)
                : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF4169E1) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Radio(
              value: true,
              groupValue: isSelected,
              onChanged: (value) {},
              activeColor: const Color(0xFF4169E1),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product?.rawPrice.toString() ?? '加载中...',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (description.isNotEmpty)
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
