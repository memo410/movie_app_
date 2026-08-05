import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/menu_data.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'order_success_screen.dart';

const List<String> _stepTitles = ['Delivery', 'Payment', 'Review'];

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final PageController _pages = PageController();
  final TextEditingController _note = TextEditingController();
  int _step = 0;
  int _tipIndex = 1;
  bool _placing = false;

  static const List<double> _tips = [0, 15, 25, 40];

  @override
  void initState() {
    super.initState();
    _note.text = AppScope.read(context).deliveryNote;
  }

  @override
  void dispose() {
    _pages.dispose();
    _note.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    if (step < 0 || step >= _stepTitles.length) return;
    setState(() => _step = step);
    _pages.animateToPage(
      step,
      duration: Motion.page,
      curve: Motion.emphasized,
    );
  }

  Future<void> _place() async {
    setState(() => _placing = true);
    AppScope.read(context).setDeliveryNote(_note.text.trim());
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final order = AppScope.read(context).placeOrder();
    HapticFeedback.heavyImpact();
    setState(() => _placing = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
    );
  }

  Future<bool> _confirmLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.exit_to_app_rounded),
        title: const Text('Leave checkout?'),
        content: const Text(
          'Your cart is kept, but the delivery details you entered here '
          'will not be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay here'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final tip = _tips[_tipIndex];
    final grandTotal = state.total + tip;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_step > 0) {
          _goTo(_step - 1);
          return;
        }
        final leave = await _confirmLeave();
        if (!leave || !context.mounted) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: _step == 0 ? 'Back to cart' : 'Previous step',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text('Checkout · ${_stepTitles[_step]}'),
        ),
        body: Column(
          children: [
            _StepBar(step: _step, onTap: _goTo),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _DeliveryStep(state: state, note: _note),
                  _PaymentStep(
                    state: state,
                    tips: _tips,
                    tipIndex: _tipIndex,
                    onTip: (value) => setState(() => _tipIndex = value),
                  ),
                  _ReviewStep(state: state, tip: tip, total: grandTotal),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _CheckoutBar(
          step: _step,
          total: grandTotal,
          placing: _placing,
          onBack: () => _goTo(_step - 1),
          onNext: () => _step == _stepTitles.length - 1 ? _place() : _goTo(_step + 1),
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.step, required this.onTap});

  final int step;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.md, 0, Gap.md, Gap.md),
      child: Row(
        children: [
          for (var i = 0; i < _stepTitles.length; i++) ...[
            if (i > 0)
              Expanded(
                child: AnimatedContainer(
                  duration: Motion.base,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: Gap.xs),
                  color: i <= step ? colors.primary : colors.outlineVariant,
                ),
              ),
            Semantics(
              button: i < step,
              onTap: i < step ? () => onTap(i) : null,
              label: 'Step ${i + 1} of ${_stepTitles.length}, ${_stepTitles[i]}',
              child: ExcludeSemantics(
                child: GestureDetector(
                  onTap: i < step ? () => onTap(i) : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: Motion.base,
                        curve: Motion.enter,
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= step
                              ? colors.primary
                              : colors.surfaceContainerHigh,
                          border: Border.all(
                            color: i <= step ? colors.primary : colors.outline,
                          ),
                        ),
                        child: i < step
                            ? Icon(
                                Icons.check_rounded,
                                size: IconSize.sm,
                                color: colors.onPrimary,
                              )
                            : Center(
                                child: Text(
                                  '${i + 1}',
                                  style: context.text.labelMedium?.copyWith(
                                    color: i == step
                                        ? colors.onPrimary
                                        : colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _stepTitles[i],
                        style: context.text.labelSmall?.copyWith(
                          color: i <= step
                              ? colors.onSurface
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliveryStep extends StatelessWidget {
  const _DeliveryStep({required this.state, required this.note});

  final AppState state;
  final TextEditingController note;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.md, 0, Gap.md, Gap.xxl),
      children: [
        Text('Deliver to', style: context.text.headlineSmall),
        Gap.h12,
        for (final address in MenuData.addresses) ...[
          _SelectableTile(
            icon: address.icon,
            title: address.label,
            subtitle: address.line,
            selected: state.address.id == address.id,
            onTap: () => state.setAddress(address),
          ),
          Gap.h8,
        ],
        Gap.h8,
        OutlinedButton.icon(
          onPressed: () => showAppSnack(
            'Adding new addresses is not available in this build.',
            icon: Icons.info_outline_rounded,
          ),
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Add a new address'),
        ),
        Gap.h24,
        Text('Delivery window', style: context.text.headlineSmall),
        Gap.h12,
        const _DeliveryWindow(),
        Gap.h24,
        Text('Instructions for the rider', style: context.text.headlineSmall),
        Gap.h12,
        TextField(
          controller: note,
          maxLines: 3,
          maxLength: 140,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Gate code, floor, landmark…',
            alignLabelWithHint: true,
          ),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: state.leaveAtDoor,
          onChanged: state.setLeaveAtDoor,
          title: Text('Leave at the door', style: context.text.titleMedium),
          subtitle: Text(
            'The rider will not ring the bell.',
            style: context.text.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _DeliveryWindow extends StatefulWidget {
  const _DeliveryWindow();

  @override
  State<_DeliveryWindow> createState() => _DeliveryWindowState();
}

class _DeliveryWindowState extends State<_DeliveryWindow> {
  int _selected = 0;

  static const List<({String label, String detail, IconData icon})> _options = [
    (
      label: 'As soon as possible',
      detail: '35-45 minutes',
      icon: Icons.bolt_rounded,
    ),
    (
      label: 'Later tonight',
      detail: 'Pick a slot between 19:00 and 23:00',
      icon: Icons.schedule_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _options.length; i++) ...[
          _SelectableTile(
            icon: _options[i].icon,
            title: _options[i].label,
            subtitle: _options[i].detail,
            selected: _selected == i,
            onTap: () => setState(() => _selected = i),
          ),
          if (i < _options.length - 1) Gap.h8,
        ],
      ],
    );
  }
}

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({
    required this.state,
    required this.tips,
    required this.tipIndex,
    required this.onTip,
  });

  final AppState state;
  final List<double> tips;
  final int tipIndex;
  final ValueChanged<int> onTip;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.md, 0, Gap.md, Gap.xxl),
      children: [
        Text('Pay with', style: context.text.headlineSmall),
        Gap.h12,
        for (final method in MenuData.paymentMethods) ...[
          _SelectableTile(
            icon: method.icon,
            title: method.label,
            subtitle: method.detail,
            selected: state.payment.id == method.id,
            onTap: () => state.setPayment(method),
          ),
          Gap.h8,
        ],
        Gap.h24,
        Text('Tip your rider', style: context.text.headlineSmall),
        Gap.h4,
        Text(
          'Riders keep 100% of tips.',
          style: context.text.bodyMedium,
        ),
        Gap.h12,
        Row(
          children: [
            for (var i = 0; i < tips.length; i++) ...[
              Expanded(
                child: _TipChip(
                  amount: tips[i],
                  selected: tipIndex == i,
                  onTap: () => onTip(i),
                ),
              ),
              if (i < tips.length - 1) Gap.w8,
            ],
          ],
        ),
        Gap.h24,
        SoftCard(
          color: context.colors.secondaryContainer,
          bordered: false,
          child: Row(
            children: [
              Icon(
                Icons.verified_user_rounded,
                color: context.colors.onSecondaryContainer,
              ),
              Gap.w12,
              Expanded(
                child: Text(
                  'This is a demo build — no real payment is taken and no card '
                  'details are stored.',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TipChip extends StatelessWidget {
  const _TipChip({
    required this.amount,
    required this.selected,
    required this.onTap,
  });

  final double amount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: selected,
      onTap: onTap,
      label: amount == 0 ? 'No tip' : 'Tip ${money(amount)}',
      child: ExcludeSemantics(
        child: PressScale(
          onTap: onTap,
          scale: 0.94,
          child: AnimatedContainer(
            duration: Motion.fast,
            height: kMinTouchTarget,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? colors.primary : colors.surfaceContainerLowest,
              borderRadius: Radii.sm,
              border: Border.all(
                color: selected ? colors.primary : colors.outline,
              ),
            ),
            child: Text(
              amount == 0 ? 'None' : '${amount.round()}',
              style: context.text.labelLarge?.copyWith(
                color: selected ? colors.onPrimary : colors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.state,
    required this.tip,
    required this.total,
  });

  final AppState state;
  final double tip;
  final double total;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.md, 0, Gap.md, Gap.xxl),
      children: [
        Text('Your order', style: context.text.headlineSmall),
        Gap.h12,
        SoftCard(
          child: Column(
            children: [
              for (var i = 0; i < state.lines.length; i++) ...[
                if (i > 0) ...[Gap.h12, const HairLine(), Gap.h12],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 26,
                      width: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        borderRadius: Radii.xs,
                      ),
                      child: Text(
                        '${state.lines[i].quantity}',
                        style: context.text.labelSmall?.copyWith(
                          color: context.colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.lines[i].dish.name,
                            style: context.text.titleSmall,
                          ),
                          if (state.lines[i].optionsSummary.isNotEmpty)
                            Text(
                              state.lines[i].optionsSummary,
                              style: context.text.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    Text(
                      money(state.lines[i].lineTotal),
                      style: context.text.titleSmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Gap.h24,
        Text('Delivering to', style: context.text.headlineSmall),
        Gap.h12,
        _SelectableTile(
          icon: state.address.icon,
          title: state.address.label,
          subtitle: state.address.line,
          selected: true,
          onTap: () {},
        ),
        Gap.h8,
        _SelectableTile(
          icon: state.payment.icon,
          title: state.payment.label,
          subtitle: state.payment.detail,
          selected: true,
          onTap: () {},
        ),
        if (state.deliveryNote.isNotEmpty || state.leaveAtDoor) ...[
          Gap.h16,
          SoftCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.sticky_note_2_outlined),
                Gap.w12,
                Expanded(
                  child: Text(
                    [
                      if (state.leaveAtDoor) 'Leave at the door.',
                      if (state.deliveryNote.isNotEmpty) state.deliveryNote,
                    ].join(' '),
                    style: context.text.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
        Gap.h24,
        SoftCard(
          child: Column(
            children: [
              _Line(label: 'Subtotal', value: money(state.subtotal)),
              Gap.h12,
              _Line(
                label: 'Delivery',
                value: state.deliveryFee == 0
                    ? 'Free'
                    : money(state.deliveryFee),
                color: state.deliveryFee == 0 ? brand.success : null,
              ),
              if (state.discount > 0) ...[
                Gap.h12,
                _Line(
                  label: 'Discount · ${state.appliedPromo!.code}',
                  value: '- ${money(state.discount)}',
                  color: brand.success,
                ),
              ],
              if (tip > 0) ...[
                Gap.h12,
                _Line(label: 'Rider tip', value: money(tip)),
              ],
              Gap.h16,
              const HairLine(),
              Gap.h16,
              Row(
                children: [
                  Expanded(child: Text('Total', style: context.text.titleLarge)),
                  AnimatedMoney(
                    value: total,
                    style: context.text.headlineMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: context.text.titleSmall?.copyWith(
            color: color ?? context.colors.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: selected,
      onTap: onTap,
      label: '$title. $subtitle',
      child: ExcludeSemantics(
        child: PressScale(
          onTap: onTap,
          scale: 0.985,
          child: AnimatedContainer(
            duration: Motion.fast,
            constraints: const BoxConstraints(minHeight: kMinTouchTarget + 12),
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.md,
              vertical: Gap.sm,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? colors.primaryContainer
                  : colors.surfaceContainerLowest,
              borderRadius: Radii.sm,
              border: Border.all(
                color: selected ? colors.primary : colors.outline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.text.titleMedium),
                      Text(
                        subtitle,
                        style: context.text.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.step,
    required this.total,
    required this.placing,
    required this.onBack,
    required this.onNext,
  });

  final int step;
  final double total;
  final bool placing;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLast = step == _stepTitles.length - 1;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
        boxShadow: Shadows.raised(Theme.of(context).brightness),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.md, Gap.sm, Gap.md, Gap.sm),
          child: Row(
            children: [
              if (step > 0) ...[
                SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: placing ? null : onBack,
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                Gap.w12,
              ],
              Expanded(
                child: AppButton(
                  label: isLast ? 'Place order · ${money(total)}' : 'Continue',
                  icon: isLast
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  loading: placing,
                  onPressed: onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
