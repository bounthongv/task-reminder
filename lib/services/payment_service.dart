import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class PaymentService {
  // NOTE: This link looks like a Stripe Express Dashboard. 
  // Replace with a public 'https://buy.stripe.com/...' link for customers.
  static const String _stripeCheckoutUrl = 'https://connect.stripe.com/app/express#acct_1RXkZSR619KfUE9U/overview';

  Future<void> openStripeCheckout(BuildContext context) async {
    final Uri url = Uri.parse(_stripeCheckoutUrl); 
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    
          if (context.mounted) {
    
            ScaffoldMessenger.of(context).showSnackBar(
    
              const SnackBar(content: Text('Could not launch payment page')),
    
            );
    
          }
    
        }
    
      }
    
    }
    
    
