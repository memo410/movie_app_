import 'package:flutter/material.dart';

import '../models/models.dart';

abstract final class MenuData {
  static const String restaurantName = 'Savora';
  static const String restaurantTagline = 'Wood-fired kitchen · Zamalek, Cairo';
  static const double deliveryFee = 25;
  static const double freeDeliveryThreshold = 400;

  static const List<MenuCategory> categories = [
    MenuCategory(id: 'pizza', name: 'Pizza', icon: Icons.local_pizza_rounded),
    MenuCategory(id: 'pasta', name: 'Pasta', icon: Icons.ramen_dining_rounded),
    MenuCategory(id: 'burgers', name: 'Burgers', icon: Icons.lunch_dining_rounded),
    MenuCategory(id: 'grills', name: 'Grills', icon: Icons.outdoor_grill_rounded),
    MenuCategory(id: 'salads', name: 'Salads', icon: Icons.local_florist_rounded),
    MenuCategory(id: 'sides', name: 'Sides', icon: Icons.tapas_rounded),
    MenuCategory(id: 'desserts', name: 'Desserts', icon: Icons.icecream_rounded),
    MenuCategory(id: 'drinks', name: 'Drinks', icon: Icons.local_cafe_rounded),
  ];

  static MenuCategory categoryById(String id) =>
      categories.firstWhere((c) => c.id == id);

  static const List<PortionSize> _pizzaSizes = [
    PortionSize(id: 'sm', label: 'Small', priceDelta: -40, serves: '9" · serves 1'),
    PortionSize(id: 'md', label: 'Medium', priceDelta: 0, serves: '12" · serves 2'),
    PortionSize(id: 'lg', label: 'Large', priceDelta: 65, serves: '16" · serves 3-4'),
  ];

  static const List<AddOn> _pizzaAddOns = [
    AddOn(id: 'cheese', label: 'Extra mozzarella', price: 35),
    AddOn(id: 'mushroom', label: 'Sautéed mushrooms', price: 25),
    AddOn(id: 'olives', label: 'Kalamata olives', price: 20),
    AddOn(id: 'chilli', label: 'Chilli honey drizzle', price: 18),
  ];

  static const List<PortionSize> _plateSizes = [
    PortionSize(id: 'reg', label: 'Regular', priceDelta: 0, serves: 'Serves 1'),
    PortionSize(id: 'sharing', label: 'Sharing', priceDelta: 90, serves: 'Serves 2-3'),
  ];

  static const List<AddOn> _pastaAddOns = [
    AddOn(id: 'parmesan', label: 'Aged parmesan', price: 30),
    AddOn(id: 'chicken', label: 'Grilled chicken', price: 55),
    AddOn(id: 'truffle', label: 'Truffle oil', price: 45),
  ];

  static const List<AddOn> _burgerAddOns = [
    AddOn(id: 'patty', label: 'Double patty', price: 75),
    AddOn(id: 'bacon', label: 'Smoked beef bacon', price: 40),
    AddOn(id: 'cheddar', label: 'Aged cheddar', price: 25),
    AddOn(id: 'jalapeno', label: 'Pickled jalapeños', price: 15),
  ];

  static const List<AddOn> _drinkAddOns = [
    AddOn(id: 'ice', label: 'Extra ice', price: 0),
    AddOn(id: 'shot', label: 'Extra espresso shot', price: 20),
  ];

  static const List<Dish> dishes = [
    Dish(
      id: 'p1',
      name: 'Margherita Verace',
      tagline: 'San Marzano · buffalo mozzarella · basil',
      description:
          'Our signature 72-hour cold-fermented dough, blistered in the wood '
          'oven for 90 seconds. Topped with San Marzano tomatoes, torn buffalo '
          'mozzarella and basil picked the same morning.',
      basePrice: 185,
      categoryId: 'pizza',
      icon: Icons.local_pizza_rounded,
      rating: 4.8,
      reviewCount: 1240,
      calories: 780,
      prepMinutes: 18,
      imageUrl:
          'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.bestseller, DishTag.vegetarian],
      sizes: _pizzaSizes,
      addOns: _pizzaAddOns,
    ),
    Dish(
      id: 'p2',
      name: 'Diavola Piccante',
      tagline: 'Spicy salami · chilli honey · smoked scamorza',
      description:
          'For people who like heat with their sweetness. Spicy Calabrian '
          'salami and smoked scamorza, finished with a chilli honey drizzle '
          'the moment it leaves the oven.',
      basePrice: 225,
      categoryId: 'pizza',
      icon: Icons.local_pizza_rounded,
      rating: 4.7,
      reviewCount: 862,
      calories: 940,
      prepMinutes: 18,
      imageUrl:
          'https://images.unsplash.com/photo-1628840042765-356cda07504e?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.spicy, DishTag.chefPick],
      sizes: _pizzaSizes,
      addOns: _pizzaAddOns,
      discountPercent: 15,
    ),
    Dish(
      id: 'p3',
      name: 'Quattro Funghi',
      tagline: 'Four mushrooms · thyme · truffle cream',
      description:
          'Portobello, oyster, shiitake and button mushrooms over a truffle '
          'cream base, with fresh thyme and a shower of parmesan.',
      basePrice: 210,
      categoryId: 'pizza',
      icon: Icons.local_pizza_rounded,
      rating: 4.6,
      reviewCount: 431,
      calories: 810,
      prepMinutes: 18,
      imageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.vegetarian],
      sizes: _pizzaSizes,
      addOns: _pizzaAddOns,
    ),
    Dish(
      id: 'p4',
      name: 'Frutti di Mare',
      tagline: 'Shrimp · calamari · garlic · lemon zest',
      description:
          'Gulf shrimp and calamari with confit garlic, parsley and lemon '
          'zest on a light tomato base. Arrives with a wedge of lemon.',
      basePrice: 265,
      categoryId: 'pizza',
      icon: Icons.set_meal_rounded,
      rating: 4.5,
      reviewCount: 297,
      calories: 720,
      prepMinutes: 22,
      imageUrl:
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.newItem],
      sizes: _pizzaSizes,
      addOns: _pizzaAddOns,
    ),

    Dish(
      id: 'a1',
      name: 'Carbonara Romana',
      tagline: 'Guanciale · pecorino · black pepper',
      description:
          'No cream, ever. Just guanciale rendered slowly, egg yolk, pecorino '
          'romano and a lot of cracked black pepper, tossed off the heat.',
      basePrice: 195,
      categoryId: 'pasta',
      icon: Icons.ramen_dining_rounded,
      rating: 4.9,
      reviewCount: 1533,
      calories: 690,
      prepMinutes: 15,
      imageUrl:
          'https://images.unsplash.com/photo-1612874742237-6526221588e3?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.bestseller, DishTag.chefPick],
      sizes: _plateSizes,
      addOns: _pastaAddOns,
    ),
    Dish(
      id: 'a2',
      name: "Penne all'Arrabbiata",
      tagline: 'Slow tomato · garlic · dried chilli',
      description:
          'Tomatoes reduced for three hours with garlic and dried chilli. '
          'Simple, sharp and properly spicy. Finished with parsley.',
      basePrice: 155,
      categoryId: 'pasta',
      icon: Icons.ramen_dining_rounded,
      rating: 4.5,
      reviewCount: 604,
      calories: 540,
      prepMinutes: 14,
      imageUrl:
          'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.spicy, DishTag.vegetarian],
      sizes: _plateSizes,
      addOns: _pastaAddOns,
    ),
    Dish(
      id: 'a3',
      name: 'Tagliatelle al Tartufo',
      tagline: 'Fresh egg pasta · black truffle · butter',
      description:
          'Hand-cut egg tagliatelle in nothing but brown butter, parmesan and '
          'shaved black truffle. Our most requested off-menu dish, now on it.',
      basePrice: 285,
      categoryId: 'pasta',
      icon: Icons.dinner_dining_rounded,
      rating: 4.8,
      reviewCount: 388,
      calories: 720,
      prepMinutes: 17,
      imageUrl:
          'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.chefPick, DishTag.vegetarian],
      sizes: _plateSizes,
      addOns: _pastaAddOns,
    ),
    Dish(
      id: 'a4',
      name: 'Lasagna della Casa',
      tagline: 'Beef ragù · béchamel · 8 layers',
      description:
          'Beef ragù cooked down over six hours, layered eight times with '
          'béchamel and parmesan, then baked to order. Worth the wait.',
      basePrice: 215,
      categoryId: 'pasta',
      icon: Icons.bakery_dining_rounded,
      rating: 4.7,
      reviewCount: 721,
      calories: 880,
      prepMinutes: 25,
      imageUrl:
          'https://images.unsplash.com/photo-1574894709920-11b28e7367e3?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.bestseller],
      sizes: _plateSizes,
      addOns: _pastaAddOns,
    ),

    Dish(
      id: 'b1',
      name: 'Savora Smash',
      tagline: 'Double smash patty · house sauce · brioche',
      description:
          'Two 90g patties smashed on a screaming flat-top for maximum crust, '
          'American cheese, pickles and our house sauce in a toasted brioche bun.',
      basePrice: 205,
      categoryId: 'burgers',
      icon: Icons.lunch_dining_rounded,
      rating: 4.9,
      reviewCount: 2104,
      calories: 950,
      prepMinutes: 16,
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.bestseller],
      addOns: _burgerAddOns,
    ),
    Dish(
      id: 'b2',
      name: 'Truffle Mushroom Burger',
      tagline: 'Swiss · caramelised onion · truffle aioli',
      description:
          'A single thick-cut patty with melted swiss, sautéed mushrooms, '
          'onions cooked down for an hour, and truffle aioli.',
      basePrice: 235,
      categoryId: 'burgers',
      icon: Icons.lunch_dining_rounded,
      rating: 4.6,
      reviewCount: 512,
      calories: 890,
      prepMinutes: 18,
      imageUrl:
          'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.chefPick],
      addOns: _burgerAddOns,
    ),
    Dish(
      id: 'b3',
      name: 'Nashville Hot Chicken',
      tagline: 'Buttermilk chicken · cayenne oil · slaw',
      description:
          'Buttermilk-brined chicken thigh, fried and lacquered in cayenne '
          'oil, with cold slaw and pickles to fight back. Genuinely hot.',
      basePrice: 195,
      categoryId: 'burgers',
      icon: Icons.fastfood_rounded,
      rating: 4.7,
      reviewCount: 688,
      calories: 870,
      prepMinutes: 19,
      imageUrl:
          'https://images.unsplash.com/photo-1606755962773-d324e0a13086?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.spicy, DishTag.newItem],
      addOns: _burgerAddOns,
      discountPercent: 20,
    ),

    Dish(
      id: 'g1',
      name: 'Ribeye 300g',
      tagline: 'Dry-aged 28 days · rosemary butter',
      description:
          'Dry-aged ribeye over charcoal, rested and finished with rosemary '
          'butter and flaked salt. Served with grilled greens.',
      basePrice: 495,
      categoryId: 'grills',
      icon: Icons.outdoor_grill_rounded,
      rating: 4.9,
      reviewCount: 419,
      calories: 1120,
      prepMinutes: 28,
      imageUrl:
          'https://images.unsplash.com/photo-1546964124-0cce460f38ef?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.chefPick],
    ),
    Dish(
      id: 'g2',
      name: 'Charcoal Chicken',
      tagline: 'Half chicken · lemon · sumac · garlic sauce',
      description:
          'Half a chicken marinated overnight in lemon, sumac and garlic, '
          'then grilled over charcoal. Comes with toum and warm bread.',
      basePrice: 265,
      categoryId: 'grills',
      icon: Icons.kebab_dining_rounded,
      rating: 4.7,
      reviewCount: 903,
      calories: 840,
      prepMinutes: 25,
      imageUrl:
          'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.bestseller],
      sizes: _plateSizes,
    ),
    Dish(
      id: 'g3',
      name: 'Mixed Grill Platter',
      tagline: 'Kofta · shish tawook · lamb chops',
      description:
          'Kofta, shish tawook and two lamb chops with grilled tomato, '
          'onion and a bowl of tahini. Built for sharing.',
      basePrice: 445,
      categoryId: 'grills',
      icon: Icons.dinner_dining_rounded,
      rating: 4.8,
      reviewCount: 556,
      calories: 1340,
      prepMinutes: 30,
      imageUrl:
          'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.bestseller],
    ),

    Dish(
      id: 's1',
      name: 'Caesar Classico',
      tagline: 'Cos lettuce · anchovy dressing · croutons',
      description:
          'Cos lettuce, proper anchovy dressing made to order, sourdough '
          'croutons and a generous amount of parmesan.',
      basePrice: 135,
      categoryId: 'salads',
      icon: Icons.local_florist_rounded,
      rating: 4.4,
      reviewCount: 388,
      calories: 380,
      prepMinutes: 10,
      imageUrl:
          'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?auto=format&fit=crop&w=800&q=70',
      addOns: [AddOn(id: 'chicken', label: 'Grilled chicken', price: 55)],
    ),
    Dish(
      id: 's2',
      name: 'Burrata & Heirloom',
      tagline: 'Whole burrata · heirloom tomato · basil oil',
      description:
          'A whole burrata on heirloom tomatoes with basil oil, aged balsamic '
          'and sea salt. Three ingredients, all of them excellent.',
      basePrice: 210,
      categoryId: 'salads',
      icon: Icons.eco_rounded,
      rating: 4.8,
      reviewCount: 274,
      calories: 420,
      prepMinutes: 8,
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.vegetarian, DishTag.chefPick],
    ),
    Dish(
      id: 's3',
      name: 'Quinoa & Roast Veg',
      tagline: 'Quinoa · roast pumpkin · pomegranate',
      description:
          'Warm quinoa with roast pumpkin, chickpeas, pomegranate seeds and '
          'a lemon-tahini dressing. Substantial enough to be lunch.',
      basePrice: 155,
      categoryId: 'salads',
      icon: Icons.rice_bowl_rounded,
      rating: 4.5,
      reviewCount: 196,
      calories: 460,
      prepMinutes: 12,
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.vegetarian, DishTag.newItem],
    ),

    Dish(
      id: 'd1',
      name: 'Truffle Parmesan Fries',
      tagline: 'Triple-cooked · truffle oil · parmesan',
      description:
          'Triple-cooked fries tossed in truffle oil, parmesan and parsley. '
          'The single most reordered item on the menu.',
      basePrice: 95,
      categoryId: 'sides',
      icon: Icons.fastfood_rounded,
      rating: 4.8,
      reviewCount: 1876,
      calories: 520,
      prepMinutes: 9,
      imageUrl:
          'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.bestseller, DishTag.vegetarian],
    ),
    Dish(
      id: 'd2',
      name: 'Garlic Focaccia',
      tagline: 'Rosemary · sea salt · olive oil',
      description:
          'Slow-proved focaccia with rosemary, garlic confit and a lot of '
          'good olive oil. Comes out of the oven every 40 minutes.',
      basePrice: 75,
      categoryId: 'sides',
      icon: Icons.bakery_dining_rounded,
      rating: 4.6,
      reviewCount: 512,
      calories: 340,
      prepMinutes: 7,
      imageUrl:
          'https://images.unsplash.com/photo-1585478259715-876acc5be8eb?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.vegetarian],
    ),
    Dish(
      id: 'd3',
      name: 'Buffalo Wings',
      tagline: 'Six wings · buffalo sauce · blue cheese',
      description:
          'Six wings fried twice for crunch, tossed in buffalo sauce, with '
          'a blue cheese dip and celery sticks.',
      basePrice: 125,
      categoryId: 'sides',
      icon: Icons.tapas_rounded,
      rating: 4.5,
      reviewCount: 731,
      calories: 610,
      prepMinutes: 14,
      imageUrl:
          'https://images.unsplash.com/photo-1608039755401-742074f0548d?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.spicy],
    ),

    Dish(
      id: 'e1',
      name: 'Tiramisù',
      tagline: 'Mascarpone · espresso · cocoa',
      description:
          'Savoiardi soaked in single-origin espresso, layered with '
          'mascarpone cream and dusted with bitter cocoa. Made daily at 6am.',
      basePrice: 115,
      categoryId: 'desserts',
      icon: Icons.cake_rounded,
      rating: 4.9,
      reviewCount: 1099,
      calories: 430,
      prepMinutes: 5,
      imageUrl:
          'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.bestseller, DishTag.vegetarian],
    ),
    Dish(
      id: 'e2',
      name: 'Molten Chocolate Fondant',
      tagline: '70% dark · vanilla gelato',
      description:
          'A 70% dark chocolate fondant with a liquid centre, served with '
          'vanilla bean gelato. Baked to order, so give it twelve minutes.',
      basePrice: 135,
      categoryId: 'desserts',
      icon: Icons.icecream_rounded,
      rating: 4.8,
      reviewCount: 654,
      calories: 560,
      prepMinutes: 12,
      imageUrl:
          'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.chefPick, DishTag.vegetarian],
    ),
    Dish(
      id: 'e3',
      name: 'Basque Burnt Cheesecake',
      tagline: 'Caramelised top · soft centre',
      description:
          'Baked hot and fast so the top caramelises while the centre stays '
          'barely set. Served at room temperature, as it should be.',
      basePrice: 125,
      categoryId: 'desserts',
      icon: Icons.cake_rounded,
      rating: 4.7,
      reviewCount: 487,
      calories: 490,
      prepMinutes: 5,
      imageUrl:
          'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.newItem, DishTag.vegetarian],
      discountPercent: 10,
    ),

    Dish(
      id: 'k1',
      name: 'Flat White',
      tagline: 'Double ristretto · micro-foam',
      description:
          'A double ristretto of our house blend with steamed micro-foam. '
          'Roasted in Maadi, ground to order.',
      basePrice: 65,
      categoryId: 'drinks',
      icon: Icons.local_cafe_rounded,
      rating: 4.7,
      reviewCount: 902,
      calories: 120,
      prepMinutes: 4,
      imageUrl:
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.vegetarian],
      addOns: _drinkAddOns,
    ),
    Dish(
      id: 'k2',
      name: 'Mint Lemonade',
      tagline: 'Fresh lemon · mint · crushed ice',
      description:
          'Lemons squeezed to order, blended with mint and crushed ice. '
          'No syrup, no concentrate.',
      basePrice: 55,
      categoryId: 'drinks',
      icon: Icons.local_drink_rounded,
      rating: 4.6,
      reviewCount: 1188,
      calories: 90,
      prepMinutes: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1621263764928-df1444c5e859?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.bestseller, DishTag.vegetarian],
      addOns: _drinkAddOns,
    ),
    Dish(
      id: 'k3',
      name: 'Hibiscus Iced Tea',
      tagline: 'Karkade · orange peel · cinnamon',
      description:
          'Cold-brewed hibiscus with orange peel and a cinnamon stick, '
          'lightly sweetened. Served over ice with a wedge of orange.',
      basePrice: 50,
      categoryId: 'drinks',
      icon: Icons.emoji_food_beverage_rounded,
      rating: 4.5,
      reviewCount: 340,
      calories: 70,
      prepMinutes: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=800&q=70',
      tags: [DishTag.vegetarian, DishTag.newItem],
      addOns: _drinkAddOns,
    ),
  ];

  static Dish dishById(String id) => dishes.firstWhere((d) => d.id == id);

  static List<Dish> byCategory(String categoryId) =>
      dishes.where((d) => d.categoryId == categoryId).toList();

  static List<Dish> get bestsellers =>
      dishes.where((d) => d.tags.contains(DishTag.bestseller)).toList();

  static List<Dish> get chefPicks =>
      dishes.where((d) => d.tags.contains(DishTag.chefPick)).toList();

  static List<Dish> get onOffer => dishes.where((d) => d.isDiscounted).toList();

  static List<Dish> get newArrivals =>
      dishes.where((d) => d.tags.contains(DishTag.newItem)).toList();

  static List<Dish> get trending {
    final sorted = [...dishes]..sort((a, b) {
        final byRating = b.rating.compareTo(a.rating);
        return byRating != 0 ? byRating : b.reviewCount.compareTo(a.reviewCount);
      });
    return sorted.take(8).toList();
  }

  static const List<PromoCode> promoCodes = [
    PromoCode(code: 'SAVORA20', percentOff: 20, description: '20% off your order'),
    PromoCode(code: 'WELCOME10', percentOff: 10, description: '10% off for new diners'),
    PromoCode(code: 'FRIDAY15', percentOff: 15, description: '15% off on weekends'),
  ];

  static const List<DeliveryAddress> addresses = [
    DeliveryAddress(
      id: 'home',
      label: 'Home',
      line: '14 Brazil St, Zamalek, Cairo',
      icon: Icons.home_rounded,
    ),
    DeliveryAddress(
      id: 'work',
      label: 'Work',
      line: 'Nile City Towers, Corniche El Nil',
      icon: Icons.business_center_rounded,
    ),
    DeliveryAddress(
      id: 'other',
      label: "Mum's place",
      line: '7 El Nasr Rd, New Cairo',
      icon: Icons.location_on_rounded,
    ),
  ];

  static const List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'card',
      label: 'Visa ending 4029',
      detail: 'Expires 08/28',
      icon: Icons.credit_card_rounded,
    ),
    PaymentMethod(
      id: 'wallet',
      label: 'Savora Wallet',
      detail: 'Balance EGP 320',
      icon: Icons.account_balance_wallet_rounded,
    ),
    PaymentMethod(
      id: 'cash',
      label: 'Cash on delivery',
      detail: 'Please have exact change',
      icon: Icons.payments_rounded,
    ),
  ];

  static const List<String> popularSearches = [
    'Carbonara',
    'Truffle fries',
    'Spicy',
    'Vegetarian',
    'Under 150',
    'Tiramisù',
  ];
}
