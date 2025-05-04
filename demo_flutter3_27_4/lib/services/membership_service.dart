import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MembershipService with ChangeNotifier {
  static const String _isPremiumKey = 'is_premium';
  static const String _expirationDateKey = 'expiration_date';
  static const String _productId = 'premium_monthly';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _isPremium = false;
  DateTime? _expirationDate;
  List<ProductDetails> _products = [];

  bool get isPremium => _isPremium;
  DateTime? get expirationDate => _expirationDate;
  List<ProductDetails> get products => _products;

  MembershipService() {
    _loadMembershipStatus();
    _initializeInAppPurchase();
  }

  Future<void> _loadMembershipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_isPremiumKey) ?? false;
    final expirationTimestamp = prefs.getInt(_expirationDateKey);
    if (expirationTimestamp != null) {
      _expirationDate =
          DateTime.fromMillisecondsSinceEpoch(expirationTimestamp);
    }
    notifyListeners();
  }

  Future<void> _saveMembershipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, _isPremium);
    if (_expirationDate != null) {
      await prefs.setInt(
          _expirationDateKey, _expirationDate!.millisecondsSinceEpoch);
    }
  }

  Future<void> _initializeInAppPurchase() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      debugPrint('Store not available');
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          _inAppPurchase.purchaseStream;
      purchaseUpdated.listen((purchaseDetailsList) {
        _handlePurchases(purchaseDetailsList);
      });
    }

    final Set<String> _kIds = <String>{_productId};
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_kIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
    notifyListeners();
  }

  Future<void> purchaseMembership() async {
    if (_products.isEmpty) {
      debugPrint('No products available');
      return;
    }

    final ProductDetails productDetails = _products.first;
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
      applicationUserName: null,
    );

    try {
      final bool pending = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      debugPrint('Purchase ${pending ? 'pending' : 'not pending'}');
    } catch (e) {
      debugPrint('Purchase error: $e');
    }
  }

  Future<void> _handlePurchases(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('Purchase pending');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('Purchase error: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _isPremium = true;
        _expirationDate = DateTime.now().add(const Duration(days: 30));
        await _saveMembershipStatus();
        notifyListeners();

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        debugPrint('Purchase canceled');
      }
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Restore purchases error: $e');
    }
  }

  Future<void> checkMembershipStatus() async {
    if (_expirationDate != null && DateTime.now().isAfter(_expirationDate!)) {
      _isPremium = false;
      _expirationDate = null;
      await _saveMembershipStatus();
      notifyListeners();
    }
  }
}
