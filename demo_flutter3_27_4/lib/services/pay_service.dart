import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayService with ChangeNotifier {
  // 单例模式
  static final PayService _instance = PayService._internal();
  factory PayService() => _instance;
  PayService._internal();

  // 产品ID
  static const String _yearlyProductId = 'premium_yearly';
  static const String _weeklyProductId = 'premium_weekly';
  static const String _monthlyProductId = 'premium_monthly';

  // 存储键名
  static const String _isProUserKey = 'is_pro_user';
  static const String _subscriptionTypeKey = 'subscription_type';
  static const String _purchaseDateKey = 'purchase_date';
  static const String _expirationDateKey = 'expiration_date';

  // 应用内购买实例
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // 订阅信息
  bool _isProUser = false;
  String _subscriptionType = '';
  DateTime? _purchaseDate;
  DateTime? _expirationDate;

  // 可用产品
  List<ProductDetails> _products = [];

  // 订阅状态
  bool _isLoading = true;
  String _errorMessage = '';

  // 购买流订阅
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // 获取器
  bool get isProUser => _isProUser;
  String get subscriptionType => _subscriptionType;
  DateTime? get purchaseDate => _purchaseDate;
  DateTime? get expirationDate => _expirationDate;
  List<ProductDetails> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // 通过产品ID获取产品详情
  ProductDetails? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // 初始化服务
  Future<void> initialize() async {
    // 加载保存的订阅状态
    await _loadSubscriptionStatus();

    // 初始化应用内购买
    await _initializeInAppPurchase();

    // 设置加载状态为false
    _isLoading = false;
    notifyListeners();
  }

  // 从SharedPreferences加载订阅状态
  Future<void> _loadSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isProUser = prefs.getBool(_isProUserKey) ?? false;
      _subscriptionType = prefs.getString(_subscriptionTypeKey) ?? '';

      final purchaseTimestamp = prefs.getInt(_purchaseDateKey);
      if (purchaseTimestamp != null) {
        _purchaseDate = DateTime.fromMillisecondsSinceEpoch(purchaseTimestamp);
      }

      final expirationTimestamp = prefs.getInt(_expirationDateKey);
      if (expirationTimestamp != null) {
        _expirationDate =
            DateTime.fromMillisecondsSinceEpoch(expirationTimestamp);

        // 检查订阅是否已过期
        if (DateTime.now().isAfter(_expirationDate!)) {
          _isProUser = false;
          _subscriptionType = '';
          _purchaseDate = null;
          _expirationDate = null;
          await _saveSubscriptionStatus();
        }
      }
    } catch (e) {
      debugPrint('加载订阅状态错误: $e');
    }
  }

  // 保存订阅状态到SharedPreferences
  Future<void> _saveSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isProUserKey, _isProUser);
      await prefs.setString(_subscriptionTypeKey, _subscriptionType);

      if (_purchaseDate != null) {
        await prefs.setInt(
            _purchaseDateKey, _purchaseDate!.millisecondsSinceEpoch);
      } else {
        await prefs.remove(_purchaseDateKey);
      }

      if (_expirationDate != null) {
        await prefs.setInt(
            _expirationDateKey, _expirationDate!.millisecondsSinceEpoch);
      } else {
        await prefs.remove(_expirationDateKey);
      }
    } catch (e) {
      debugPrint('保存订阅状态错误: $e');
    }
  }

  // 初始化应用内购买
  Future<void> _initializeInAppPurchase() async {
    // 检查商店是否可用
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      _errorMessage = '应用商店不可用';
      notifyListeners();
      return;
    }

    // 设置购买监听器
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        _errorMessage = '购买流监听错误: $error';
        notifyListeners();
      },
    );

    // 加载产品详情
    await _loadProductDetails();
  }

  // 加载产品详情
  Future<void> _loadProductDetails() async {
    try {
      final Set<String> productIds = {
        _yearlyProductId,
        _weeklyProductId,
        _monthlyProductId,
      };

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        _errorMessage = '加载产品详情错误: ${response.error}';
        notifyListeners();
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('未找到的产品ID: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      notifyListeners();
    } catch (e) {
      _errorMessage = '查询产品详情错误: $e';
      notifyListeners();
    }
  }

  // 购买产品
  Future<bool> purchaseProduct(String productId) async {
    if (_products.isEmpty) {
      _errorMessage = '无可用产品';
      notifyListeners();
      return false;
    }

    ProductDetails? productDetails;
    try {
      productDetails =
          _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      _errorMessage = '找不到指定产品';
      notifyListeners();
      return false;
    }

    PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
      applicationUserName: null,
    );

    try {
      _isLoading = true;
      notifyListeners();

      if (defaultTargetPlatform == TargetPlatform.android) {
        // 对于Android，需要指定是否为消耗性商品
        if (productId == _yearlyProductId ||
            productId == _weeklyProductId ||
            productId == _monthlyProductId) {
          await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
        } else {
          await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
        }
      } else {
        // 对于iOS
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }

      return true;
    } catch (e) {
      _errorMessage = '购买产品错误: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 购买年度订阅
  Future<bool> purchaseYearlySubscription() async {
    return await purchaseProduct(_yearlyProductId);
  }

  // 购买周度订阅
  Future<bool> purchaseWeeklySubscription() async {
    return await purchaseProduct(_weeklyProductId);
  }

  // 购买月度订阅
  Future<bool> purchaseMonthlySubscription() async {
    return await purchaseProduct(_monthlyProductId);
  }

  // 处理购买更新
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // 购买正在处理中
        debugPrint('购买处理中');
        _isLoading = true;
        notifyListeners();
      } else {
        _isLoading = false;

        if (purchaseDetails.status == PurchaseStatus.error) {
          // 购买出错
          _errorMessage = '购买错误: ${purchaseDetails.error?.message}';
          notifyListeners();
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // 购买成功或已恢复
          await _verifyPurchase(purchaseDetails);

          // 完成购买
          if (purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          // 购买已取消
          debugPrint('购买已取消');
        }

        notifyListeners();
      }
    }
  }

  // 验证购买
  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // TODO: 如需要，添加服务器端验证

    // 目前，我们只信任本地验证
    if (purchaseDetails.productID == _yearlyProductId) {
      _isProUser = true;
      _subscriptionType = 'yearly';
      _purchaseDate = DateTime.now();
      _expirationDate = DateTime.now().add(const Duration(days: 365));
    } else if (purchaseDetails.productID == _weeklyProductId) {
      _isProUser = true;
      _subscriptionType = 'weekly';
      _purchaseDate = DateTime.now();
      _expirationDate = DateTime.now().add(const Duration(days: 7));
    } else if (purchaseDetails.productID == _monthlyProductId) {
      _isProUser = true;
      _subscriptionType = 'monthly';
      _purchaseDate = DateTime.now();
      _expirationDate = DateTime.now().add(const Duration(days: 30));
    }

    await _saveSubscriptionStatus();
  }

  // 恢复购买
  Future<bool> restorePurchases() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _inAppPurchase.restorePurchases();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '恢复购买错误: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 检查订阅是否活跃
  Future<void> checkSubscriptionStatus() async {
    if (_expirationDate != null && DateTime.now().isAfter(_expirationDate!)) {
      _isProUser = false;
      _subscriptionType = '';
      _purchaseDate = null;
      _expirationDate = null;
      await _saveSubscriptionStatus();
      notifyListeners();
    }
  }

  // 释放资源
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
