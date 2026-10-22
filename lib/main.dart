import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const GradeTrackerApp());
}

const ink = Color(0xFF142B28);
const forest = Color(0xFF28665A);
const mint = Color(0xFFD9EEE4);
const lime = Color(0xFFD7F36A);
const paper = Color(0xFFF5F6F0);

class GradeTrackerApp extends StatefulWidget {
  const GradeTrackerApp({super.key});

  @override
  State<GradeTrackerApp> createState() => _GradeTrackerAppState();
}

class _GradeTrackerAppState extends State<GradeTrackerApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _loading = true;
  String? _studentName;
  int _selectedTab = 0;
  final List<Course> _courses = [
    Course('Biology', 'BIO 204', const Color(0xFFE0EFCB), [
      Grade('Cell lab report', 18, 20),
      Grade('Chapter 4 quiz', 17, 20),
      Grade('Ecosystems exam', 88, 100),
    ]),
    Course('World History', 'HIS 110', const Color(0xFFF6DFD4), [
      Grade('Primary source essay', 46, 50),
      Grade('Unit 2 test', 84, 100),
    ]),
    Course('Algebra II', 'MAT 231', const Color(0xFFDCE8F4), [
      Grade('Functions worksheet', 19, 20),
      Grade('Polynomials quiz', 42, 50),
      Grade('Midterm', 91, 100),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  double get _overallGrade {
    final grades = _courses.expand((course) => course.grades).toList();
    if (grades.isEmpty) return 0;
    final earned = grades.fold<double>(0, (sum, grade) => sum + grade.earned);
    final possible = grades.fold<double>(
      0,
      (sum, grade) => sum + grade.possible,
    );
    return possible == 0 ? 0 : earned / possible * 100;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Grade Tracker-Fajilan, Sernal, Cabailo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: paper,
        colorScheme: ColorScheme.fromSeed(seedColor: forest),
        useMaterial3: true,
      ),
      home: _loading
          ? const LoadingScreen()
          : _studentName == null
          ? AuthScreen(
              onAuthenticated: (name) => setState(() => _studentName = name),
            )
          : TrackerScreen(
              studentName: _studentName!,
              courses: _courses,
              overallGrade: _overallGrade,
              selectedTab: _selectedTab,
              onTabSelected: (tab) => setState(() => _selectedTab = tab),
              onAddGrade: _addGrade,
              onSignOut: () => setState(() {
                _studentName = null;
                _selectedTab = 0;
              }),
            ),
    );
  }

  Future<void> _addGrade() async {
    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null) return;
    final result = await showDialog<GradeSubmission>(
      context: dialogContext,
      builder: (context) => AddGradeDialog(courses: _courses),
    );
    if (result == null) return;
    setState(() {
      _courses
          .firstWhere((course) => course.name == result.courseName)
          .grades
          .add(Grade(result.title, result.earned, result.possible));
    });
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: lime,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_graph_rounded, size: 40, color: ink),
            ),
            const SizedBox(height: 22),
            const Text(
              'grade garden',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A little progress, every day.',
              style: TextStyle(color: Color(0xFFB7C9C2), fontSize: 14),
            ),
            const SizedBox(height: 36),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: lime),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onAuthenticated});

  final ValueChanged<String> onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final name = _isRegistering
        ? _nameController.text.trim().split(' ').first
        : _emailController.text.trim().split('@').first;
    widget.onAuthenticated(name.isEmpty ? 'Student' : name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: ink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_graph_rounded,
                          color: lime,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 11),
                      const Text(
                        'grade garden',
                        style: TextStyle(
                          color: ink,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 42),
                  Text(
                    _isRegistering ? 'Start growing.' : 'Welcome back.',
                    style: const TextStyle(
                      color: ink,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isRegistering
                        ? 'Create your account and keep every class in view.'
                        : 'Your semester, looking a little clearer.',
                    style: const TextStyle(
                      color: Color(0xFF697671),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EBE4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _AuthTab(
                          label: 'Log in',
                          selected: !_isRegistering,
                          onTap: () => setState(() => _isRegistering = false),
                        ),
                        _AuthTab(
                          label: 'Register',
                          selected: _isRegistering,
                          onTap: () => setState(() => _isRegistering = true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_isRegistering) ...[
                          _InputField(
                            controller: _nameController,
                            label: 'Your name',
                            icon: Icons.person_outline_rounded,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Enter your name'
                                : null,
                          ),
                          const SizedBox(height: 15),
                        ],
                        _InputField(
                          controller: _emailController,
                          label: 'School email',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value == null || !value.contains('@')
                              ? 'Enter a valid email address'
                              : null,
                        ),
                        const SizedBox(height: 15),
                        _InputField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _hidePassword,
                          suffix: IconButton(
                            onPressed: () =>
                                setState(() => _hidePassword = !_hidePassword),
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF697671),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.length < 6
                              ? 'Use at least 6 characters'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: ink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _submit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isRegistering ? 'Create account' : 'Log in',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 19),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Your grades stay on this device.',
                      style: TextStyle(
                        color: Colors.blueGrey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTab extends StatelessWidget {
  const _AuthTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: TextButton(
      style: TextButton.styleFrom(
        backgroundColor: selected ? Colors.white : Colors.transparent,
        foregroundColor: selected ? ink : const Color(0xFF697671),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    ),
  );
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: forest),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE4E8E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: forest, width: 1.5),
      ),
    ),
  );
}

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({
    super.key,
    required this.studentName,
    required this.courses,
    required this.overallGrade,
    required this.selectedTab,
    required this.onTabSelected,
    required this.onAddGrade,
    required this.onSignOut,
  });

  final String studentName;
  final List<Course> courses;
  final double overallGrade;
  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddGrade;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GRADE GARDEN',
                              style: TextStyle(
                                color: forest,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Hey, $studentName',
                              style: const TextStyle(
                                color: ink,
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onSignOut,
                        tooltip: 'Sign out',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.logout_rounded, color: ink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _OverallCard(
                    grade: overallGrade,
                    courseCount: courses.length,
                  ),
                  const SizedBox(height: 27),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedTab == 0 ? 'Your classes' : 'All classes',
                        style: const TextStyle(
                          color: ink,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onAddGrade,
                        icon: const Icon(Icons.add_rounded, size: 19),
                        label: const Text('Add grade'),
                        style: TextButton.styleFrom(
                          foregroundColor: forest,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  for (final course in courses) _CourseCard(course: course),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EEE6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: forest,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Small steps add up. You have ${courses.fold<int>(0, (sum, course) => sum + course.grades.length)} grades tracked this term.',
                            style: const TextStyle(
                              color: ink,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddGrade,
        backgroundColor: lime,
        foregroundColor: ink,
        tooltip: 'Add a grade',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: onTabSelected,
        backgroundColor: Colors.white,
        indicatorColor: mint,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Classes',
          ),
        ],
      ),
    );
  }
}

class _OverallCard extends StatelessWidget {
  const _OverallCard({required this.grade, required this.courseCount});

  final double grade;
  final int courseCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ink,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SEMESTER SNAPSHOT',
                style: TextStyle(
                  color: Color(0xFFB7C9C2),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF29423C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$courseCount classes',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${grade.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: lime,
                  fontSize: 43,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  'overall average',
                  style: TextStyle(color: Color(0xFFB7C9C2), fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 21),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: grade / 100,
              minHeight: 7,
              backgroundColor: const Color(0xFF34514A),
              color: lime,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Keep showing up. It is working.',
            style: TextStyle(color: Color(0xFFB7C9C2), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBE4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: course.tint,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: ink.withValues(alpha: 0.8),
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      course.code,
                      style: const TextStyle(
                        color: Color(0xFF87918C),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${course.average.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 7),
              _LetterGrade(value: course.average),
            ],
          ),
          if (course.grades.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Divider(height: 1, color: Color(0xFFEEF0EB)),
            ),
            for (final grade in course.grades.take(2))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        grade.title,
                        style: const TextStyle(
                          color: Color(0xFF56635E),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      '${grade.earned.toStringAsFixed(0)} / ${grade.possible.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF56635E),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (course.grades.length > 2)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '+ ${course.grades.length - 2} more grades',
                  style: const TextStyle(
                    color: forest,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _LetterGrade extends StatelessWidget {
  const _LetterGrade({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final letter = value >= 90
        ? 'A'
        : value >= 80
        ? 'B'
        : value >= 70
        ? 'C'
        : value >= 60
        ? 'D'
        : 'F';
    return Container(
      width: 29,
      height: 29,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: mint,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          color: forest,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AddGradeDialog extends StatefulWidget {
  const AddGradeDialog({super.key, required this.courses});

  final List<Course> courses;

  @override
  State<AddGradeDialog> createState() => _AddGradeDialogState();
}

class _AddGradeDialogState extends State<AddGradeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _earnedController = TextEditingController();
  final _possibleController = TextEditingController(text: '100');
  String? _courseName;

  @override
  void dispose() {
    _titleController.dispose();
    _earnedController.dispose();
    _possibleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: paper,
      title: const Text(
        'Add a grade',
        style: TextStyle(color: ink, fontWeight: FontWeight.w700),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _courseName,
                decoration: const InputDecoration(labelText: 'Class'),
                items: widget.courses
                    .map(
                      (course) => DropdownMenuItem(
                        value: course.name,
                        child: Text(course.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _courseName = value),
                validator: (value) => value == null ? 'Choose a class' : null,
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Assignment name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter an assignment name'
                    : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _earnedController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Score'),
                      validator: _validateScore,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _possibleController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Out of'),
                      validator: _validateScore,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(backgroundColor: ink),
          child: const Text('Save grade'),
        ),
      ],
    );
  }

  String? _validateScore(String? value) {
    final score = double.tryParse(value ?? '');
    return score == null || score < 0 ? 'Enter a valid score' : null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final earned = double.parse(_earnedController.text);
    final possible = double.parse(_possibleController.text);
    if (possible <= 0 || earned > possible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Score must not exceed a positive total.'),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      GradeSubmission(
        _courseName!,
        _titleController.text.trim(),
        earned,
        possible,
      ),
    );
  }
}

class Course {
  Course(this.name, this.code, this.tint, this.grades);

  final String name;
  final String code;
  final Color tint;
  final List<Grade> grades;

  double get average {
    if (grades.isEmpty) return 0;
    final earned = grades.fold<double>(0, (sum, grade) => sum + grade.earned);
    final possible = grades.fold<double>(
      0,
      (sum, grade) => sum + grade.possible,
    );
    return possible == 0 ? 0 : earned / possible * 100;
  }
}

class Grade {
  const Grade(this.title, this.earned, this.possible);

  final String title;
  final double earned;
  final double possible;
}

class GradeSubmission {
  const GradeSubmission(
    this.courseName,
    this.title,
    this.earned,
    this.possible,
  );

  final String courseName;
  final String title;
  final double earned;
  final double possible;
}
