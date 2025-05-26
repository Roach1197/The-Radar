# RareCoinRadar Web + Mobile App

**AI-powered eBay listing generator and profit analyzer**, built with:
- Flutter (Frontend: Web & Android-ready)
- Flask (Backend API + AI listing + Stripe integration)
- Stripe (Subscriptions)
- Tailwind-inspired design with Material 3
- Hosted on a Linux VPS

---

## Features

### Flutter Web UI
- Quick Profit Calculator
- Full Report Generator with AI listing
- Export to PDF, CSV, JSON
- Paywall screen for premium access
- Stripe checkout integration (monthly plan)
- Toggleable ad zones (future)

### Flask Backend
- `/ebay-listing` for eBay profit breakdown
- `/api/ai-listing-gen` for OpenAI description generation
- `/api/send-email` to email reports
- `/api/create-checkout-session` for Stripe subscription
- JSON-safe rendering with inline export support

---

## Nano Paths

| Component                  | Nano Path                                           |
|---------------------------|-----------------------------------------------------|
| Main Flutter entry        | `/opt/rarecoinradar_app/lib/main.dart`             |
| Listing form              | `/opt/rarecoinradar_app/lib/pages/full_report.dart`|
| Quick calculator          | `/opt/rarecoinradar_app/lib/pages/quick_calculator.dart` |
| Settings screen           | `/opt/rarecoinradar_app/lib/pages/settings.dart`   |
| Listing output widget     | `/opt/rarecoinradar_app/lib/widgets/listing_output.dart` |
| API service               | `/opt/rarecoinradar_app/lib/utils/api_service.dart`|
| Theme setup               | `/opt/rarecoinradar_app/lib/utils/theme.dart`      |
| Constants file            | `/opt/rarecoinradar_app/lib/utils/constants.dart`  |
| Paywall screen            | `/opt/rarecoinradar_app/lib/features/paywall/paywall_screen.dart` |
| Stripe backend            | `/opt/ebayapp/stripe_checkout.py`                  |
| Flask backend             | `/opt/ebayapp/ebay_listing.py`                     |

---

## Running Locally

### Flask Server (port 5050)
```bash
cd /opt/ebayapp
source venv/bin/activate
python3 app.py run --host=0.0.0.0 --port=5050
