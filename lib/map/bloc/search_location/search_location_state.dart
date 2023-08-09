part of 'search_location_cubit.dart';

class SearchLocationInitial extends Equatable {
  final CubitStatuses statuses;
  final List<SearchLocationResult> result;
  final String error;
  final String request;

  const SearchLocationInitial({
    required this.statuses,
    required this.result,
    required this.error,
    required this.request,
  });

  factory SearchLocationInitial.initial() {
    return const SearchLocationInitial(
      result: [],
      error: '',
      request: '',
      statuses: CubitStatuses.init,
    );
  }

  @override
  List<Object> get props => [statuses, result, error];

  SearchLocationInitial copyWith({
    CubitStatuses? statuses,
    List<SearchLocationResult>? result,
    String? error,
    String? request,
  }) {
    return SearchLocationInitial(
      statuses: statuses ?? this.statuses,
      result: result ?? this.result,
      error: error ?? this.error,
      request: request ?? this.request,
    );
  }
}
