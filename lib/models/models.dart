import 'package:flutter/material.dart';

enum DishTag {
  bestseller('Bestseller', Icons.local_fire_department_rounded),
  chefPick("Chef's pick", Icons.workspace_premium_rounded),
  spicy('Spicy', Icons.whatshot_rounded),
  vegetarian('Vegetarian', Icons.eco_rounded),
  newItem('New', Icons.auto_awesome_rounded);

  const DishTag(this.label, this.icon);
  final String label;
  final IconData icon;
}

class MenuCategory {
  const MenuCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final IconData icon;
}

class PortionSize {
  const PortionSize({
    required this.id,
    required this.label,
    required this.priceDelta,
    this.serves,
  });

  final String id;
  final String label;
  final double priceDelta;
  final String? serves;
}

class AddOn {
  const AddOn({required this.id, required this.label, required this.price});

  final String id;
  final String label;
  final double price;
}

class Dish {
  const Dish({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.basePrice,
    required this.categoryId,
    required this.icon,
    required this.rating,
    required this.reviewCount,
    required this.calories,
    required this.prepMinutes,
    this.imageUrl,
    this.tags = const [],
    this.sizes = const [],
    this.addOns = const [],
    this.discountPercent = 0,
  });

  final String id;
  final String name;
  final String tagline;
  final String description;
  final double basePrice;
  final String categoryId;
  final IconData icon;
  final double rating;
  final int reviewCount;
  final int calories;
  final int prepMinutes;
  final String? imageUrl;
  final List<DishTag> tags;
  final List<PortionSize> sizes;
  final List<AddOn> addOns;
  final int discountPercent;

  bool get isDiscounted => discountPercent > 0;

  double get effectivePrice => basePrice * (1 - discountPercent / 100);

  double priceFor(PortionSize? size, Set<String> addOnIds) {
    var total = effectivePrice + (size?.priceDelta ?? 0);
    for (final addOn in addOns) {
      if (addOnIds.contains(addOn.id)) total += addOn.price;
    }
    return total;
  }
}

class CartLine {
  CartLine({
    required this.id,
    required this.dish,
    required this.quantity,
    this.size,
    this.addOnIds = const {},
    this.note = '',
  });

  final String id;
  final Dish dish;
  int quantity;
  final PortionSize? size;
  final Set<String> addOnIds;
  final String note;

  double get unitPrice => dish.priceFor(size, addOnIds);
  double get lineTotal => unitPrice * quantity;

  String get optionsSummary {
    final parts = <String>[
      if (size != null) size!.label,
      ...dish.addOns.where((a) => addOnIds.contains(a.id)).map((a) => a.label),
    ];
    return parts.join(' · ');
  }

  CartLine copyWith({int? quantity}) => CartLine(
        id: id,
        dish: dish,
        quantity: quantity ?? this.quantity,
        size: size,
        addOnIds: addOnIds,
        note: note,
      );
}

enum OrderStage {
  confirmed(
    'Order confirmed',
    'We received your order',
    Icons.receipt_long_rounded,
  ),
  preparing(
    'In the kitchen',
    'Our chefs are cooking',
    Icons.soup_kitchen_rounded,
  ),
  onTheWay(
    'On the way',
    'Your rider has picked it up',
    Icons.delivery_dining_rounded,
  ),
  delivered('Delivered', 'Enjoy your meal', Icons.check_circle_rounded);

  const OrderStage(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}

class PromoCode {
  const PromoCode({
    required this.code,
    required this.percentOff,
    required this.description,
  });

  final String code;
  final int percentOff;
  final String description;
}

class DeliveryAddress {
  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.line,
    required this.icon,
  });

  final String id;
  final String label;
  final String line;
  final IconData icon;
}

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.label,
    required this.detail,
    required this.icon,
  });

  final String id;
  final String label;
  final String detail;
  final IconData icon;
}

class Order {
  Order({
    required this.id,
    required this.lines,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.placedAt,
    required this.address,
    required this.payment,
    this.stage = OrderStage.confirmed,
  });

  final String id;
  final List<CartLine> lines;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final DateTime placedAt;
  final DeliveryAddress address;
  final PaymentMethod payment;
  OrderStage stage;

  double get total => subtotal + deliveryFee - discount;
  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);
}
