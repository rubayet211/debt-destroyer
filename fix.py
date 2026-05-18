import sys

def fix_file(path, marker):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    idx = content.find(marker)
    if idx != -1:
        content = content[:idx]
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)

fix_file('lib/core/widgets/app_widgets.dart', '?.copyWith(')
fix_file('lib/features/dashboard/presentation/home_dashboard_screen.dart', 'inal String label;')

marker_str = "String _minimumRuleLabel(MinimumPaymentRule value) {"
with open('lib/features/debts/presentation/debts_screens.dart', 'r', encoding='utf-8') as f:
    content = f.read()
idx = content.find(marker_str)
if idx != -1:
    end_idx = content.find('}', idx)
    end_idx = content.find('}', end_idx + 1)
    content = content[:end_idx + 1] + '\n'
    with open('lib/features/debts/presentation/debts_screens.dart', 'w', encoding='utf-8') as f:
        f.write(content)
