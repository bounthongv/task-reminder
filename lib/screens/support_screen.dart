import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:task_reminder_flutter/providers/user_provider.dart';
import 'package:task_reminder_flutter/generated/app_localizations.dart';
import 'package:task_reminder_flutter/services/payment_service.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.supportAndPremium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context, userProvider),
            const SizedBox(height: 30),
            Text(
              l10n.chooseYourPlan,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPlanCard(
              context,
              title: l10n.freeTier,
              price: "\$0",
              features: [
                l10n.featureStandardThemes,
                l10n.featureBasicNotifications,
                l10n.featureRecurringLimit
              ],
              isCurrent: userProvider.tier == UserTier.free,
              onTap: null,
            ),
            const SizedBox(height: 15),
            _buildPlanCard(
              context,
              title: l10n.proTier,
              price: "\.99 / month",
              features: [
                l10n.featurePremiumThemes,
                l10n.featureUnlimitedRecurring,
                l10n.featureCustomSounds,
                l10n.featurePrioritySupport
              ],
              isCurrent: userProvider.tier == UserTier.pro,
              highlight: true,
              onTap: () => _showPaymentOptions(context),
            ),
            const SizedBox(height: 30),
            Text(
              l10n.directSupport,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.coffee, color: Colors.brown),
              title: Text(l10n.buyMeACoffee),
              subtitle: Text(l10n.buyMeACoffeeSubtitle),
              trailing: const Icon(Icons.open_in_new),
              onTap: () async {
                 final Uri url = Uri.parse('https://buymeacoffee.com/bounthong/e/497689');
                 if (await canLaunchUrl(url)) {
                   await launchUrl(url, mode: LaunchMode.externalApplication);
                 }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, UserProvider userProvider) {
    final l10n = AppLocalizations.of(context)!;
    String tierName = userProvider.tier.toString().split('.').last.toUpperCase();
    return Card(
      color: Colors.blueAccent.withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.blueAccent)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.account_circle, size: 50, color: Colors.blueAccent),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.yourCurrentStatus, style: const TextStyle(fontSize: 14)),
                Text(tierName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, {
    required String title,
    required String price,
    required List<String> features,
    required bool isCurrent,
    bool highlight = false,
    VoidCallback? onTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: isCurrent ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: highlight ? Colors.amber.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: highlight ? Colors.amber : Colors.grey.shade300,
            width: highlight ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                if (isCurrent)
                  Chip(label: Text(l10n.active), backgroundColor: Colors.green, labelStyle: const TextStyle(color: Colors.white))
                else
                  Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              ],
            ),
            const Divider(),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(child: Text(f)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showPaymentOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.selectPaymentMethod, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: Text(l10n.creditDebitCard),
              subtitle: Text(l10n.internationalPayment),
              onTap: () async {
                Navigator.pop(context); // Close bottom sheet
                await PaymentService().openStripeCheckout(context);
                if (context.mounted) _showStripeConfirmation(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: Text(l10n.localQrCode),
              subtitle: Text(l10n.preferredForLao),
              onTap: () {
                 Navigator.pop(context);
                 _showQRPayment(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStripeConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.completingPayment),
        content: Text(l10n.stripePaymentDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          OutlinedButton(
            onPressed: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'support@taskreminder.com',
                query: encodeQueryParameters(<String, String>{
                  'subject': 'Payment Proof for Task Reminder Pro',
                  'body': 'Please attach your payment screenshot here.\n\nMy User Email: ${Provider.of<UserProvider>(context, listen: false).currentUserEmail ?? "Unknown"}' 
                }),
              );
              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              } else {
                 if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.couldNotOpenEmail)),
                  );
                 }
              }
            },
            child: Text(l10n.sendProofViaEmail),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).updateTier(UserTier.pro);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.paymentConfirmationSent)),
              );
            },
            child: Text(l10n.iHavePaid),
          ),
        ],
      ),
    );
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _showQRPayment(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.scanToPay),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.scanQrDescription),
            const SizedBox(height: 20),
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/qr_code.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_2, size: 100, color: Colors.grey),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              l10n.addQrCodeInstruction,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.upgradeProcessing,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
          ElevatedButton(
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).updateTier(UserTier.pro);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.paymentConfirmationSent)),
              );
            },
            child: Text(l10n.iHavePaid),
          ),
        ],
      ),
    );
  }
}