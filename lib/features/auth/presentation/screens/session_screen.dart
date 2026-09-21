import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/vendora_logo.dart';
import '../../models/app_user.dart';
import '../../providers/auth_controller.dart';
import '../widgets/account_content.dart';
import '../widgets/welcome_content.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key, required this.profile});
  final AppUser profile;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  // Après connexion, afficher les vraies informations du compte.
  int _index = 1;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final seller = widget.profile.isSeller;
    return Scaffold(
      appBar: AppBar(
        title: _index == 0
            ? const VendoraLogo()
            : Text(seller ? 'Mon profil vendeur' : 'Mon compte'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.pageMaxWidth,
              ),
              child: _index == 0
                  ? WelcomeContent(seller: seller)
                  : AccountContent(
                      profile: widget.profile,
                      isLoading: auth.busy,
                      error: auth.operationError,
                      onSignOut: () => auth.signOut(),
                    ),
            ),
          ),
        ),
      ),
      // Seules les destinations réellement présentes sont exposées dans ce lot.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() => _index = index);
          if (_scroll.hasClients) _scroll.jumpTo(0);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(
              seller ? Icons.storefront_outlined : Icons.home_outlined,
            ),
            selectedIcon: Icon(seller ? Icons.storefront : Icons.home_rounded),
            label: seller ? 'Boutique' : 'Accueil',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: seller ? 'Profil' : 'Compte',
          ),
        ],
      ),
    );
  }
}
