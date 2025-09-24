import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class SplashPage extends StatefulWidget {
	const SplashPage({super.key});

	@override
	State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
	@override
	void initState() {
		super.initState();
		// Defer to next microtask so context/providers are ready
		WidgetsBinding.instance.addPostFrameCallback((_) {
			if (!mounted) return;
			context.read<AuthViewModel>().tryAutoLogin();
		});
	}

	@override
	Widget build(BuildContext context) {
		return const Scaffold(
			body: Center(
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						CircularProgressIndicator(),
						SizedBox(height: 12),
						Text('Checking session...'),
					],
				),
			),
		);
	}
}

