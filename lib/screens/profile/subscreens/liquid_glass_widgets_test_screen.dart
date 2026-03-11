import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class LiquidGlassWidgetsTestScreen extends StatefulWidget {
  const LiquidGlassWidgetsTestScreen({super.key});

  @override
  State<LiquidGlassWidgetsTestScreen> createState() => _LiquidGlassWidgetsTestScreenState();
}

class _LiquidGlassWidgetsTestScreenState extends State<LiquidGlassWidgetsTestScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _HomePage(),
    _ContainersPage(),
    _InteractivePage(),
    _FeedbackPage(),
    _OverlaysPage(),
    _SurfacesPage(),
    _InputPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LiquidGlassScope.stack(
      background: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
              Color(0xFF1a1a2e),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
      ),
      content: Positioned.fill(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.back, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Liquid Glass Widgets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: GlassBottomBar(
            quality: GlassQuality.premium,
            indicatorColor: Colors.black26,
            tabs: [
              GlassBottomBarTab(
                label: 'Home',
                icon: CupertinoIcons.home,
                selectedIcon: CupertinoIcons.house_fill,
              ),
              GlassBottomBarTab(
                label: 'Containers',
                icon: CupertinoIcons.square_stack_3d_up,
                selectedIcon: CupertinoIcons.square_stack_3d_up_fill,
              ),
              GlassBottomBarTab(
                label: 'Interactive',
                icon: CupertinoIcons.hand_point_right,
                selectedIcon: CupertinoIcons.hand_point_right_fill,
              ),
              GlassBottomBarTab(
                label: 'Feedback',
                icon: CupertinoIcons.hourglass,
                selectedIcon: CupertinoIcons.hourglass,
              ),
              GlassBottomBarTab(
                label: 'Overlays',
                icon: CupertinoIcons.square_stack,
                selectedIcon: CupertinoIcons.square_stack_fill,
              ),
              GlassBottomBarTab(
                label: 'Surfaces',
                icon: CupertinoIcons.rectangle_3_offgrid,
                selectedIcon: CupertinoIcons.rectangle_3_offgrid_fill,
              ),
              GlassBottomBarTab(
                label: 'Input',
                icon: CupertinoIcons.keyboard,
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Home Page
// ---------------------------------------------------------------------------
class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return AdaptiveLiquidGlassLayer(
      quality: GlassQuality.standard,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Widget Showcase',
                      style: TextStyle(fontSize: 20, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 24),
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(CupertinoIcons.sparkles, color: Colors.white, size: 32),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Welcome', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                                    const SizedBox(height: 4),
                                    Text('Explore the glass widget collection', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'This showcase demonstrates Apple Liquid Glass widgets following Apple\'s design philosophy of composable primitives.',
                            style: TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Widget Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 16),
                    const _CategoryCard(icon: CupertinoIcons.square_stack_3d_up_fill, title: 'Containers', description: 'GlassCard, GlassPanel, and GlassContainer for content', color: Colors.purple),
                    const SizedBox(height: 12),
                    const _CategoryCard(icon: CupertinoIcons.hand_point_right_fill, title: 'Interactive', description: 'GlassButton, GlassSwitch, and GlassSegmentedControl', color: Colors.green),
                    const SizedBox(height: 12),
                    const _CategoryCard(icon: CupertinoIcons.hourglass, title: 'Feedback', description: 'GlassProgressIndicator for loading and progress', color: Colors.blue),
                    const SizedBox(height: 12),
                    const _CategoryCard(icon: CupertinoIcons.square_stack_fill, title: 'Overlays', description: 'GlassDialog, GlassSheet, and GlassActionSheet', color: Colors.cyan),
                    const SizedBox(height: 12),
                    const _CategoryCard(icon: CupertinoIcons.rectangle_3_offgrid_fill, title: 'Surfaces', description: 'GlassAppBar, GlassBottomBar, and GlassTabBar', color: Colors.orange),
                    const SizedBox(height: 12),
                    const _CategoryCard(icon: CupertinoIcons.keyboard, title: 'Input', description: 'GlassTextField, GlassSearchBar, and GlassPicker', color: Colors.pink),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.icon, required this.title, required this.description, required this.color});

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Containers Page
// ---------------------------------------------------------------------------
class _ContainersPage extends StatelessWidget {
  const _ContainersPage();

  @override
  Widget build(BuildContext context) {
    return AdaptiveLiquidGlassLayer(
      quality: GlassQuality.standard,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _PageHeader(title: 'Containers', subtitle: 'Foundation primitives for content layout'),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassContainer'),
                    const SizedBox(height: 12),
                    GlassContainer(
                      width: double.infinity,
                      height: 80,
                      child: const Center(child: Text('GlassContainer', style: TextStyle(color: Colors.white, fontSize: 16))),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassCard'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GlassCard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text('Elevated card with shadow for content grouping.', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassPanel'),
                    const SizedBox(height: 12),
                    GlassPanel(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GlassPanel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text('Larger surface for major UI sections.', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: GlassCard(
                                  padding: const EdgeInsets.all(12),
                                  child: const Center(child: Text('Nested Card 1', style: TextStyle(color: Colors.white, fontSize: 13))),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GlassCard(
                                  padding: const EdgeInsets.all(12),
                                  child: const Center(child: Text('Nested Card 2', style: TextStyle(color: Colors.white, fontSize: 13))),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interactive Page
// ---------------------------------------------------------------------------
class _InteractivePage extends StatefulWidget {
  const _InteractivePage();

  @override
  State<_InteractivePage> createState() => _InteractivePageState();
}

class _InteractivePageState extends State<_InteractivePage> {
  bool _switchValue = false;
  double _sliderValue = 0.5;
  int _segmentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLiquidGlassLayer(
      quality: GlassQuality.standard,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _PageHeader(title: 'Interactive', subtitle: 'User interaction components'),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassButton'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GlassButton(
                          icon: CupertinoIcons.star_fill,
                          label: 'Star',
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        GlassButton(
                          icon: CupertinoIcons.heart_fill,
                          label: 'Like',
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        GlassButton.custom(
                          onTap: () {},
                          width: 120,
                          height: 44,
                          child: const Text('Custom', style: TextStyle(color: Colors.white, fontSize: 15)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassIconButton'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GlassIconButton(
                          icon: CupertinoIcons.add,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 12),
                        GlassIconButton(
                          icon: CupertinoIcons.minus,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 12),
                        GlassIconButton(
                          icon: CupertinoIcons.share,
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassChip'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        GlassChip(label: 'Breakfast'),
                        GlassChip(label: 'Lunch', selected: true),
                        GlassChip(label: 'Dinner'),
                        GlassChip(label: 'Snack'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassSwitch'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Enable feature', style: TextStyle(color: Colors.white, fontSize: 16)),
                          GlassSwitch(
                            value: _switchValue,
                            onChanged: (v) => setState(() => _switchValue = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassSlider'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Value: ${(_sliderValue * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 16)),
                          const SizedBox(height: 12),
                          GlassSlider(
                            value: _sliderValue,
                            onChanged: (v) => setState(() => _sliderValue = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassSegmentedControl'),
                    const SizedBox(height: 12),
                    GlassSegmentedControl(
                      segments: const ['Day', 'Week', 'Month'],
                      selectedIndex: _segmentIndex,
                      onSegmentSelected: (i) => setState(() => _segmentIndex = i),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassBadge'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GlassBadge(
                          count: 3,
                          child: GlassButton(icon: CupertinoIcons.bell, onTap: () {}),
                        ),
                        const SizedBox(width: 16),
                        GlassBadge(
                          count: 12,
                          child: GlassButton(icon: CupertinoIcons.mail, onTap: () {}),
                        ),
                        const SizedBox(width: 16),
                        GlassBadge.dot(
                          child: GlassButton(icon: CupertinoIcons.chat_bubble, onTap: () {}),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feedback Page
// ---------------------------------------------------------------------------
class _FeedbackPage extends StatefulWidget {
  const _FeedbackPage();

  @override
  State<_FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<_FeedbackPage> {
  double _progress = 0.65;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLiquidGlassLayer(
      quality: GlassQuality.standard,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _PageHeader(title: 'Feedback', subtitle: 'Status and loading indicators'),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'Circular — Indeterminate'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              GlassProgressIndicator.circular(size: 14.0, strokeWidth: 2.0),
                              const SizedBox(height: 8),
                              const Text('Small', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          Column(
                            children: [
                              GlassProgressIndicator.circular(),
                              const SizedBox(height: 8),
                              const Text('Medium', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          Column(
                            children: [
                              GlassProgressIndicator.circular(size: 28.0, strokeWidth: 3.0),
                              const SizedBox(height: 8),
                              const Text('Large', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'Circular — Determinate'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GlassProgressIndicator.circular(value: 0.25, color: Colors.red),
                          GlassProgressIndicator.circular(value: 0.5, color: Colors.orange),
                          GlassProgressIndicator.circular(value: 0.75, color: Colors.blue),
                          GlassProgressIndicator.circular(value: 1.0, color: Colors.green),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'Linear — Indeterminate'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: GlassProgressIndicator.linear(),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'Linear — Determinate'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          GlassProgressIndicator.linear(value: _progress, color: _progress >= 1.0 ? Colors.green : Colors.blue),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${(_progress * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 16)),
                              Row(
                                children: [
                                  GlassButton(
                                    icon: CupertinoIcons.minus,
                                    onTap: () => setState(() => _progress = (_progress - 0.1).clamp(0.0, 1.0)),
                                    width: 40,
                                    height: 40,
                                  ),
                                  const SizedBox(width: 8),
                                  GlassButton(
                                    icon: CupertinoIcons.add,
                                    onTap: () => setState(() => _progress = (_progress + 0.1).clamp(0.0, 1.0)),
                                    width: 40,
                                    height: 40,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overlays Page
// ---------------------------------------------------------------------------
class _OverlaysPage extends StatelessWidget {
  const _OverlaysPage();

  @override
  Widget build(BuildContext context) {
    return AdaptiveLiquidGlassLayer(
      quality: GlassQuality.standard,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _PageHeader(title: 'Overlays', subtitle: 'Modal and floating UI'),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassDialog'),
                    const SizedBox(height: 12),
                    GlassButton.custom(
                      onTap: () {
                        GlassDialog.show(
                          context: context,
                          title: 'Confirm Action',
                          message: 'Are you sure you want to proceed?',
                          actions: [
                            GlassDialogAction(label: 'Cancel', onPressed: () => Navigator.pop(context)),
                            GlassDialogAction(label: 'OK', onPressed: () => Navigator.pop(context), isPrimary: true),
                          ],
                        );
                      },
                      width: 180,
                      height: 48,
                      child: const Text('Show Dialog', style: TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassSheet'),
                    const SizedBox(height: 12),
                    GlassButton.custom(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => GlassSheet(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const ListTile(
                                  leading: Icon(CupertinoIcons.photo, color: Colors.white),
                                  title: Text('Take Photo', style: TextStyle(color: Colors.white)),
                                ),
                                const ListTile(
                                  leading: Icon(CupertinoIcons.text_cursor, color: Colors.white),
                                  title: Text('Describe by Text', style: TextStyle(color: Colors.white)),
                                ),
                                const ListTile(
                                  leading: Icon(CupertinoIcons.mic, color: Colors.white),
                                  title: Text('Voice Input', style: TextStyle(color: Colors.white)),
                                ),
                                const ListTile(
                                  leading: Icon(CupertinoIcons.barcode, color: Colors.white),
                                  title: Text('Scan Barcode', style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        );
                      },
                      width: 220,
                      height: 48,
                      child: const Text('Show Bottom Sheet', style: TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassActionSheet'),
                    const SizedBox(height: 12),
                    GlassButton.custom(
                      onTap: () {
                        showGlassActionSheet(
                          context: context,
                          title: 'Choose Meal Type',
                          actions: [
                            GlassActionSheetAction(label: 'Breakfast', onPressed: () => Navigator.pop(context)),
                            GlassActionSheetAction(label: 'Lunch', onPressed: () => Navigator.pop(context)),
                            GlassActionSheetAction(label: 'Dinner', onPressed: () => Navigator.pop(context)),
                            GlassActionSheetAction(label: 'Snack', onPressed: () => Navigator.pop(context)),
                          ],
                          cancelLabel: 'Cancel',
                        );
                      },
                      width: 220,
                      height: 48,
                      child: const Text('Show Action Sheet', style: TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Surfaces Page
// ---------------------------------------------------------------------------
class _SurfacesPage extends StatefulWidget {
  const _SurfacesPage();

  @override
  State<_SurfacesPage> createState() => _SurfacesPageState();
}

class _SurfacesPageState extends State<_SurfacesPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLiquidGlassLayer(
      quality: GlassQuality.standard,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _PageHeader(title: 'Surfaces', subtitle: 'Navigation and app structure'),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassAppBar'),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 56,
                        child: GlassAppBar(
                          quality: GlassQuality.standard,
                          title: const Text('Glass App Bar', style: TextStyle(color: Colors.white)),
                          leading: const Icon(CupertinoIcons.back, color: Colors.white),
                          actions: [IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.ellipsis, color: Colors.white))],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassTabBar'),
                    const SizedBox(height: 12),
                    GlassTabBar(
                      tabs: const [
                        GlassTab(label: 'Overview'),
                        GlassTab(label: 'Details'),
                        GlassTab(label: 'Stats'),
                      ],
                      selectedIndex: _tabIndex,
                      onTabSelected: (i) => setState(() => _tabIndex = i),
                    ),
                    const SizedBox(height: 16),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'Tab ${_tabIndex + 1} content: ${['Overview', 'Details', 'Stats'][_tabIndex]}',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassToolbar'),
                    const SizedBox(height: 12),
                    GlassToolbar(
                      children: [
                        GlassIconButton(icon: CupertinoIcons.bold, onPressed: () {}),
                        GlassIconButton(icon: CupertinoIcons.italic, onPressed: () {}),
                        GlassIconButton(icon: CupertinoIcons.underline, onPressed: () {}),
                        GlassIconButton(icon: CupertinoIcons.text_alignleft, onPressed: () {}),
                        GlassIconButton(icon: CupertinoIcons.text_aligncenter, onPressed: () {}),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Input Page
// ---------------------------------------------------------------------------
class _InputPage extends StatelessWidget {
  const _InputPage();

  @override
  Widget build(BuildContext context) {
    return AdaptiveLiquidGlassLayer(
      quality: GlassQuality.standard,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _PageHeader(title: 'Input', subtitle: 'Text input components'),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassTextField'),
                    const SizedBox(height: 12),
                    GlassTextField(
                      placeholder: 'Enter food name...',
                      onChanged: (v) {},
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassTextArea'),
                    const SizedBox(height: 12),
                    GlassTextArea(
                      placeholder: 'Describe your meal in detail...',
                      onChanged: (v) {},
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassPasswordField'),
                    const SizedBox(height: 12),
                    GlassPasswordField(
                      placeholder: 'Enter password',
                      onChanged: (v) {},
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassSearchBar'),
                    const SizedBox(height: 12),
                    GlassSearchBar(
                      placeholder: 'Search foods...',
                      onChanged: (v) {},
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GlassPicker'),
                    const SizedBox(height: 12),
                    GlassPicker(
                      value: 'Breakfast',
                      placeholder: 'Select meal type',
                      onTap: () {},
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------
class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white));
  }
}
