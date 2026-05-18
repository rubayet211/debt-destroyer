import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    this.title,
    this.titleWidget,
    required this.child,
    this.actions = const [],
    this.floatingActionButton,
    this.hideAppBar = false,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.page),
    this.bottomPadding = AppSpacing.lg,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget child;
  final List<Widget> actions;
  final Widget? floatingActionButton;
  final bool hideAppBar;
  final EdgeInsetsGeometry padding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hideAppBar
          ? null
          : AppBar(
              leading: Navigator.of(context).canPop()
                  ? IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    )
                  : IconButton(
                      tooltip: 'Menu',
                      onPressed: () {},
                      icon: const Icon(Icons.menu_rounded),
                    ),
              title:
                  titleWidget ??
                  (title != null ? Text(title!) : const SizedBox.shrink()),
              actions: actions,
            ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Padding(
          padding: padding,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    this.onTap,
    this.borderColor,
    this.radius = AppRadius.card,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? scheme.surface;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(
        color: borderColor ?? scheme.outlineVariant.withValues(alpha: 0.45),
      ),
    );
    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? scheme.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: shadow && scheme.brightness == Brightness.light
            ? AppShadows.ambient
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );

    if (onTap != null) {
      content = InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

class HeroFinanceCard extends StatelessWidget {
  const HeroFinanceCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.trailing,
    this.children = const [],
  });

  final String label;
  final Widget value;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      color: AppColors.primaryContainer,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w900,
            ),
            child: value,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
          if (children.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            ...children,
          ],
        ],
      ),
    );
  }
}

class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accentColor,
    this.subtitle,
  });

  final String label;
  final Widget value;
  final IconData? icon;
  final Color? accentColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = accentColor ?? scheme.secondary;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      radius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, size: 16, color: accent),
                ),
              if (icon != null) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.titleLarge,
            child: value,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.action,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      title: 'Something went wrong',
      message: message,
      icon: Icons.error_outline_rounded,
      action: onRetry == null
          ? null
          : FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
    );
  }
}

class SensitiveValueText extends ConsumerWidget {
  const SensitiveValueText({
    super.key,
    required this.value,
    required this.hide,
    this.style,
  });

  final String value;
  final bool hide;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axis: Axis.horizontal,
          child: child,
        ),
      ),
      child: Text(
        hide ? '••••••' : value,
        key: ValueKey(hide),
        style: style ?? Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class LoadingPane extends StatelessWidget {
  const LoadingPane({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 36,
              width: 36,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({super.key, required this.label, this.color, this.icon});

  final String label;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final badgeColor = color ?? scheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: badgeColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
