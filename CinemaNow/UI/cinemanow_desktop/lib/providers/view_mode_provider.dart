import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/models/view_mode.dart';
import 'package:cinemanow_desktop/providers/base_provider.dart';

class ViewModeProvider extends BaseProvider<ViewMode> {
  ViewModeProvider() : super("ViewMode");

  @override
  ViewMode fromJson(data) {
    return ViewMode.fromJson(data);
  }

  Future<SearchResult<ViewMode>> getViewModes({dynamic filter}) async {
    return await get(filter: filter);
  }

  Future<void> deleteViewMode(int id) async {
    await delete(id);
  }
}