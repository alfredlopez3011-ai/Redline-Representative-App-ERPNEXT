import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = <(String, String)>[
    (
      'البيانات التي يعالجها التطبيق',
      'يعالج RedLine بيانات تسجيل الدخول وخادم ERP الذي تختاره، وبيانات العمل '
          'المصرح لك بها مثل العملاء والطلبات والفواتير والتحصيلات. تُحفظ رموز '
          'الجلسة في التخزين الآمن على جهازك، وقد تُحفظ نسخة محلية من بيانات '
          'العمل اللازمة للعمل دون اتصال.',
    ),
    (
      'الموقع والصور والتقويم',
      'يُطلب الموقع فقط عند تنفيذ عملية تحتاج إثبات موقع، مثل تسجيل زيارة أو '
          'إنشاء مستند ميداني. تُستخدم الكاميرا أو الصور فقط عند اختيارك إرفاق '
          'صورة. ويُستخدم التقويم فقط عندما تختار إضافة تذكير استحقاق. لا يعمل '
          'التطبيق على تتبع موقعك في الخلفية.',
    ),
    (
      'الإشعارات',
      'يستخدم التطبيق Firebase Cloud Messaging لإرسال إشعارات العمل. قد يُرسل '
          'رمز إشعارات خاص بالجهاز إلى خادم ERP المرتبط بحسابك لتمكين هذه الخدمة.',
    ),
    (
      'مشاركة البيانات والاحتفاظ بها',
      'تُرسل بيانات العمل إلى خادم ERP الذي تسجل الدخول إليه وإلى خدمات Google '
          'اللازمة لتوصيل الإشعارات. لا يبيع التطبيق بياناتك. تُحذف بيانات الجلسة '
          'والنسخ المحلية المرتبطة بالحساب من الجهاز عند تسجيل الخروج.',
    ),
    (
      'التحكم في بياناتك',
      'يمكنك إلغاء صلاحيات الموقع والكاميرا والتقويم والإشعارات من إعدادات '
          'Android. حسابات المستخدمين تُدار بواسطة جهة العمل على خادم ERP؛ لطلب '
          'تصحيح بيانات حسابك أو حذفه تواصل مع مسؤول النظام في جهة عملك.',
    ),
    (
      'التواصل',
      'للاستفسارات المتعلقة بالخصوصية تواصل مع Red Tech For Technology أو مع '
          'مسؤول نظام ERP في جهة عملك. آخر تحديث: 9 أكتوبر 2026.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(title: const Text('سياسة الخصوصية')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final section in _sections)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.$1,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section.$2,
                    style: const TextStyle(
                      height: 1.7,
                      color: AppColors.midGray,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
