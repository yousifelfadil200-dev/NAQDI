import 'package:flutter/material.dart';

void main() => runApp(const NaqdiApp());

const purple = Color(0xFF6417B8);
const deepPurple = Color(0xFF390875);
const pale = Color(0xFFF5EEFF);
const ink = Color(0xFF24123D);

class NaqdiApp extends StatelessWidget {
  const NaqdiApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'نقدي | NAQDI',
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFFCFAFF), colorScheme: ColorScheme.fromSeed(seedColor: purple), fontFamily: 'Roboto'),
    home: const Directionality(textDirection: TextDirection.rtl, child: DemoShell()),
  );
}

class Tx {
  final String title, date;
  final int amount;
  Tx(this.title, this.amount, this.date);
}

class DemoShell extends StatefulWidget {
  const DemoShell({super.key});
  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  int tab = 0;
  int balance = 350000;
  final phone = TextEditingController();
  final amount = TextEditingController();
  final note = TextEditingController();
  final List<Tx> history = [Tx('تحويل تجريبي وارد', 50000, '02 نوفمبر 2026'), Tx('شراء رصيد تجريبي', -2500, '01 نوفمبر 2026')];

  String money(int n) => '${n.abs().toString().replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (m) => ',')} ج.س';
  void toast(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s), behavior: SnackBarBehavior.floating));

  void transaction(String kind) {
    final n = int.tryParse(amount.text.trim());
    if (n == null || n <= 0) { toast('أدخل مبلغاً صحيحاً'); return; }
    if (kind == 'تحويل' && phone.text.trim().length < 9) { toast('أدخل رقم هاتف المستلم'); return; }
    if (kind == 'سحب' && n > balance) { toast('الرصيد التجريبي غير كافٍ'); return; }
    setState(() {
      if (kind == 'إيداع') balance += n; else balance -= n;
      history.insert(0, Tx(kind == 'تحويل' ? 'تحويل إلى ${phone.text}' : '$kind تجريبي', kind == 'إيداع' ? n : -n, '02 نوفمبر 2026'));
      tab = 0;
      phone.clear(); amount.clear(); note.clear();
    });
    toast('تم تسجيل $kind التجريبي بنجاح');
  }

  @override
  void dispose() { phone.dispose(); amount.dispose(); note.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final pages = [home(), transfer(), activity(), profile()];
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, title: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: purple, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white)), const SizedBox(width: 10), const Text('نقدي', style: TextStyle(color: deepPurple, fontWeight: FontWeight.w900, fontSize: 22)), const SizedBox(width: 6), const Text('NAQDI', style: TextStyle(color: purple, fontWeight: FontWeight.bold, fontSize: 12))]), actions: [IconButton(onPressed: () => toast('لا توجد إشعارات جديدة'), icon: const Icon(Icons.notifications_none, color: deepPurple))]),
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(backgroundColor: Colors.white, indicatorColor: pale, selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: purple), label: 'الرئيسية'), NavigationDestination(icon: Icon(Icons.send_outlined), selectedIcon: Icon(Icons.send, color: purple), label: 'تحويل'), NavigationDestination(icon: Icon(Icons.history), selectedIcon: Icon(Icons.history, color: purple), label: 'السجل'), NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: purple), label: 'حسابي')]),
    );
  }

  Widget home() => ListView(padding: const EdgeInsets.all(16), children: [
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [deepPurple, purple]), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('رصيدك الحالي', style: TextStyle(color: Colors.white70)), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)), child: const Text('نسخة تجريبية', style: TextStyle(color: Colors.white, fontSize: 11)))]), const SizedBox(height: 10), Text(money(balance), style: const TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900)), const SizedBox(height: 16), const Divider(color: Colors.white30), const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('رقم المحفظة', style: TextStyle(color: Colors.white70)), Text('09XXXXXXXX', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])])),
    const SizedBox(height: 22), const Text('الخدمات الرئيسية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ink)), const SizedBox(height: 12),
    GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.05, children: [service(Icons.send_rounded, 'تحويل', () => setState(() => tab = 1)), service(Icons.add_circle_outline, 'إيداع', () => actionPage('إيداع')), service(Icons.account_balance_wallet_outlined, 'سحب', () => actionPage('سحب')), service(Icons.receipt_long, 'الفواتير', () => toast('خدمة تجريبية - قريباً')), service(Icons.phone_android, 'شحن رصيد', () => toast('خدمة تجريبية - قريباً')), service(Icons.person_outline, 'إدارة الحساب', () => setState(() => tab = 3))]),
    const SizedBox(height: 22), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('آخر العمليات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ink)), TextButton(onPressed: () => setState(() => tab = 2), child: const Text('عرض الكل'))]), ...history.take(3).map(txTile),
    const SizedBox(height: 16), const Text('تنبيه: هذا تطبيق تجريبي؛ لا توجد أموال حقيقية أو خدمات مصرفية متصلة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.deepOrange, fontSize: 11)),
  ]);

  Widget service(IconData icon, String label, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(17), child: Container decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFECE2F8))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: purple, size: 28), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: ink, fontSize: 12))])));

  Widget txTile(Tx tx) => Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Row(children: [CircleAvatar(backgroundColor: tx.amount > 0 ? const Color(0xFFE7F7EE) : pale, child: Icon(tx.amount > 0 ? Icons.south_west : Icons.north_east, color: tx.amount > 0 ? Colors.green : purple)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, color: ink)), Text(tx.date, style: const TextStyle(color: Colors.grey, fontSize: 11))])), Text('${tx.amount > 0 ? '+' : '-'}${money(tx.amount)}', style: TextStyle(fontWeight: FontWeight.bold, color: tx.amount > 0 ? Colors.green : ink, fontSize: 12))]));

  Widget transfer() => formPage('تحويل الأموال', 'أدخل بيانات المستلم', true, 'تحويل');
  Widget formPage(String title, String subtitle, bool needsPhone, String kind) => ListView(padding: const EdgeInsets.all(18), children: [Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: deepPurple)), const SizedBox(height: 5), Text(subtitle, style: const TextStyle(color: Colors.grey)), const SizedBox(height: 22), if (needsPhone) ...[const Text('رقم هاتف المستلم'), const SizedBox(height: 7), TextField(controller: phone, keyboardType: TextInputType.phone, decoration: field('09XXXXXXXX', Icons.phone_android)), const SizedBox(height: 16)], const Text('المبلغ بالجنيه السوداني'), const SizedBox(height: 7), TextField(controller: amount, keyboardType: TextInputType.number, decoration: field('أدخل المبلغ', Icons.payments_outlined)), const SizedBox(height: 16), const Text('البيان (اختياري)'), const SizedBox(height: 7), TextField(controller: note, decoration: field('سبب العملية', Icons.edit_note)), const SizedBox(height: 22), Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: pale, borderRadius: BorderRadius.circular(15)), child: const Text('رسوم العملية التجريبية: 0 ج.س\nلن يتم إرسال أموال حقيقية.', style: TextStyle(color: deepPurple, height: 1.7))), const SizedBox(height: 20), FilledButton(onPressed: () => transaction(kind), style: FilledButton.styleFrom(backgroundColor: purple, padding: const EdgeInsets.all(16)), child: Text('تأكيد $kind', style: const TextStyle(fontWeight: FontWeight.bold))),]);
  InputDecoration field(String hint, IconData icon) => InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: purple), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5D9F4))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5D9F4))));

  void actionPage(String kind) { Navigator.push(context, MaterialPageRoute(builder: (_) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(appBar: AppBar(title: Text(kind)), body: formPage(kind, 'أدخل مبلغ العملية التجريبية', false, kind))))); }

  Widget activity() => ListView(padding: const EdgeInsets.all(16), children: [const Text('سجل العمليات', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: deepPurple)), const SizedBox(height: 15), if (history.isEmpty) const Text('لا توجد عمليات حتى الآن') else ...history.map(txTile)]);
  Widget profile() => ListView(padding: const EdgeInsets.all(16), children: [Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [deepPurple, purple]), borderRadius: BorderRadius.circular(20)), child: const Column(children: [CircleAvatar(radius: 35, backgroundColor: Colors.white, child: Icon(Icons.person, color: purple, size: 40)), SizedBox(height: 10), Text('مستخدم نقدي التجريبي', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), Text('09XXXXXXXX', style: TextStyle(color: Colors.white70))])), const SizedBox(height: 15), ...[['المعلومات الشخصية', Icons.person_outline], ['الأمان والخصوصية', Icons.shield_outlined], ['اللغة', Icons.language], ['مساعدة ودعم', Icons.help_outline], ['عن نقدي', Icons.info_outline]].map((e) => ListTile(onTap: () => toast('هذه الخاصية ستتوفر لاحقاً'), leading: Icon(e[1] as IconData, color: purple), title: Text(e[0] as String), trailing: const Icon(Icons.chevron_left))), const Center(child: Text('NAQDI • DEMO VERSION 1.0', style: TextStyle(color: Colors.grey, fontSize: 11)))]);
}
