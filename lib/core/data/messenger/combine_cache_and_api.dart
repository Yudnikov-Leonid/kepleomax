import 'package:kepleomax/core/app_constants.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';

class CombineCacheAndApi {
  Iterable<MessageDto> combineLoad(
    List<MessageDto> cache,
    List<MessageDto> api, {
    int limit = AppConstants.msgPagingLimit,
  }) {
    final firstIndex = cache.indexWhere((e) => e.id == api.first.id);
    final lastIndex = cache.indexWhere((e) => e.id == api.last.id);

    return of(firstIndex, lastIndex).combineLoad(cache, api, limit: limit);
  }

  static Iterable<Message> combineLoadMore(
    List<Message> cache,
    List<MessageDto> api, {
    required int limit,
  }) {
    final cacheSubList = cache.where((m) => m.fromCache).toList();
    final firstIndex = cacheSubList.indexWhere((e) => e.id == api.first.id);
    final lastIndex = cacheSubList.indexWhere((e) => e.id == api.last.id);

    final combined = of(firstIndex, lastIndex)
        .combineLoad(cacheSubList.map((m) => m.toDto()).toList(), api, limit: limit)
        .map(Message.fromDto);
    return [...cache.where((m) => !m.fromCache), ...combined];
  }

  /// 0 => 0, -1 => -1, 1 => >0
  static final Map<(int, int), CombineCacheAndApi> _cases = {
    (0, 0): _NN(),
    (0, -1): _NOut(),
    (0, 1): _NIn(),
    (-1, 0): _OutN(),
    (-1, -1): _OutOut(),
    (-1, 1): _OutIn(),
    (1, 0): _InN(),
    (1, -1): _InOut(),
    (1, 1): _InIn(),
  };

  static CombineCacheAndApi of(int firstIndex, int lastIndex) =>
      _cases[(firstIndex.clamp(-1, 1), lastIndex.clamp(-1, 1))]!;
}

/// cases
class _NN implements CombineCacheAndApi {
  @override
  Iterable<MessageDto> combineLoad(
    List<MessageDto> cache,
    List<MessageDto> api, {
    int? limit,
  }) => api;
}

class _NOut implements CombineCacheAndApi {
  @override
  Iterable<MessageDto> combineLoad(
    List<MessageDto> cache,
    List<MessageDto> api, {
    int? limit,
  }) => api;
}

class _NIn implements CombineCacheAndApi {
  @override
  Iterable<MessageDto> combineLoad(
    List<MessageDto> cache,
    List<MessageDto> api, {
    int limit = AppConstants.msgPagingLimit,
  }) {
    if (api.length < limit) return api;

    final newList = <MessageDto>[];
    newList.addAll(api);
    newList.addAll(cache.sublist(cache.indexWhere((m) => m.id == api.last.id) + 1));
    return newList;
  }
}

class _OutN implements CombineCacheAndApi {
  @override
  Iterable<MessageDto> combineLoad(
    List<MessageDto> cache,
    List<MessageDto> api, {
    int? limit,
  }) => api;
}

class _OutOut implements CombineCacheAndApi {
  @override
  Iterable<MessageDto> combineLoad(
    List<MessageDto> cache,
    List<MessageDto> api, {
    int? limit,
  }) => api;
}

class _OutIn implements CombineCacheAndApi {
  @override
  Iterable<MessageDto> combineLoad(
    List<MessageDto> cache,
    List<MessageDto> api, {
    int limit = AppConstants.msgPagingLimit,
  }) {
    if (api.length < limit) return api;

    final newList = <MessageDto>[];
    newList.addAll(api);
    newList.addAll(cache.sublist(cache.indexWhere((m) => m.id == api.last.id) + 1));
    return newList;
  }
}

class _InN implements CombineCacheAndApi {
  @override
  Iterable<MessageDto> combineLoad(
    List<MessageDto> cache,
    List<MessageDto> api, {
    int? limit,
  }) => api;
}

class _InOut implements CombineCacheAndApi {
  @override
  Iterable<MessageDto> combineLoad(
    List<MessageDto> cache,
    List<MessageDto> api, {
    int? limit,
  }) => api;
}

class _InIn implements CombineCacheAndApi {
  @override
  Iterable<MessageDto> combineLoad(
    List<MessageDto> cache,
    List<MessageDto> api, {
    int limit = AppConstants.msgPagingLimit,
  }) {
    if (api.length < limit) return api;

    final newList = <MessageDto>[];
    newList.addAll(api);
    newList.addAll(cache.sublist(cache.indexWhere((m) => m.id == api.last.id) + 1));
    return newList;
  }
}
