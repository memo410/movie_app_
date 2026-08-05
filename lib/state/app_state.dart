import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  String _userName = 'Guest';
  String _userEmail = '';
  bool _hasSeenOnboarding = false;

  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  String get greetingName => _userName.split(' ').first;

  void completeOnboarding() {
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  void signIn(String email) {
    _userEmail = email;
    final handle = email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
    _userName = handle
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
    if (_userName.isEmpty) _userName = 'Guest';
    notifyListeners();
  }

  void signOut() {
    _userName = 'Guest';
    _userEmail = '';
    _lines.clear();
    _favouriteIds.clear();
    _orders.clear();
    _appliedPromo = null;
    notifyListeners();
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  final List<CartLine> _lines = [];
  int _lineSeed = 0;

  List<CartLine> get lines => List.unmodifiable(_lines);
  bool get isCartEmpty => _lines.isEmpty;
  int get cartCount => _lines.fold(0, (sum, l) => sum + l.quantity);

  double get subtotal => _lines.fold(0, (sum, l) => sum + l.lineTotal);

  double get deliveryFee =>
      _lines.isEmpty || subtotal >= MenuData.freeDeliveryThreshold
          ? 0
          : MenuData.deliveryFee;

  double get amountToFreeDelivery =>
      (MenuData.freeDeliveryThreshold - subtotal).clamp(0, double.infinity);

  double get discount =>
      _appliedPromo == null ? 0 : subtotal * _appliedPromo!.percentOff / 100;

  double get total => subtotal + deliveryFee - discount;

  int quantityOf(String dishId) => _lines
      .where((l) => l.dish.id == dishId)
      .fold(0, (sum, l) => sum + l.quantity);

  void addToCart(
    Dish dish, {
    int quantity = 1,
    PortionSize? size,
    Set<String> addOnIds = const {},
    String note = '',
  }) {
    final match = _lines.indexWhere((l) =>
        l.dish.id == dish.id &&
        l.size?.id == size?.id &&
        l.note == note &&
        _sameSet(l.addOnIds, addOnIds));

    if (match >= 0) {
      _lines[match].quantity += quantity;
    } else {
      _lines.add(CartLine(
        id: 'line-${_lineSeed++}',
        dish: dish,
        quantity: quantity,
        size: size,
        addOnIds: {...addOnIds},
        note: note,
      ));
    }
    notifyListeners();
  }

  void setLineQuantity(String lineId, int quantity) {
    final index = _lines.indexWhere((l) => l.id == lineId);
    if (index < 0) return;
    if (quantity <= 0) {
      _lines.removeAt(index);
    } else {
      _lines[index].quantity = quantity;
    }
    notifyListeners();
  }

  void incrementLine(String lineId) {
    final line = _lines.firstWhere((l) => l.id == lineId);
    setLineQuantity(lineId, line.quantity + 1);
  }

  void decrementLine(String lineId) {
    final line = _lines.firstWhere((l) => l.id == lineId);
    setLineQuantity(lineId, line.quantity - 1);
  }

  ({CartLine line, int index})? removeLine(String lineId) {
    final index = _lines.indexWhere((l) => l.id == lineId);
    if (index < 0) return null;
    final line = _lines.removeAt(index);
    notifyListeners();
    return (line: line, index: index);
  }

  void restoreLine(CartLine line, int index) {
    _lines.insert(index.clamp(0, _lines.length), line);
    notifyListeners();
  }

  void clearCart() {
    _lines.clear();
    _appliedPromo = null;
    notifyListeners();
  }

  PromoCode? _appliedPromo;
  PromoCode? get appliedPromo => _appliedPromo;

  String? applyPromo(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return 'Enter a promo code first.';
    if (_appliedPromo?.code == code) return '$code is already applied.';

    PromoCode? match;
    for (final promo in MenuData.promoCodes) {
      if (promo.code == code) match = promo;
    }
    if (match == null) {
      return "We don't recognise “$code”. Check the spelling and try again.";
    }
    _appliedPromo = match;
    notifyListeners();
    return null;
  }

  void removePromo() {
    _appliedPromo = null;
    notifyListeners();
  }

  final Set<String> _favouriteIds = {};

  bool isFavourite(String dishId) => _favouriteIds.contains(dishId);
  int get favouriteCount => _favouriteIds.length;

  List<Dish> get favourites =>
      MenuData.dishes.where((d) => _favouriteIds.contains(d.id)).toList();

  bool toggleFavourite(String dishId) {
    final added = _favouriteIds.add(dishId);
    if (!added) _favouriteIds.remove(dishId);
    notifyListeners();
    return added;
  }

  DeliveryAddress _address = MenuData.addresses.first;
  PaymentMethod _payment = MenuData.paymentMethods.first;
  bool _leaveAtDoor = false;
  String _deliveryNote = '';

  DeliveryAddress get address => _address;
  PaymentMethod get payment => _payment;
  bool get leaveAtDoor => _leaveAtDoor;
  String get deliveryNote => _deliveryNote;

  void setAddress(DeliveryAddress value) {
    _address = value;
    notifyListeners();
  }

  void setPayment(PaymentMethod value) {
    _payment = value;
    notifyListeners();
  }

  void setLeaveAtDoor(bool value) {
    _leaveAtDoor = value;
    notifyListeners();
  }

  void setDeliveryNote(String value) {
    _deliveryNote = value;
    notifyListeners();
  }

  final List<Order> _orders = [];
  int _orderSeed = 1042;

  List<Order> get orders => List.unmodifiable(_orders.reversed);

  Order? get activeOrder {
    for (var i = _orders.length - 1; i >= 0; i--) {
      if (_orders[i].stage != OrderStage.delivered) return _orders[i];
    }
    return null;
  }

  Order placeOrder() {
    final order = Order(
      id: 'SV-${_orderSeed++}',
      lines: _lines.map((l) => l.copyWith()).toList(),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      placedAt: DateTime.now(),
      address: _address,
      payment: _payment,
    );
    _orders.add(order);
    _lines.clear();
    _appliedPromo = null;
    notifyListeners();
    return order;
  }

  void advanceOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index < 0) return;
    final order = _orders[index];
    final next = order.stage.index + 1;
    if (next >= OrderStage.values.length) return;
    order.stage = OrderStage.values[next];
    notifyListeners();
  }

  void reorder(Order order) {
    for (final line in order.lines) {
      addToCart(
        line.dish,
        quantity: line.quantity,
        size: line.size,
        addOnIds: line.addOnIds,
        note: line.note,
      );
    }
  }

  final List<String> _recentSearches = [];
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  void recordSearch(String term) {
    final clean = term.trim();
    if (clean.length < 2) return;
    _recentSearches.removeWhere((t) => t.toLowerCase() == clean.toLowerCase());
    _recentSearches.insert(0, clean);
    if (_recentSearches.length > 6) _recentSearches.removeLast();
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  List<Dish> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    return MenuData.dishes.where((dish) {
      final category = MenuData.categoryById(dish.categoryId).name.toLowerCase();
      final tags = dish.tags.map((t) => t.label.toLowerCase()).join(' ');
      return dish.name.toLowerCase().contains(q) ||
          dish.tagline.toLowerCase().contains(q) ||
          dish.description.toLowerCase().contains(q) ||
          category.contains(q) ||
          tags.contains(q);
    }).toList();
  }

  static bool _sameSet(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing from the widget tree');
    return scope!.notifier!;
  }

  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing from the widget tree');
    return scope!.notifier!;
  }
}
