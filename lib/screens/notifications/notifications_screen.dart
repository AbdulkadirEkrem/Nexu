import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/request_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/meeting_request_model.dart';
import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // initState yerine didChangeDependencies kullanarak kullanıcı değişimini yakalıyoruz
  // Bu sayede Utku çıkıp Abdulkadir girdiğinde liste anında yenileniyor.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    final user = userProvider.currentUser;
    
    // Eğer kullanıcı varsa Provider'ı bu kullanıcı ID'si ile başlat.
    // Provider'ın içindeki mantık, ID değiştiyse eski veriyi silecek.
    if (user != null) {
      requestProvider.initialize(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            tr('notifications_title'),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: AppColors.primary,
                  ),
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(text: tr('tab_incoming')), // Bana Gelenler (Sadece Bekleyen)
                    Tab(text: tr('tab_sent')),     // Benim Gönderdiklerim (Hepsi)
                    Tab(text: tr('tab_feedback')), // Cevaplananlar (Onay/Red)
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Consumer<RequestProvider>(
          builder: (context, requestProvider, _) {
            // Yükleniyor ve listeler boşsa
            if (requestProvider.isLoading &&
                requestProvider.incomingRequests.isEmpty &&
                requestProvider.outgoingRequests.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filtreleme: Feedback sekmesi için sadece Accepted/Declined olanları ayır
            final feedbackRequests = requestProvider.outgoingRequests
                .where((r) => r.status != RequestStatus.pending)
                .toList();

            return TabBarView(
              children: [
                // 1. Sekme: INCOMING (Gelen Kutusu - Sadece Pending)
                _buildRequestList(
                  requests: requestProvider.incomingRequests,
                  emptyMessage: tr('no_pending_requests'),
                  icon: Icons.inbox_outlined,
                  isIncoming: true,
                ),

                // 2. Sekme: SENT (Giden Kutusu - Hepsi)
                _buildRequestList(
                  requests: requestProvider.outgoingRequests,
                  emptyMessage: tr('no_sent_requests'),
                  icon: Icons.send_outlined,
                  isIncoming: false,
                ),

                // 3. Sekme: FEEDBACK (Sadece Cevaplananlar)
                _buildRequestList(
                  requests: feedbackRequests,
                  emptyMessage: tr('no_feedback_yet'),
                  icon: Icons.check_circle_outline,
                  isIncoming: false,
                  isFeedbackTab: true,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Listeleri oluşturmak için yardımcı metod (Kod tekrarını önler)
  Widget _buildRequestList({
    required List<MeetingRequestModel> requests,
    required String emptyMessage,
    required IconData icon,
    required bool isIncoming,
    bool isFeedbackTab = false,
  }) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        if (isFeedbackTab) {
          return _FeedbackCard(request: request);
        } else if (isIncoming) {
          return _RequestCard(request: request);
        } else {
          return _SentRequestCard(request: request);
        }
      },
    );
  }
}

// --- Alt Widgetlar ---

class _RequestCard extends StatelessWidget {
  final MeetingRequestModel request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
        border: isDark
            ? Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Kısım: Kimden Geldi?
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 24,
                  child: Text(
                    request.requesterName.isNotEmpty ? request.requesterName[0].toUpperCase() : '?',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requesterName,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr('requested_meeting_subtitle'),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Orta Kısım: Toplantı Detayları
            Text(
              request.title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            _RequestDetailRow(icon: Icons.calendar_today, label: tr('label_date'), value: request.formattedDate),
            const SizedBox(height: 6),
            _RequestDetailRow(icon: Icons.access_time, label: tr('label_time'), value: request.formattedTime),
            const SizedBox(height: 6),
            _RequestDetailRow(icon: Icons.timer, label: tr('label_duration'), value: request.formattedDuration),
            if (request.description != null && request.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _RequestDetailRow(
                icon: Icons.description,
                label: tr('label_desc'),
                value: request.description!,
                isLinkify: true,
              ),
            ],
            const SizedBox(height: 20),
            
            // Alt Kısım: Butonlar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await requestProvider.declineRequest(request.id);
                      if (context.mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(tr('msg_request_declined')),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error.withOpacity(0.1),
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      tr('btn_decline'),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await requestProvider.acceptRequest(request.id);
                      
                      if (context.mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(tr('msg_request_accepted')),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${requestProvider.errorMessage}'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      tr('btn_accept'),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SentRequestCard extends StatelessWidget {
  final MeetingRequestModel request;

  const _SentRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (request.status) {
      case RequestStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = tr('status_pending');
        break;
      case RequestStatus.accepted:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        statusText = tr('status_accepted');
        break;
      case RequestStatus.declined:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        statusText = tr('status_declined');
        break;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
        border: isDark
            ? Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 24,
                  child: Text(
                    request.recipientName.isNotEmpty ? request.recipientName[0].toUpperCase() : '?',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tr('to')}: ${request.recipientName}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: GoogleFonts.inter(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _RequestDetailRow(icon: Icons.calendar_today, label: tr('label_date'), value: request.formattedDate),
            const SizedBox(height: 6),
            _RequestDetailRow(icon: Icons.access_time, label: tr('label_time'), value: request.formattedTime),
            if (request.description != null && request.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _RequestDetailRow(
                icon: Icons.description,
                label: tr('label_desc'),
                value: request.description!,
                isLinkify: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final MeetingRequestModel request;

  const _FeedbackCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    final isAccepted = request.status == RequestStatus.accepted;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
        border: isDark
            ? Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              )
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isAccepted ? AppColors.success : AppColors.error).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isAccepted ? Icons.check_circle : Icons.cancel,
            color: isAccepted ? AppColors.success : AppColors.error,
            size: 28,
          ),
        ),
        title: Text(
          isAccepted ? '${request.recipientName} ${tr('accepted')}' : '${request.recipientName} ${tr('declined')}',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            request.title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          onPressed: () => requestProvider.dismissRequest(request.id),
        ),
      ),
    );
  }
}

class _RequestDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLinkify;

  const _RequestDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLinkify = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: isLinkify
                ? Linkify(
                    text: value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    linkStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                    onOpen: (link) async {
                      final uri = Uri.parse(link.url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  )
                : Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}