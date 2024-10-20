import 'package:cinemanow_desktop/models/screening.dart';
import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/providers/screening_provider.dart';
import 'package:cinemanow_desktop/screens/add_edit_screening_screen.dart';
import 'package:cinemanow_desktop/widgets/date_picker.dart';
import 'package:cinemanow_desktop/widgets/screening_card.dart';
import 'package:cinemanow_desktop/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ScreeningListScreen extends StatefulWidget {
  const ScreeningListScreen({super.key});

  @override
  _ScreeningListScreenState createState() => _ScreeningListScreenState();
}

class _ScreeningListScreenState extends State<ScreeningListScreen>
    with SingleTickerProviderStateMixin {
  late ScreeningProvider provider;
  SearchResult<Screening>? result;
  final TextEditingController _ftsEditingController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchScreenings();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchScreenings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchScreenings({String? fts, DateTime? date}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<ScreeningProvider>();
      result = await provider.getScreenings(fts: fts, date: date);
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSearch(),
                const SizedBox(height: 16),
                _buildTabBar(),
                const SizedBox(height: 16),
                _isLoading
                    ? const Expanded(
                        child: Center(
                            child: CircularProgressIndicator(
                        color: Colors.red,
                      )))
                    : _buildResultView(),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                final resultIndex = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddEditScreeningScreen(
                      onScreeningAdded: _fetchScreenings,
                      onScreeningUpdated: _fetchScreenings,
                      currentTabIndex: _tabController.index,
                    ),
                  ),
                );

                if (resultIndex != null && resultIndex is int) {
                  _tabController.animateTo(resultIndex);
                }
              },
              backgroundColor: Colors.grey[850],
              child: Icon(
                Icons.add,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.red,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey[500],
      tabs: const [
        Tab(text: 'Active'),
        Tab(text: 'Hidden'),
        Tab(text: 'Draft'),
      ],
      onTap: (index) {
        setState(() {});
      },
    );
  }

  Widget _buildSearch() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Expanded(
                  child: TextSelectionTheme(
                    data: const TextSelectionThemeData(
                      selectionColor: Colors.red,
                    ),
                    child: TextField(
                      controller: _ftsEditingController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                      ),
                      cursorColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DatePicker(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            await _fetchScreenings(
              fts: _ftsEditingController.text,
              date: _selectedDate,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[850],
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            minimumSize: const Size(0, 55),
          ),
          child: Text(
            'Search',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    final List<Screening> filteredScreenings =
        result?.result.where((screening) {
              switch (_tabController.index) {
                case 0:
                  return screening.stateMachine == 'active';
                case 1:
                  return screening.stateMachine == 'hidden';
                case 2:
                  return screening.stateMachine == 'draft';
                default:
                  return false;
              }
            }).toList() ??
            [];

    if (filteredScreenings.isEmpty) {
      return Expanded(child: Center(child: _buildNoScreeningsView()));
    }

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          if (constraints.maxWidth > 1200) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth > 800) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 1;
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1,
            ),
            itemCount: filteredScreenings.length,
            itemBuilder: (context, index) {
              final screening = filteredScreenings[index];
              String? imageUrl = screening.movie?.imageBase64;
              return ScreeningCard(
                imageUrl: imageUrl != null
                    ? 'data:image/jpeg;base64,$imageUrl'
                    : 'assets/images/default.jpg',
                title: screening.movie?.title ?? 'Unknown Title',
                date: screening.dateTime != null
                    ? DateFormat('dd/MM/yyyy').format(screening.dateTime!)
                    : 'Unknown Date',
                time: screening.dateTime != null
                    ? DateFormat('HH:mm').format(screening.dateTime!)
                    : 'Unknown Time',
                hall: screening.hall?.name ?? 'Unknown Hall',
                viewMode: screening.viewMode?.name ?? 'Unknown View Mode',
                price: screening.price != null
                    ? formatNumber(screening.price)
                    : 'Unknown Price',
                screeningId: screening.id ?? 0,
                onDelete: _fetchScreenings,
                onScreeningUpdated: _fetchScreenings,
                stateMachine: screening.stateMachine ?? 'unknown',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNoScreeningsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            'No Screenings Available',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different date or search term.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
