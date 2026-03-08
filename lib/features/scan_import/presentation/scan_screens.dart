import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/parsers.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/models/import_models.dart';
import '../../../shared/models/payment.dart';
import '../../../shared/models/subscription_state.dart';
import '../../../shared/providers/app_providers.dart';
import '../domain/import_services.dart';

class ScanImportHubScreen extends ConsumerWidget {
  const ScanImportHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(documentsByDebtProvider(null));
    return AppPage(
      title: 'Scan & import',
      child: ListView(
        children: [
          AppCard(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SourceButton(
                  label: 'Camera',
                  icon: Icons.camera_alt_outlined,
                  onTap: () => context.push('/scan/camera'),
                ),
                _SourceButton(
                  label: 'Gallery',
                  icon: Icons.photo_library_outlined,
                  onTap: () => _pickImage(
                    context,
                    ref,
                    ImageSource.gallery,
                    DocumentSourceType.gallery,
                  ),
                ),
                _SourceButton(
                  label: 'Receipt',
                  icon: Icons.receipt_long_outlined,
                  onTap: () => _pickImage(
                    context,
                    ref,
                    ImageSource.gallery,
                    DocumentSourceType.receipt,
                  ),
                ),
                _SourceButton(
                  label: 'PDF statement',
                  icon: Icons.picture_as_pdf_outlined,
                  onTap: () => _pickPdf(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          docs.when(
            data: (items) => items.isEmpty
                ? const EmptyStateView(
                    title: 'No scans yet',
                    message:
                        'Imported documents will appear here with OCR and review status.',
                    icon: Icons.document_scanner_outlined,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Recent imports'),
                      const SizedBox(height: 12),
                      ...items
                          .take(8)
                          .map(
                            (doc) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AppCard(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(doc.mimeType),
                                  subtitle: Text(
                                    '${doc.sourceType.name} • ${doc.parseStatus.name}',
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
            error: (error, _) => AppErrorState(message: error.toString()),
            loading: () => const LoadingPane(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
    DocumentSourceType type,
  ) async {
    final permission = await Permission.photos.request();
    if (!permission.isGranted && source == ImageSource.gallery) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gallery permission denied.')),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 92);
    if (file == null || !context.mounted) {
      return;
    }

    final allowCloud = await _askConsent(context, ref);
    if (!context.mounted) {
      return;
    }

    context.push(
      Uri(
        path: '/scan/processing',
        queryParameters: {'cloud': allowCloud.toString()},
      ).toString(),
      extra: FileReference(
        path: file.path,
        sourceType: type,
        mimeType: 'image/${file.path.split('.').last}',
      ),
    );
  }

  Future<void> _pickPdf(BuildContext context, WidgetRef ref) async {
    final premium =
        ref.read(subscriptionStateProvider).valueOrNull ??
        SubscriptionState.free();
    final hasPdfAccess = ref
        .read(premiumServiceProvider)
        .guard(premium, PremiumFeature.pdfImport);
    if (!hasPdfAccess && context.mounted) {
      context.push('/premium');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final path = result?.files.single.path;
    if (path == null || !context.mounted) {
      return;
    }

    final allowCloud = await _askConsent(context, ref);
    if (!context.mounted) {
      return;
    }

    context.push(
      Uri(
        path: '/scan/processing',
        queryParameters: {'cloud': allowCloud.toString()},
      ).toString(),
      extra: FileReference(
        path: path,
        sourceType: DocumentSourceType.pdf,
        mimeType: 'application/pdf',
      ),
    );
  }

  Future<bool> _askConsent(BuildContext context, WidgetRef ref) async {
    final count = await ref
        .read(documentsRepositoryProvider)
        .countSuccessfulScansInMonth(DateTime.now());
    if (!context.mounted) {
      return false;
    }
    final premium =
        ref.read(subscriptionStateProvider).valueOrNull ??
        SubscriptionState.free();
    if (!premium.isPremium && count >= AppConstants.freeAiScanLimit) {
      if (context.mounted) {
        context.push('/premium');
      }
      return false;
    }

    final choice = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose import privacy level',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'Local OCR runs on-device. Cloud AI parsing only runs if you allow it for this import.',
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Use local OCR + cloud AI'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Use local OCR only'),
              ),
            ],
          ),
        ),
      ),
    );

    final repository = ref.read(preferencesRepositoryProvider);
    final prefs = await repository.loadPreferences();
    await repository.savePreferences(
      prefs.copyWith(aiConsentEnabled: choice ?? false),
    );
    return choice ?? false;
  }
}

class CameraCaptureScreen extends ConsumerStatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  ConsumerState<CameraCaptureScreen> createState() =>
      _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  CameraController? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      setState(() => _error = 'Camera permission denied.');
      return;
    }
    final cameras = ref.read(availableCamerasProvider);
    if (cameras.isEmpty) {
      setState(() => _error = 'No camera available.');
      return;
    }
    final controller = CameraController(cameras.first, ResolutionPreset.high);
    await controller.initialize();
    if (mounted) {
      setState(() => _controller = controller);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppPage(
        title: 'Capture',
        child: AppErrorState(message: _error!),
      );
    }
    if (_controller == null || !_controller!.value.isInitialized) {
      return const AppPage(
        title: 'Capture',
        child: LoadingPane(message: 'Starting camera...'),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Camera capture')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: FilledButton.icon(
                onPressed: _capture,
                icon: const Icon(Icons.camera),
                label: const Text('Capture'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    final file = await _controller!.takePicture();
    if (!mounted) {
      return;
    }
    final allowCloud = await _askConsent(context);
    if (!mounted) {
      return;
    }
    context.push(
      Uri(
        path: '/scan/processing',
        queryParameters: {'cloud': allowCloud.toString()},
      ).toString(),
      extra: FileReference(
        path: file.path,
        sourceType: DocumentSourceType.camera,
        mimeType: 'image/jpeg',
      ),
    );
  }

  Future<bool> _askConsent(BuildContext context) async {
    final choice = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Use cloud AI?'),
        content: const Text(
          'Local OCR always runs first. Allow cloud AI for this capture?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Local only'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Allow once'),
          ),
        ],
      ),
    );
    return choice ?? false;
  }
}

class OCRProcessingScreen extends ConsumerStatefulWidget {
  const OCRProcessingScreen({
    super.key,
    required this.fileReference,
    required this.allowCloud,
  });

  final FileReference fileReference;
  final bool allowCloud;

  @override
  ConsumerState<OCRProcessingScreen> createState() =>
      _OCRProcessingScreenState();
}

class _OCRProcessingScreenState extends ConsumerState<OCRProcessingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_process);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanImportStateProvider);
    return AppPage(
      title: 'Processing',
      child: state.when(
        data: (bundle) {
          if (bundle == null) {
            return const LoadingPane(message: 'Preparing import...');
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/scan/review', extra: bundle);
            }
          });
          return const LoadingPane(message: 'Finalizing import...');
        },
        error: (error, _) => AppErrorState(
          message:
              'OCR failed. Try another document or enter the debt manually.',
          onRetry: _process,
        ),
        loading: () =>
            const LoadingPane(message: 'Running OCR and extraction...'),
      ),
    );
  }

  Future<void> _process() {
    return ref
        .read(scanImportStateProvider.notifier)
        .process(input: widget.fileReference, allowCloud: widget.allowCloud);
  }
}

class ParsedReviewConfirmScreen extends ConsumerStatefulWidget {
  const ParsedReviewConfirmScreen({super.key, required this.bundle});

  final ImportReviewBundle bundle;

  @override
  ConsumerState<ParsedReviewConfirmScreen> createState() =>
      _ParsedReviewConfirmScreenState();
}

class _ParsedReviewConfirmScreenState
    extends ConsumerState<ParsedReviewConfirmScreen> {
  late final TextEditingController _title;
  late final TextEditingController _creditor;
  late final TextEditingController _balance;
  late final TextEditingController _apr;
  late final TextEditingController _minimum;
  late final TextEditingController _paymentAmount;
  late final TextEditingController _notes;
  DebtType _type = DebtType.other;
  ImportActionType _action = ImportActionType.createDebt;
  String? _selectedDebtId;

  @override
  void initState() {
    super.initState();
    final candidate = widget.bundle.candidate;
    _title = TextEditingController(text: candidate.title ?? '');
    _creditor = TextEditingController(text: candidate.creditorName ?? '');
    _balance = TextEditingController(
      text: candidate.currentBalance?.toString() ?? '',
    );
    _apr = TextEditingController(
      text: candidate.aprPercentage?.toString() ?? '',
    );
    _minimum = TextEditingController(
      text: candidate.minimumPayment?.toString() ?? '',
    );
    _paymentAmount = TextEditingController(
      text: candidate.paymentAmount?.toString() ?? '',
    );
    _notes = TextEditingController(text: candidate.notes ?? '');
    _type = candidate.debtType ?? DebtType.other;
  }

  @override
  void dispose() {
    _title.dispose();
    _creditor.dispose();
    _balance.dispose();
    _apr.dispose();
    _minimum.dispose();
    _paymentAmount.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debts = ref.watch(debtsProvider).valueOrNull ?? const <Debt>[];
    return AppPage(
      title: 'Review import',
      child: ListView(
        children: [
          if (widget.bundle.hasAiFailure)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(child: Text(widget.bundle.errorMessage!)),
            ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatters.documentClassification(
                    widget.bundle.classification,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Confidence: ${(widget.bundle.candidate.confidence * 100).toStringAsFixed(0)}%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ImportActionType>(
            initialValue: _action,
            decoration: const InputDecoration(labelText: 'Save as'),
            items: const [
              DropdownMenuItem(
                value: ImportActionType.createDebt,
                child: Text('Create new debt'),
              ),
              DropdownMenuItem(
                value: ImportActionType.addPayment,
                child: Text('Add payment'),
              ),
            ],
            onChanged: (value) => setState(() => _action = value ?? _action),
          ),
          if (_action == ImportActionType.addPayment) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedDebtId,
              decoration: const InputDecoration(
                labelText: 'Map to existing debt',
              ),
              items: debts
                  .map(
                    (debt) => DropdownMenuItem(
                      value: debt.id,
                      child: Text(debt.title),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedDebtId = value),
            ),
          ],
          const SizedBox(height: 12),
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _creditor,
            decoration: const InputDecoration(labelText: 'Creditor'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<DebtType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Debt type'),
            items: DebtType.values
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(Formatters.debtType(type)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _type = value ?? _type),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _balance,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Balance'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _apr,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'APR'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _minimum,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Minimum payment'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _paymentAmount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Payment amount'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text('Raw OCR text'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.bundle.normalizedText.isEmpty
                      ? 'No OCR text.'
                      : widget.bundle.normalizedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(documentsRepositoryProvider)
                        .markDeleted(widget.bundle.document.id);
                    if (context.mounted) {
                      context.go('/scan');
                    }
                  },
                  child: const Text('Discard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => _save(context),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final prefs = ref.read(userPreferencesProvider).valueOrNull;
    final documentsRepository = ref.read(documentsRepositoryProvider);
    await documentsRepository.saveDocument(widget.bundle.document);
    await documentsRepository.saveParsedExtraction(
      ParsedExtraction(
        id: const Uuid().v4(),
        documentId: widget.bundle.document.id,
        classification: widget.bundle.classification,
        confidence: widget.bundle.candidate.confidence,
        payloadJson: jsonEncode({
          'title': _title.text,
          'creditorName': _creditor.text,
          'balance': _balance.text,
          'apr': _apr.text,
          'minimum': _minimum.text,
          'paymentAmount': _paymentAmount.text,
        }),
        ambiguityNotes: widget.bundle.errorMessage ?? '',
        createdAt: DateTime.now(),
      ),
    );

    if (_action == ImportActionType.createDebt) {
      final debtId = const Uuid().v4();
      final debt = Debt(
        id: debtId,
        title: _title.text.trim().isEmpty
            ? 'Imported debt'
            : _title.text.trim(),
        creditorName: _creditor.text.trim().isEmpty
            ? 'Unknown creditor'
            : _creditor.text.trim(),
        type: _type,
        currency:
            widget.bundle.candidate.currency ?? prefs?.currencyCode ?? 'USD',
        originalBalance: Parsers.parseMoney(_balance.text),
        currentBalance: Parsers.parseMoney(_balance.text),
        apr: Parsers.parseMoney(_apr.text),
        minimumPayment: Parsers.parseMoney(_minimum.text),
        dueDate: widget.bundle.candidate.dueDate,
        paymentFrequency: PaymentFrequency.monthly,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: _notes.text.trim(),
        tags: const ['imported'],
        status: DebtStatus.active,
        remindersEnabled: true,
        customPriority: 99,
      );
      await ref.read(debtsRepositoryProvider).saveDebt(debt);
      await documentsRepository.linkDocument(widget.bundle.document.id, debtId);
    } else {
      final debtId = _selectedDebtId;
      if (debtId == null) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Choose a debt to attach this payment to.'),
          ),
        );
        return;
      }
      await ref
          .read(paymentsRepositoryProvider)
          .savePayment(
            Payment(
              id: const Uuid().v4(),
              debtId: debtId,
              amount: Parsers.parseMoney(_paymentAmount.text),
              date: widget.bundle.candidate.paymentDate ?? DateTime.now(),
              method: 'Imported',
              sourceType: PaymentSourceType.scan,
              notes: _notes.text.trim(),
              tags: const ['scan'],
              createdAt: DateTime.now(),
            ),
          );
      await documentsRepository.linkDocument(widget.bundle.document.id, debtId);
    }

    ref.read(scanImportStateProvider.notifier).clear();
    if (context.mounted) {
      context.go('/dashboard');
    }
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: FilledButton.tonalIcon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
