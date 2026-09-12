import 'package:flutter/foundation.dart';
import '../models/story_thread.dart';

class StoryThreadsViewModel extends ChangeNotifier {
  final List<StoryThread> _threads = [];
  String? _activeThreadId;

  StoryThreadsViewModel() {
    _initDefaultThreads();
  }

  List<StoryThread> get threads => List.unmodifiable(_threads);

  List<StoryThread> get followedThreads =>
      _threads.where((t) => t.isFollowing).toList();

  StoryThread? get activeThread => _threads.cast<StoryThread?>().firstWhere(
        (t) => t?.id == _activeThreadId,
        orElse: () => _threads.isNotEmpty ? _threads.first : null,
      );

  void setActiveThread(String threadId) {
    _activeThreadId = threadId;
    notifyListeners();
  }

  void toggleFollow(String threadId) {
    final index = _threads.indexWhere((t) => t.id == threadId);
    if (index != -1) {
      final current = _threads[index];
      _threads[index] = current.copyWith(isFollowing: !current.isFollowing);
      notifyListeners();
    }
  }

  void updateCheckpoint(String threadId, int newCheckpointIndex) {
    final index = _threads.indexWhere((t) => t.id == threadId);
    if (index != -1) {
      final current = _threads[index];
      if (newCheckpointIndex > current.checkpointIndex) {
        _threads[index] = current.copyWith(checkpointIndex: newCheckpointIndex);
        notifyListeners();
      }
    }
  }

  StoryThread? getThreadForArticle(String? threadId) {
    if (threadId == null) return null;
    return _threads.cast<StoryThread?>().firstWhere(
          (t) => t?.id == threadId,
          orElse: () => null,
        );
  }

  void _initDefaultThreads() {
    final now = DateTime.now();

    _threads.addAll([
      StoryThread(
        id: 'thread-ai-regulation',
        title: 'Global AI Governance & Semiconductor Accord',
        topic: 'Technology & Geopolitics',
        summary: 'Tracking international oversight frameworks, export controls on advanced compute, and safety thresholds for frontier foundation models.',
        category: 'technology',
        lastUpdated: now.subtract(const Duration(hours: 2)),
        isFollowing: true,
        checkpointIndex: 1, // Has 2 unread events
        events: [
          ThreadEvent(
            id: 'ai-ev-1',
            timestamp: now.subtract(const Duration(days: 6)),
            headline: 'Bipartisan Compute Transparency Act Drafted',
            summary: 'Legislators introduce early requirements for data center operators to log training runs exceeding 10^25 FLOPs.',
            source: 'Reuters Washington Bureau',
            impact: 'Legislative Draft',
          ),
          ThreadEvent(
            id: 'ai-ev-2',
            timestamp: now.subtract(const Duration(days: 4)),
            headline: 'Multilateral Frontier Model Safety Testing Protocols Agreed',
            summary: '14 leading national AI safety institutes coordinate joint red-teaming benchmarks for autonomous cyber resilience.',
            source: 'Financial Times Tech Desk',
            impact: 'Global Accord',
          ),
          ThreadEvent(
            id: 'ai-ev-3',
            timestamp: now.subtract(const Duration(days: 2)),
            headline: 'Semiconductor Export Restrictions Expanded to Sub-7nm Lithography',
            summary: 'New licensing requirements mandate bilateral reviews for high-bandwidth memory distribution across key logistics hubs.',
            source: 'Bloomberg Technology',
            impact: 'Market Disruption',
          ),
          ThreadEvent(
            id: 'ai-ev-4',
            timestamp: now.subtract(const Duration(hours: 2)),
            headline: 'Open-Weights Model Auditing Sandbox Launches',
            summary: 'Independent academic consortium opens verified evaluation platform for developer transparency and safety compliance.',
            source: 'Byline Editorial Verification',
            impact: 'New Update • Today',
          ),
        ],
      ),
      StoryThread(
        id: 'thread-clean-energy',
        title: 'The Global Clean Energy Transition 2026',
        topic: 'Energy & Climate Economics',
        summary: 'Following next-generation nuclear deployments, grid-scale storage breakthroughs, and critical minerals supply chains.',
        category: 'science',
        lastUpdated: now.subtract(const Duration(hours: 5)),
        isFollowing: false,
        checkpointIndex: 0,
        events: [
          ThreadEvent(
            id: 'energy-ev-1',
            timestamp: now.subtract(const Duration(days: 7)),
            headline: 'Solid-State Electrolyte Battery Factory Breaks Ground',
            summary: 'Commercial facilities target 400 Wh/kg density with initial commercial shipments scheduled for automotive OEMs.',
            source: 'Nikkei Asia',
            impact: 'Manufacturing Milestone',
          ),
          ThreadEvent(
            id: 'energy-ev-2',
            timestamp: now.subtract(const Duration(days: 3)),
            headline: 'Small Modular Reactor (SMR) Fast-Track Licensing Approved',
            summary: 'Regulatory commission establishes streamlined 18-month approval pipeline for standardized 300MW nuclear units.',
            source: 'The Wall Street Journal',
            impact: 'Regulatory Breakthrough',
          ),
          ThreadEvent(
            id: 'energy-ev-3',
            timestamp: now.subtract(const Duration(hours: 5)),
            headline: 'Offshore Floating Wind Turbine Sets Continuous Output Record',
            summary: 'Deepwater array endures Category 4 sea swells while maintaining 94% rated power delivery to coastal substation grids.',
            source: 'Byline Energy Desk',
            impact: 'New Update • Today',
          ),
        ],
      ),
      StoryThread(
        id: 'thread-global-economy',
        title: 'Central Banks & Post-Inflation Trajectory',
        topic: 'Global Macro & Markets',
        summary: 'Continuous timeline on central bank rate calibrations, sovereign debt yields, and labor market structural adjustments.',
        category: 'business',
        lastUpdated: now.subtract(const Duration(hours: 8)),
        isFollowing: false,
        checkpointIndex: 0,
        events: [
          ThreadEvent(
            id: 'econ-ev-1',
            timestamp: now.subtract(const Duration(days: 5)),
            headline: 'Core CPI Moderates Toward 2.1% Target Zone',
            summary: 'Services sector deceleration balances firming goods demand across major Atlantic and Pacific economies.',
            source: 'Bloomberg Economics',
            impact: 'Data Release',
          ),
          ThreadEvent(
            id: 'econ-ev-2',
            timestamp: now.subtract(const Duration(hours: 8)),
            headline: 'Central Bank Governors Signal Flexible Policy Neutrality',
            summary: 'Joint summit communiqués stress real-time data dependency rather than predetermined rate reduction timetables.',
            source: 'Financial Times Markets',
            impact: 'New Update • Today',
          ),
        ],
      ),
    ]);
  }
}
