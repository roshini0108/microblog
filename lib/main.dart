import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MicroblogApp());

class MicroblogApp extends StatelessWidget {
  const MicroblogApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microblog Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),
      ),
      home: const HomeShell(),
    );
  }
}

/// Simple in-memory models
class User {
  final String username;
  final String name;
  bool following;
  User({required this.username, required this.name, this.following = false});
}

class Tweet {
  final String id;
  final User user;
  final String text;
  final DateTime time;
  int likes;
  int retweets;
  bool liked;
  bool retweeted;
  Tweet({
    required this.id,
    required this.user,
    required this.text,
    DateTime? time,
    this.likes = 0,
    this.retweets = 0,
    this.liked = false,
    this.retweeted = false,
  }) : time = time ?? DateTime.now();
}

/// App shell with bottom navigation
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final List<User> users = [
    User(username: 'alice', name: 'Alice Johnson'),
    User(username: 'bob', name: 'Bob Singh'),
    User(username: 'carla', name: 'Carla Gomez'),
  ];

  late List<Tweet> tweets;
  int _selectedIndex = 0;
  final _composerController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    tweets = List.generate(8, (i) {
      final u = users[rnd.nextInt(users.length)];
      return Tweet(
        id: 't$i',
        user: u,
        text: sampleTexts[i % sampleTexts.length],
        time: DateTime.now().subtract(Duration(minutes: 10 * i)),
        likes: rnd.nextInt(50),
        retweets: rnd.nextInt(20),
      );
    });
  }

  void _postTweet(String text) {
    if (text.trim().isEmpty) return;
    final newTweet = Tweet(
      id: 't${tweets.length + 1}',
      user: users[0], // current user is users[0]
      text: text,
      time: DateTime.now(),
    );
    setState(() {
      tweets.insert(0, newTweet);
      _composerController.clear();
    });
    // show small confirmation
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Posted')));
  }

  void _toggleLike(Tweet t) {
    setState(() {
      t.liked = !t.liked;
      t.likes += t.liked ? 1 : -1;
    });
  }

  void _toggleRetweet(Tweet t) {
    setState(() {
      t.retweeted = !t.retweeted;
      t.retweets += t.retweeted ? 1 : -1;
    });
  }

  void _deleteTweet(Tweet t) {
    setState(() => tweets.removeWhere((x) => x.id == t.id));
  }

  List<Tweet> _filterFeed() {
    final q = _searchController.text.toLowerCase().trim();
    if (q.isEmpty) return tweets;
    return tweets
        .where(
          (t) =>
              t.text.toLowerCase().contains(q) ||
              t.user.username.toLowerCase().contains(q),
        )
        .toList();
  }

  Widget _buildComposer() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: _composerController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "What's happening?",
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _postTweet(_composerController.text),
                      icon: const Icon(Icons.send),
                      label: const Text('Tweet'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedTab() {
    final list = _filterFeed();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search tweets or users',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        _buildComposer(),
        const Divider(height: 1),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('No results'))
              : RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 300));
                    setState(() {
                      tweets.shuffle();
                    });
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final t = list[idx];
                      return TweetCard(
                        tweet: t,
                        onLike: () => _toggleLike(t),
                        onRetweet: () => _toggleRetweet(t),
                        onDelete: t.user == users[0]
                            ? () => _deleteTweet(t)
                            : null,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _exploreTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Trending',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(8, (i) {
              return Chip(
                label: Text('#topic${i + 1}'),
                backgroundColor: Colors.white,
              );
            }),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Suggested people',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: users.map((u) {
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(u.name),
                subtitle: Text('@${u.username}'),
                trailing: TextButton(
                  onPressed: () => setState(() => u.following = !u.following),
                  child: Text(u.following ? 'Following' : 'Follow'),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _messagesTab() {
    return const Center(child: Text('Messages — (demo)'));
  }

  Widget _profileTab() {
    final self = users[0];
    final myTweets = tweets.where((t) => t.user == self).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 36, child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    self.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '@${self.username}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('${myTweets.length} Tweets'),
                      const SizedBox(width: 12),
                      Text(
                        'Following: ${users.where((u) => u.following).length}',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: myTweets.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final t = myTweets[i];
              return TweetCard(
                tweet: t,
                onLike: () => _toggleLike(t),
                onRetweet: () => _toggleRetweet(t),
                onDelete: () => _deleteTweet(t),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_feedTab(), _exploreTab(), _messagesTab(), _profileTab()];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Microblog',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _selectedIndex = 2),
            icon: const Icon(Icons.mail_outline),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[700],
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickCompose(context),
        child: const Icon(Icons.create),
      ),
    );
  }

  void _showQuickCompose(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) {
        final ctl = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: const [
                    CircleAvatar(child: Icon(Icons.person)),
                    SizedBox(width: 8),
                    Text('Compose'),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: ctl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "What's happening?",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _postTweet(ctl.text);
                  },
                  child: const Text('Tweet'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget to display a tweet
class TweetCard extends StatelessWidget {
  final Tweet tweet;
  final VoidCallback onLike;
  final VoidCallback onRetweet;
  final VoidCallback? onDelete;
  const TweetCard({
    required this.tweet,
    required this.onLike,
    required this.onRetweet,
    this.onDelete,
    super.key,
  });

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Row(
        children: [
          Text(
            tweet.user.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            '@${tweet.user.username} · ${_timeAgo(tweet.time)}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Spacer(),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.grey,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Text(tweet.text),
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: onRetweet,
                child: Row(
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 18,
                      color: tweet.retweeted ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text('${tweet.retweets}'),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 18,
                      color: tweet.liked ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text('${tweet.likes}'),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () => _showReplySheet(context),
                child: Row(
                  children: const [
                    Icon(
                      Icons.mode_comment_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 6),
                    Text('Reply'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showReplySheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (c) {
        final ctl = TextEditingController();
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets + const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reply to @${tweet.user.username}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Write a reply',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Reply posted (demo)')),
                  );
                },
                child: const Text('Reply'),
              ),
            ],
          ),
        );
      },
    );
  }
}

const sampleTexts = [
  'Just tried a new cafe — the coffee was amazing ☕',
  'Small wins every day count. Keep going!',
  'Working on a fun side project — will share soon 🚀',
  'Does anyone recommend a good Python tutorial?',
  'Listening to lo-fi beats to focus 🎧',
  'Day trip to the hills — fresh air and great views.',
  'What’s your favorite book this year?',
  'Learning Flutter is fun and productive!',
];
