import 'package:flutter/material.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/application/configs/di/injection_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<User>? _topUsers;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final client = sl<Client>();
    try {
      final top = await client.leaderboard.getTopUsers();
      // Assume current user ID is available or just show top
      setState(() {
        _topUsers = top;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'common.error'.tr()}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('leaderboard.title'.tr(), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20)),
            Text('leaderboard.subtitle'.tr(), style: GoogleFonts.poppins(fontSize: 10, color: Colors.white38)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_topUsers != null && _topUsers!.isNotEmpty) _buildPodium(_topUsers!),
                Expanded(child: _buildList(_topUsers ?? [])),
              ],
            ),
    );
  }

  Widget _buildPodium(List<User> users) {
    // Only show podium if we have at least 1 user, ideally 3
    final first = users.isNotEmpty ? users[0] : null;
    final second = users.length > 1 ? users[1] : null;
    final third = users.length > 2 ? users[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null) _buildPodiumStep(second, 2, 100),
          const SizedBox(width: 10),
          if (first != null) _buildPodiumStep(first, 1, 140),
          const SizedBox(width: 10),
          if (third != null) _buildPodiumStep(third, 3, 80),
        ],
      ),
    );
  }

  Widget _buildPodiumStep(User user, int rank, double height) {
    final color = rank == 1 ? Colors.amber : (rank == 2 ? Colors.grey[400]! : Colors.orange[300]!);
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 40 : 30,
              backgroundColor: color,
              child: CircleAvatar(
                radius: rank == 1 ? 37 : 27,
                backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null ? const Icon(Icons.person) : null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(user.name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        Text('${user.streakCount} 🔥', style: const TextStyle(color: Colors.amber, fontSize: 10)),
        const SizedBox(height: 10),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.1)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<User> users) {
    final list = users.length > 3 ? users.sublist(3) : [];
    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        final user = list[index];
        final rank = index + 4;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
               Text('#$rank', style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.bold)),
               const SizedBox(width: 15),
               CircleAvatar(
                 radius: 18,
                 backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                 child: user.photoUrl == null ? const Icon(Icons.person, size: 18) : null,
               ),
               const SizedBox(width: 15),
               Expanded(
                 child: Text(user.name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
               ),
               Text('${user.streakCount} 🔥', style: GoogleFonts.poppins(color: Colors.amber, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}
