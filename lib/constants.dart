import 'package:flutter/material.dart';

// === API ===
const String kApiBaseUrl = "http://localhost:5050";
const String kGenerateReportEndpoint = "$kApiBaseUrl/ebay-listing";
const String kCalculateEndpoint = "$kApiBaseUrl/ebay-calculate";

// === Colors ===
const Color kAccentColor = Color(0xFF00C2BA);
const Color kCardColor = Color(0xFF1E1E2F);
const Color kBorderColor = Color(0xFF444654);
const Color kProfitGood = Color(0xFF22C55E);
const Color kProfitOkay = Color(0xFFFACC15);
const Color kProfitLow = Color(0xFFF87171);

// === UI ===
const double kPadding = 16.0;
const double kSpacing = 12.0;

// === Animations ===
const Duration kFastAnim = Duration(milliseconds: 250);
const Duration kMediumAnim = Duration(milliseconds: 400);
const Duration kSlowAnim = Duration(milliseconds: 600);

// === Styles ===
const TextStyle kHeadingStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: kAccentColor,
);

const TextStyle kLabelStyle = TextStyle(
  fontSize: 14,
  color: Colors.white70,
);

const TextStyle kValueStyle = TextStyle(
  fontSize: 15,
  color: Colors.white,
  fontWeight: FontWeight.w600,
);

const TextStyle kErrorTextStyle = TextStyle(
  color: Colors.redAccent,
  fontSize: 13,
);
