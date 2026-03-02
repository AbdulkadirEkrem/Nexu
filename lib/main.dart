import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modeller ve Providerlar
import 'models/user_model.dart';
import 'providers/user_provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/request_provider.dart';
import 'providers/team_provider.dart';
import 'providers/theme_provider.dart';

// Servisler
import 'services/notification_service.dart' hide firebaseMessagingBackgroundHandler;
import 'services/firebase_messaging_handler.dart';
import 'core/theme/app_theme.dart';

// Widgets
import 'widgets/main_scaffold.dart';

// Ekranlar
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/team/team_list_screen.dart';
import 'screens/team/user_detail_screen.dart';
import 'screens/team/create_meeting_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/notifications/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();
  
  await Firebase.initializeApp();
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Check if onboarding has been seen
  final prefs = await SharedPreferences.getInstance();
  final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
  final initialLocation = onboardingSeen ? '/login' : '/onboarding';
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('tr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MyApp(initialLocation: initialLocation),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialLocation;
  
  const MyApp({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    // Provider'ları router'dan önce oluşturuyoruz ki refreshListenable'a verebilelim
    final userProvider = UserProvider();
    final calendarProvider = CalendarProvider();
    final requestProvider = RequestProvider();
    final teamProvider = TeamProvider();
    final themeProvider = ThemeProvider();

    // CRITICAL FIX: Check auth status immediately to fetch user data from Firestore
    // This ensures that if Firebase Auth has a logged-in user, we fetch their data
    userProvider.checkAuthStatus();

    final router = GoRouter(
      initialLocation: initialLocation,
      refreshListenable: userProvider,
      redirect: (context, state) {
        final isLoggedIn = userProvider.isAuthenticated;
        final isOnboarding = state.matchedLocation == '/onboarding';
        final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

        // Allow onboarding screen to be accessed without login
        if (isOnboarding) {
          return null;
        }

        // Giriş yapmamışsa ve login/register sayfasında değilse -> Login'e at
        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        // Giriş yapmışsa ve hala login/register sayfasına gitmeye çalışıyorsa -> Home'a at
        if (isLoggedIn && isLoggingIn) {
          return '/home';
        }

        return null;
      },
      routes: [
        // Onboarding route (outside ShellRoute - no bottom bar)
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        // Auth routes (outside ShellRoute - no bottom bar)
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        
        // Main app routes (inside ShellRoute - with bottom bar)
        ShellRoute(
          builder: (context, state, child) {
            return MainScaffold(
              child: child,
              location: state.matchedLocation,
            );
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
            GoRoute(
              path: '/team',
              builder: (context, state) => const TeamListScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            // Nested routes (no bottom bar needed for these)
            GoRoute(
              path: '/user-detail',
              builder: (context, state) {
                final user = state.extra as UserModel; 
                return UserDetailScreen(user: user);
              },
            ),
            GoRoute(
              path: '/create-meeting',
              builder: (context, state) {
                final recipient = state.extra as UserModel;
                return CreateMeetingScreen(recipient: recipient);
              },
            ),
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
          ],
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: calendarProvider),
        ChangeNotifierProvider.value(value: requestProvider),
        ChangeNotifierProvider.value(value: teamProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Nexu',
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            
            // 🌍 Localization
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            
            // 🎨 Theme System with Functional Toggle
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
          );
        },
      ),
    );
  }
}