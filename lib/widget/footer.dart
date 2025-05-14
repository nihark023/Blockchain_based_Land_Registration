import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:land_registration/constant/constants.dart';
import 'package:land_registration/screens/registerUser.dart';
import 'package:universal_html/html.dart' as html;
import '../constant/utils.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({Key? key}) : super(key: key);

  static final appContainer = kIsWeb
      ? html.window.document.querySelectorAll('flt-glass-pane')[0]
      : null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensures the footer takes up full width
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align footer content to the left
        children: <Widget>[
          // Logo or Title aligned to the top-left
          Row(
            mainAxisAlignment:
                MainAxisAlignment.start, // Align text to the left
            children: [
              const Text(
                'Bhoo-Parman',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),

          // Navigation Links aligned to the center
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center the navigation links
            children: <Widget>[
              _buildFooterLink(context, 'Home', '/'),
              _buildFooterLink(context, 'User', '/login', 'UserLogin'),
              _buildFooterLink(
                  context, 'Land Inspector', '/login', 'LandInspector'),
              _buildFooterLink(context, 'Contract Owner', '/login', 'owner'),
              _buildFooterLink(context, 'About', '/about'),
            ],
          ),

          // Spacer between navigation links and copyright
          const SizedBox(height: 20),

          // Copyright Text centered at the bottom
          const Center(
            child: Text(
              '© 2024 Bhoo-Parman. All rights reserved.',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xff28313b),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(BuildContext context, String title, String route,
      [String? argument]) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 12.0), // Spacing between links
      child: GestureDetector(
        onTap: () {
          if (argument != null) {
            Navigator.of(context).pushNamed(route, arguments: argument);
          } else {
            Navigator.of(context).pushNamed(route);
          }
        },
        child: MouseRegion(
          onHover: (PointerHoverEvent evt) {
            appContainer?.style.cursor = 'pointer';
          },
          onExit: (PointerExitEvent evt) {
            appContainer?.style.cursor = 'default';
          },
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xff28313b),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              letterSpacing: 1.627907,
            ),
          ),
        ),
      ),
    );
  }
}
