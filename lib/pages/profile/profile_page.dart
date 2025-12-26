import 'package:flutter/material.dart';
import 'package:lla_sample/pages/design_course_app_theme.dart';
import 'package:lla_sample/services/auth_service.dart';
import 'package:lla_sample/models/userprofile.dart';
import 'package:lla_sample/pages/profile/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _currentUser;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F8),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: StreamBuilder<UserProfile?>(
        stream: AuthService().getUserProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          
          if (user == null) {
             return const Center(child: Text("No profile data"));
          }
          
          // Store for use in menu options
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_currentUser?.id != user.id) {
              setState(() => _currentUser = user);
            }
          });

          final stats = user.stats;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                _buildStatsGrid(stats),
                const SizedBox(height: 24),
                _buildMenuOptions(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: DesignCourseAppTheme.nearlyBlue.withOpacity(0.1),
            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null 
                ? const Icon(Icons.person, size: 50, color: DesignCourseAppTheme.nearlyBlue)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.name ?? "Student",
            style: const TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold,
              color: Colors.black87
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email ?? "",
            style: const TextStyle(
              fontSize: 14, 
              color: Colors.grey
            ),
          ),
          const SizedBox(height: 16),
          Chip(
            label: Text(user.classLevel.isNotEmpty ? user.classLevel : "Class ?"),
            backgroundColor: DesignCourseAppTheme.nearlyBlue.withOpacity(0.1),
            labelStyle: TextStyle(color: DesignCourseAppTheme.nearlyBlue),
          ),
          const SizedBox(height: 16),
          if (user.schoolName != null) ...[
             const Divider(),
             const SizedBox(height: 8),
             _buildInfoRow(Icons.school, user.schoolName!),
             const SizedBox(height: 8),
          ],
          if (user.guardianName != null) ...[
             _buildInfoRow(Icons.family_restroom, "Guardian: ${user.guardianName}"),
             const SizedBox(height: 8),
          ],
          if (user.phoneNumber != null) ...[
             _buildInfoRow(Icons.phone, user.phoneNumber!),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.black54, fontSize: 13)),
      ],
    );
  }

  Widget _buildStatsGrid(UserStats stats) {
    return Row(
      children: [
        _buildStatCard("Quizzes", "${stats.quizzesTaken}", Icons.quiz),
        const SizedBox(width: 16),
        _buildStatCard("Questions", "${stats.questionsSolved}", Icons.check_circle_outline),
        const SizedBox(width: 16),
        _buildStatCard("Avg Score", "${stats.averageScore.toStringAsFixed(0)}%", Icons.emoji_events),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: DesignCourseAppTheme.nearlyBlue, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.edit, "Edit Profile", () {
            if (_currentUser != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(currentProfile: _currentUser!),
                ),
              );
            }
          }),
          const Divider(height: 1),
          _buildMenuItem(Icons.history, "Quiz History", () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.settings, "Settings", () {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
