// lib/screens/voice_hub_screen.dart
// ══════════════════════════════════════════════════════════════
// SYNAP — Voice Hub Screen
// Hindi + English + Hinglish voice support
// speech_to_text package use kar raha hai
// ══════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/tracker/tracker_bloc.dart';
import '../blocs/tracker/tracker_event.dart';

// ── Tool result model ─────────────────────────────────────────
class ToolResult {
  final String name;
  final String emoji;
  final String description;
  final String category;
  final bool isFree;
  final String url;
  const ToolResult({
    required this.name, required this.emoji,
    required this.description, required this.category,
    required this.isFree, required this.url,
  });
}

// ── Knowledge base ────────────────────────────────────────────
class VoiceKB {
  static String getResponse(String query) {
    final q = query.toLowerCase();
    if (_matches(q, ['video','edit','banao','banaun','reels','shorts','clip'])) {
      return 'Video editing ke liye yeh free tools best hain:';
    }
    if (_matches(q, ['image','photo','picture','tasveer','generate','banana','draw','design'])) {
      return 'Free image generation ke liye yeh tools try karo:';
    }
    if (_matches(q, ['code','coding','program','developer','script','develop'])) {
      return 'Coding ke liye yeh best free AI tools hain:';
    }
    if (_matches(q, ['music','song','audio','gana','beat','sound'])) {
      return 'Free music generation ke liye:';
    }
    if (_matches(q, ['chatgpt','gpt','alternative','replace','jaisa','jaisi'])) {
      return 'ChatGPT ke best free alternatives:';
    }
    if (_matches(q, ['resume','cv','job','interview','naukri'])) {
      return 'Resume aur job applications ke liye:';
    }
    if (_matches(q, ['write','writing','likhna','content','blog','article'])) {
      return 'Writing ke liye best free AI tools:';
    }
    if (_matches(q, ['present','presentation','slides','deck'])) {
      return 'Presentations banane ke liye:';
    }
    if (_matches(q, ['search','find','dhundh','research','information'])) {
      return 'Research aur search ke liye:';
    }
    if (_matches(q, ['voice','speech','tts','text to speech','bolna'])) {
      return 'Voice aur text-to-speech ke liye:';
    }
    return 'Yeh popular free AI tools hain jo help kar sakte hain:';
  }

  static List<ToolResult> getTools(String query) {
    final q = query.toLowerCase();
    if (_matches(q, ['video','edit','reels','shorts','clip','banao'])) {
      return _videoTools;
    }
    if (_matches(q, ['image','photo','picture','tasveer','generate','draw','design'])) {
      return _imageTools;
    }
    if (_matches(q, ['code','coding','program','developer','script'])) {
      return _codeTools;
    }
    if (_matches(q, ['music','song','audio','gana','beat'])) {
      return _musicTools;
    }
    if (_matches(q, ['chatgpt','gpt','alternative','replace'])) {
      return _chatTools;
    }
    if (_matches(q, ['resume','cv','job','naukri'])) {
      return _resumeTools;
    }
    if (_matches(q, ['write','writing','likhna','content','blog'])) {
      return _writingTools;
    }
    if (_matches(q, ['present','presentation','slides'])) {
      return _presentationTools;
    }
    if (_matches(q, ['search','find','dhundh','research'])) {
      return _searchTools;
    }
    if (_matches(q, ['voice','speech','tts','bolna'])) {
      return _voiceTools;
    }
    return _defaultTools;
  }

  static bool _matches(String q, List<String> keywords) =>
      keywords.any((k) => q.contains(k));

  // ── Tool lists ──────────────────────────────────────────────
  static const _videoTools = [
    ToolResult(name:'CapCut AI',    emoji:'✂️', isFree:true,  category:'Video', url:'capcut.com',    description:'Free AI video editing, auto-captions, effects. Best for Reels & Shorts.'),
    ToolResult(name:'Runway Gen-3', emoji:'🎬', isFree:false, category:'Video', url:'runwayml.com',  description:'125 free credits/month. AI video generation from text.'),
    ToolResult(name:'Pika Labs',    emoji:'🎞️', isFree:false, category:'Video', url:'pika.art',      description:'250 free credits. Text to video, easy to use.'),
  ];

  static const _imageTools = [
    ToolResult(name:'Ideogram',        emoji:'🎨', isFree:true,  category:'Image', url:'ideogram.ai',     description:'Unlimited free images with perfect text rendering.'),
    ToolResult(name:'Adobe Firefly',   emoji:'🔥', isFree:false, category:'Image', url:'firefly.adobe.com',description:'25 free credits/month. Commercially safe AI images.'),
    ToolResult(name:'Microsoft Designer',emoji:'💎',isFree:true, category:'Image', url:'designer.microsoft.com',description:'Free AI image generation using DALL-E 3.'),
  ];

  static const _codeTools = [
    ToolResult(name:'Cursor AI',       emoji:'⌨️', isFree:false, category:'Code', url:'cursor.sh',       description:'2000 free completions/month. Best AI code editor available.'),
    ToolResult(name:'GitHub Copilot',  emoji:'🐙', isFree:false, category:'Code', url:'github.com',      description:'Free for students. AI code completion in VS Code and more.'),
    ToolResult(name:'Replit AI',       emoji:'💻', isFree:true,  category:'Code', url:'replit.com',      description:'Free AI coding assistant with cloud IDE. No setup needed.'),
  ];

  static const _musicTools = [
    ToolResult(name:'Suno AI',    emoji:'🎵', isFree:false, category:'Audio', url:'suno.com',     description:'50 free credits/day. Create full songs with lyrics from text.'),
    ToolResult(name:'Udio',       emoji:'🎶', isFree:false, category:'Audio', url:'udio.com',     description:'1200 free credits/month. High quality AI music generation.'),
    ToolResult(name:'Soundraw',   emoji:'🎸', isFree:false, category:'Audio', url:'soundraw.io',  description:'5 free songs/day. Royalty-free background music.'),
  ];

  static const _chatTools = [
    ToolResult(name:'Claude',      emoji:'✦',  isFree:false, category:'Chat', url:'claude.ai',         description:'40 free messages/day. Best for long documents and analysis.'),
    ToolResult(name:'Gemini',      emoji:'♊',  isFree:true,  category:'Chat', url:'gemini.google.com', description:'60 free queries/day. Google integrated, great for research.'),
    ToolResult(name:'Perplexity',  emoji:'🔍', isFree:false, category:'Search',url:'perplexity.ai',    description:'5 Pro searches/day free. Best AI-powered search engine.'),
  ];

  static const _resumeTools = [
    ToolResult(name:'Kickresume',  emoji:'📄', isFree:false, category:'Career', url:'kickresume.com',  description:'Free AI resume builder. ATS-optimized templates.'),
    ToolResult(name:'Resume.io',   emoji:'📋', isFree:false, category:'Career', url:'resume.io',       description:'AI suggestions for better resume writing.'),
    ToolResult(name:'ChatGPT',     emoji:'🤖', isFree:false, category:'Chat',   url:'chat.openai.com', description:'Paste your resume, ask for improvements. Free tier: 40 msgs/3h.'),
  ];

  static const _writingTools = [
    ToolResult(name:'Claude',      emoji:'✦',  isFree:false, category:'Writing', url:'claude.ai',       description:'Best for long-form writing. 40 free messages daily.'),
    ToolResult(name:'Writesonic',  emoji:'✍️', isFree:false, category:'Writing', url:'writesonic.com',  description:'Free tier available. Blog posts, ads, social media copy.'),
    ToolResult(name:'Copy.ai',     emoji:'📝', isFree:false, category:'Writing', url:'copy.ai',         description:'2000 words free/month. Marketing copy and content.'),
  ];

  static const _presentationTools = [
    ToolResult(name:'Gamma',       emoji:'📊', isFree:false, category:'Slides', url:'gamma.app',       description:'10 free credits/month. AI presentations in seconds.'),
    ToolResult(name:'Canva AI',    emoji:'🎨', isFree:true,  category:'Design', url:'canva.com',       description:'Free AI presentation templates and design tools.'),
    ToolResult(name:'Beautiful.ai',emoji:'✨', isFree:false, category:'Slides', url:'beautiful.ai',    description:'Smart slide templates that design themselves.'),
  ];

  static const _searchTools = [
    ToolResult(name:'Perplexity',  emoji:'🔍', isFree:false, category:'Search', url:'perplexity.ai',   description:'5 Pro searches/day. Cites sources, accurate answers.'),
    ToolResult(name:'Gemini',      emoji:'♊',  isFree:true,  category:'Search', url:'gemini.google.com',description:'Google-powered AI search. 60 queries/day free.'),
    ToolResult(name:'You.com',     emoji:'🌐', isFree:true,  category:'Search', url:'you.com',         description:'Free unlimited AI search with source citations.'),
  ];

  static const _voiceTools = [
    ToolResult(name:'ElevenLabs',  emoji:'🎙️', isFree:false, category:'Voice', url:'elevenlabs.io',   description:'10,000 free characters/month. Most realistic AI voices.'),
    ToolResult(name:'Murf AI',     emoji:'🔊', isFree:false, category:'Voice', url:'murf.ai',         description:'10 mins free voice generation. 120+ AI voices.'),
    ToolResult(name:'PlayHT',      emoji:'📢', isFree:false, category:'Voice', url:'play.ht',         description:'12,500 free characters/month. Voice cloning available.'),
  ];

  static const _defaultTools = [
    ToolResult(name:'ChatGPT',     emoji:'🤖', isFree:false, category:'Chat',  url:'chat.openai.com', description:'40 messages/3h on GPT-4o. Best all-rounder AI assistant.'),
    ToolResult(name:'Claude',      emoji:'✦',  isFree:false, category:'Chat',  url:'claude.ai',       description:'40 messages/day. Excellent for writing and analysis.'),
    ToolResult(name:'Gemini',      emoji:'♊',  isFree:true,  category:'Chat',  url:'gemini.google.com',description:'60 queries/day free. Google integrated AI assistant.'),
  ];

  // ── Track command parser ────────────────────────────────────
  static Map<String, dynamic>? parseTrackCommand(String text) {
    final t = text.toLowerCase();
    String? toolId;
    if (t.contains('chatgpt') || t.contains('gpt'))    toolId = 'chatgpt_gpt4o';
    if (t.contains('claude'))                           toolId = 'claude';
    if (t.contains('gemini'))                           toolId = 'gemini';
    if (t.contains('perplexity'))                       toolId = 'perplexity';
    if (t.contains('suno'))                             toolId = 'suno';
    if (t.contains('midjourney'))                       toolId = 'midjourney';
    if (t.contains('cursor'))                           toolId = 'cursor';
    if (toolId == null) return null;

    final numMatch = RegExp(r'\d+').firstMatch(t);
    final count    = numMatch != null ? int.parse(numMatch.group(0)!) : 1;

    // Reset command
    final isReset = t.contains('reset') || t.contains('clear') ||
                    t.contains('zero')  || t.contains('shuru');

    return {'toolId': toolId, 'count': count, 'isReset': isReset};
  }
}

// ══════════════════════════════════════════════════════════════
// VOICE HUB SCREEN
// ══════════════════════════════════════════════════════════════
enum _VoiceState { idle, listening, thinking, done }

class VoiceHubScreen extends StatefulWidget {
  const VoiceHubScreen({super.key});
  @override State<VoiceHubScreen> createState() => _VoiceHubScreenState();
}

class _VoiceHubScreenState extends State<VoiceHubScreen>
    with TickerProviderStateMixin {

  // ── Speech ─────────────────────────────────────────────────
  final SpeechToText _speech = SpeechToText();
  bool   _speechAvailable = false;
  bool   _isListening      = false;
  String _transcript       = '';
  String _partialText      = '';

  // ── State ──────────────────────────────────────────────────
  _VoiceState _state = _VoiceState.idle;

  String            _aiResponse = '';
  List<ToolResult>  _results    = [];
  String            _mode       = 'search'; // search | track

  // ── Animations ─────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late AnimationController _waveCtrl;
  late AnimationController _resultCtrl;
  late AnimationController _ringCtrl;

  // ── Suggestion chips ───────────────────────────────────────
  final _chips = [
    'Free image banao',
    'ChatGPT alternative',
    'Code karne ke liye',
    'Video editing free',
    'Music banana free',
    'Resume likhna hai',
    'Presentation banana',
    'Research karna hai',
  ];

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _waveCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );

    _resultCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    );

    _ringCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    );

    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError:  (e) => _onSpeechError(e.errorMsg),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _resultCtrl.dispose();
    _ringCtrl.dispose();
    _speech.stop();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════
  // SPEECH LOGIC
  // ══════════════════════════════════════════════════════════
  Future<void> _toggleMic() async {
    if (_isListening) {
      await _speech.stop();
      return;
    }

    if (!_speechAvailable) {
      _showToast('Microphone permission do Settings mein');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _state       = _VoiceState.listening;
      _isListening = true;
      _transcript  = '';
      _partialText = '';
      _results     = [];
      _aiResponse  = '';
    });

    _ringCtrl.repeat();
    _waveCtrl.repeat(reverse: true);

    await _speech.listen(
      onResult:          _onResult,
      listenFor:         const Duration(seconds: 10),
      pauseFor:          const Duration(seconds: 2),
      // Hindi + English dono support
      localeId:          'hi_IN',
      onSoundLevelChange: (level) {
        // Wave animation speed change based on sound level
        if (mounted) setState(() {});
      },
    );
  }

  void _onResult(SpeechRecognitionResult result) {
    setState(() {
      _partialText = result.recognizedWords;
      if (result.finalResult) {
        _transcript  = result.recognizedWords;
        _isListening = false;
        _ringCtrl.stop();
        _waveCtrl.stop();
        if (_transcript.trim().isNotEmpty) {
          _processQuery(_transcript);
        } else {
          _setState(_VoiceState.idle);
        }
      }
    });
  }

  void _onSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      if (_isListening && _partialText.isNotEmpty) {
        _transcript  = _partialText;
        _isListening = false;
        _ringCtrl.stop();
        _waveCtrl.stop();
        _processQuery(_transcript);
      } else if (_isListening) {
        setState(() {
          _isListening = false;
          _state = _VoiceState.idle;
        });
        _ringCtrl.stop();
        _waveCtrl.stop();
      }
    }
  }

  void _onSpeechError(String error) {
    setState(() {
      _isListening = false;
      _state = _VoiceState.idle;
    });
    _ringCtrl.stop();
    _waveCtrl.stop();
    if (error != 'error_speech_timeout') {
      _showToast('Dobara try karo — $error');
    }
  }

  // ══════════════════════════════════════════════════════════
  // PROCESS QUERY
  // ══════════════════════════════════════════════════════════
  void _processQuery(String text) async {
    if (text.trim().isEmpty) return;

    _setState(_VoiceState.thinking);
    HapticFeedback.lightImpact();

    // Simulate AI thinking delay (300ms feels natural)
    await Future.delayed(const Duration(milliseconds: 350));

    if (_mode == 'track') {
      _handleTrackCommand(text);
    } else {
      _handleSearch(text);
    }
  }

  void _handleSearch(String text) {
    final response = VoiceKB.getResponse(text);
    final tools    = VoiceKB.getTools(text);

    setState(() {
      _aiResponse = response;
      _results    = tools;
      _state      = _VoiceState.done;
    });

    _resultCtrl.forward(from: 0);
    HapticFeedback.lightImpact();
  }

  void _handleTrackCommand(String text) {
    final cmd = VoiceKB.parseTrackCommand(text);

    if (cmd == null) {
      setState(() {
        _aiResponse = 'Konsa tool track karna hai? Jaise: "ChatGPT ke 5 messages use kiye"';
        _results    = [];
        _state      = _VoiceState.done;
      });
      return;
    }

    final toolId = cmd['toolId'] as String;
    final count  = cmd['count']  as int;
    final isReset = cmd['isReset'] as bool;

    if (isReset) {
      context.read<TrackerBloc>().add(TrackerManualReset(toolId));
      setState(() {
        _aiResponse = '✅ $toolId reset ho gaya!';
        _results    = [];
        _state      = _VoiceState.done;
      });
    } else {
      context.read<TrackerBloc>().add(
        TrackerUsageLogged(toolId, count: count));
      setState(() {
        _aiResponse = '📊 $count ${_unitFor(toolId)} logged for ${_nameFor(toolId)}';
        _results    = [];
        _state      = _VoiceState.done;
      });
    }
    _resultCtrl.forward(from: 0);
    HapticFeedback.lightImpact();
  }

  // ── Try chip ─────────────────────────────────────────────
  void _tryChip(String text) {
    setState(() {
      _transcript  = text;
      _partialText = text;
    });
    _processQuery(text);
  }

  void _setState(_VoiceState s) {
    setState(() => _state = s);
  }

  // ── Helpers ──────────────────────────────────────────────
  String _unitFor(String toolId) {
    switch (toolId) {
      case 'midjourney': return 'images';
      case 'suno':       return 'credits';
      default:           return 'messages';
    }
  }

  String _nameFor(String toolId) {
    final map = {
      'chatgpt_gpt4o': 'ChatGPT',
      'claude':        'Claude',
      'gemini':        'Gemini',
      'perplexity':    'Perplexity',
      'suno':          'Suno',
      'midjourney':    'Midjourney',
      'cursor':        'Cursor',
    };
    return map[toolId] ?? toolId;
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
        style: const TextStyle(fontFamily: 'DM Sans')),
      backgroundColor: const Color(0xFF0C1019),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05080F),
      body: SafeArea(
        child: Column(children: [
          _buildTopBar(),
          Expanded(child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(children: [
              _buildModePills(),
              _buildMicStage(),
              _buildStatusLabel(),
              _buildTranscriptArea(),
              if (_state == _VoiceState.done) _buildResults(),
              if (_state == _VoiceState.idle ||
                  _state == _VoiceState.done)
                _buildChips(),
            ]),
          )),
        ]),
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────────
  Widget _buildTopBar() => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
    child: Row(children: [
      IconButton(
        icon: const Icon(Icons.arrow_back_ios,
          color: Color(0xFF3A4A60), size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      // Synap logo inline SVG feel — just text logo
      const Text('Voice Hub',
        style: TextStyle(fontFamily: 'Syne', fontSize: 18,
          fontWeight: FontWeight.w800, color: Colors.white,
          letterSpacing: -0.5)),
      const Spacer(),
      // Language indicator
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF00C8E8).withValues(alpha: 0.08),
          border: Border.all(
            color: const Color(0xFF00C8E8).withValues(alpha: 0.2)),
        ),
        child: const Text('HI + EN',
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 10,
            color: Color(0xFF00C8E8), fontWeight: FontWeight.w600,
            letterSpacing: 0.5)),
      ),
    ]),
  );

  // ── MODE PILLS ───────────────────────────────────────────
  Widget _buildModePills() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Row(children: [
      _ModePill(
        icon: '🔍', label: 'Find Tool',
        active: _mode == 'search',
        onTap: () => setState(() {
          _mode = 'search';
          _results = []; _aiResponse = '';
          _state = _VoiceState.idle;
        }),
      ),
      const SizedBox(width: 10),
      _ModePill(
        icon: '📊', label: 'Log Usage',
        active: _mode == 'track',
        onTap: () => setState(() {
          _mode = 'track';
          _results = []; _aiResponse = '';
          _state = _VoiceState.idle;
        }),
      ),
    ]),
  );

  // ── MIC STAGE ────────────────────────────────────────────
  Widget _buildMicStage() => SizedBox(
    height: 260,
    child: Stack(alignment: Alignment.center, children: [
      // Animated rings
      AnimatedBuilder(
        animation: _ringCtrl,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [1.0, 1.4, 1.8, 2.2].asMap().entries.map((e) {
            final delay  = e.key * 0.25;
            final t      = (_ringCtrl.value - delay).clamp(0.0, 1.0);
            final scale  = _isListening ? 1.0 + t * 0.5 : 1.0;
            final opacity = _isListening
                ? (1 - t) * (e.key == 0 ? 0.5 : e.key == 1 ? 0.3 : e.key == 2 ? 0.15 : 0.07)
                : 0.06 - e.key * 0.01;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 96.0 + e.key * 30,
                height: 96.0 + e.key * 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00C8E8)
                        .withValues(alpha: opacity.clamp(0, 1)),
                    width: 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),

      // Main mic button
      GestureDetector(
        onTap: _toggleMic,
        child: AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) {
            final isActive = _isListening ||
                _state == _VoiceState.thinking;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: isActive ? 90 : 80,
              height: isActive ? 90 : 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? const Color(0xFF00C8E8)
                    : const Color(0xFF0C1019),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF00C8E8)
                      : const Color(0xFF00C8E8).withValues(alpha: 
                          0.25 + 0.15 * _pulseCtrl.value),
                  width: 1.5,
                ),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF00C8E8).withValues(alpha: 
                    isActive
                        ? 0.3 + 0.15 * _pulseCtrl.value
                        : 0.08 + 0.06 * _pulseCtrl.value),
                  blurRadius: isActive ? 30 : 20,
                  spreadRadius: isActive ? 4 : 0,
                )],
              ),
              child: _state == _VoiceState.thinking
                  ? const _ThinkingDots()
                  : Icon(
                      _isListening ? Icons.mic : Icons.mic_none_rounded,
                      color: isActive
                          ? const Color(0xFF05080F)
                          : const Color(0xFF00C8E8),
                      size: 32,
                    ),
            );
          },
        ),
      ),

      // Waveform bars (visible when listening)
      if (_isListening)
        Positioned(
          bottom: 20,
          child: AnimatedBuilder(
            animation: _waveCtrl,
            builder: (_, __) => _WaveformBars(value: _waveCtrl.value),
          ),
        ),
    ]),
  );

  // ── STATUS LABEL ─────────────────────────────────────────
  Widget _buildStatusLabel() {
    String text = '';
    Color color = Colors.transparent;
    switch (_state) {
      case _VoiceState.idle:
        text  = _speechAvailable
            ? 'Mic tap karo — Hindi ya English mein bolo'
            : 'Microphone permission required';
        color = const Color(0xFF3A4A60);
        break;
      case _VoiceState.listening:
        text  = 'Sun raha hoon...';
        color = const Color(0xFF00C8E8);
        break;
      case _VoiceState.thinking:
        text  = 'Soch raha hoon...';
        color = const Color(0xFFF5A623);
        break;
      case _VoiceState.done:
        text  = 'Yeh raha jawab 👇';
        color = const Color(0xFF00D68F);
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Padding(
        key: ValueKey(text),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_state != _VoiceState.idle)
              Container(
                width: 7, height: 7,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: color,
                  boxShadow: [BoxShadow(
                    color: color.withValues(alpha: 0.5), blurRadius: 6)],
                ),
              ),
            Text(text, style: TextStyle(fontFamily: 'DM Sans',
              fontSize: 13, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ── TRANSCRIPT AREA ───────────────────────────────────────
  Widget _buildTranscriptArea() {
    final display = _partialText.isNotEmpty
        ? _partialText : _transcript;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      padding: const EdgeInsets.all(14),
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF090D16),
        border: Border.all(
          color: _isListening
              ? const Color(0xFF00C8E8).withValues(alpha: 0.3)
              : const Color(0xFF131B27)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('"', style: TextStyle(fontFamily: 'Syne',
            fontSize: 28, height: 0.8,
            color: const Color(0xFF131B27))),
          const SizedBox(width: 4),
          Expanded(child: display.isEmpty
              ? Text(
                  _mode == 'track'
                      ? 'E.g. "ChatGPT ke 10 messages use kiye"'
                      : 'E.g. "Free mein video edit karna hai"',
                  style: const TextStyle(fontFamily: 'DM Sans',
                    fontSize: 13, color: Color(0xFF2E3E54)),
                )
              : Text(display,
                  style: const TextStyle(fontFamily: 'DM Sans',
                    fontSize: 14, color: Colors.white, height: 1.5)),
          ),
          if (_isListening)
            const _CursorBlink(),
        ],
      ),
    );
  }

  // ── AI RESULTS ───────────────────────────────────────────
  Widget _buildResults() => AnimatedBuilder(
    animation: _resultCtrl,
    builder: (_, __) {
      final v = Curves.easeOutCubic.transform(_resultCtrl.value);
      return Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - v)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Synap AI label
                Row(children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: const Color(0xFF090D16),
                      border: Border.all(
                        color: const Color(0xFF00C8E8).withValues(alpha: 0.3)),
                    ),
                    child: const Center(
                      child: Text('S', style: TextStyle(
                        fontFamily: 'Syne', fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00C8E8)))),
                  ),
                  const SizedBox(width: 8),
                  const Text('Synap AI',
                    style: TextStyle(fontFamily: 'DM Sans',
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: Color(0xFF00C8E8),
                      letterSpacing: 0.5)),
                ]),
                const SizedBox(height: 10),

                // Response text
                Text(_aiResponse,
                  style: const TextStyle(fontFamily: 'DM Sans',
                    fontSize: 14, color: Colors.white, height: 1.6)),

                if (_results.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ..._results.asMap().entries.map((e) =>
                    TweenAnimationBuilder<double>(
                      duration: Duration(
                        milliseconds: 300 + e.key * 80),
                      tween: Tween(begin: 0, end: 1),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, child) => Transform.translate(
                        offset: Offset(0, 14 * (1 - v)),
                        child: Opacity(
                          opacity: v.clamp(0, 1), child: child),
                      ),
                      child: _ToolCard(tool: e.value),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );

  // ── SUGGESTION CHIPS ─────────────────────────────────────
  Widget _buildChips() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Text('Try karo',
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.25),
            letterSpacing: 0.8)),
      ),
      SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => _tryChip(_chips[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF090D16),
                border: Border.all(color: const Color(0xFF131B27)),
              ),
              child: Text(_chips[i], style: const TextStyle(
                fontFamily: 'DM Sans', fontSize: 12,
                color: Color(0xFF7A8FA8), fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════
// SUB WIDGETS
// ══════════════════════════════════════════════════════════════

class _ModePill extends StatelessWidget {
  final String icon, label;
  final bool active;
  final VoidCallback onTap;
  const _ModePill({
    required this.icon, required this.label,
    required this.active, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: active
              ? const Color(0xFF00C8E8).withValues(alpha: 0.08)
              : const Color(0xFF090D16),
          border: Border.all(
            color: active
                ? const Color(0xFF00C8E8).withValues(alpha: 0.3)
                : const Color(0xFF131B27)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(
              fontFamily: 'Syne', fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active
                  ? const Color(0xFF00C8E8)
                  : const Color(0xFF3A4A60))),
          ],
        ),
      ),
    ),
  );
}

class _WaveformBars extends StatelessWidget {
  final double value;
  const _WaveformBars({required this.value});

  @override
  Widget build(BuildContext context) {
    final heights = [8.0, 16, 24, 32, 38, 30, 22, 14, 8, 18, 28, 36, 26, 16, 8];
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: heights.asMap().entries.map((e) {
        final phase = (value + e.key * 0.07) % 1.0;
        final h = e.value * (0.4 + 0.6 * sin(phase * pi));
        return Container(
          width: 3, height: h,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: const Color(0xFF00C8E8).withValues(alpha: 0.7),
          ),
        );
      }).toList(),
    );
  }
}

class _ThinkingDots extends StatefulWidget {
  const _ThinkingDots();
  @override State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 900))..repeat();
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = (_c.value - i * 0.15).clamp(0.0, 1.0);
          final opacity = (sin(t * pi).clamp(0.2, 1.0));
          return Container(
            width: 6, height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF05080F).withValues(alpha: opacity),
            ),
          );
        }),
      ),
    );
  }
}

class _CursorBlink extends StatefulWidget {
  const _CursorBlink();
  @override State<_CursorBlink> createState() => _CursorBlinkState();
}

class _CursorBlinkState extends State<_CursorBlink>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 600))..repeat(reverse: true);
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Opacity(
      opacity: _c.value,
      child: Container(
        width: 2, height: 16, margin: const EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          color: const Color(0xFF00C8E8)),
      ),
    ),
  );
}

class _ToolCard extends StatelessWidget {
  final ToolResult tool;
  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: const Color(0xFF0C1019),
      border: Border.all(color: const Color(0xFF131B27)),
    ),
    child: Row(children: [
      Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF090D16),
          border: Border.all(color: const Color(0xFF1A2336)),
        ),
        child: Center(child: Text(tool.emoji,
          style: const TextStyle(fontSize: 22))),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tool.name, style: const TextStyle(
            fontFamily: 'Syne', fontSize: 14,
            fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 3),
          Text(tool.description, style: const TextStyle(
            fontFamily: 'DM Sans', fontSize: 11,
            color: Color(0xFF7A8FA8), height: 1.4),
            maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: tool.isFree
                    ? const Color(0xFF00D68F).withValues(alpha: 0.1)
                    : const Color(0xFF00C8E8).withValues(alpha: 0.08),
                border: Border.all(
                  color: tool.isFree
                      ? const Color(0xFF00D68F).withValues(alpha: 0.25)
                      : const Color(0xFF00C8E8).withValues(alpha: 0.2)),
              ),
              child: Text(
                tool.isFree ? 'FREE' : 'FREE TIER',
                style: TextStyle(fontFamily: 'DM Sans', fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: tool.isFree
                      ? const Color(0xFF00D68F)
                      : const Color(0xFF00C8E8),
                  letterSpacing: 0.4)),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: const Color(0xFF131B27),
              ),
              child: Text(tool.category, style: const TextStyle(
                fontFamily: 'DM Sans', fontSize: 9,
                color: Color(0xFF3A4A60),
                fontWeight: FontWeight.w600)),
            ),
          ]),
        ],
      )),
      const Icon(Icons.arrow_forward_ios,
        color: Color(0xFF2E3E54), size: 12),
    ]),
  );
}
