import 'package:kepleomax/core/app_constants.dart';
import 'package:kepleomax/core/data/local_data_sources/messages_local_data_source.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';

class CombineCacheAndApi {
  final MessagesLocalDataSource _messagesLocal;

  CombineCacheAndApi(this._messagesLocal);

  Iterable<MessageDto> combineLoad(
    List<MessageDto> cache,
    List<MessageDto> api, {
    int limit = AppConstants.msgPagingLimit,
  }) {
    return _of(cache, api).combine(cache, api, limit: limit);
  }

  Iterable<Message> combineLoadMore(
    List<Message> cache,
    List<MessageDto> api, {
    required int limit,
  }) {
    final cacheSubList = cache
        .where((m) => m.fromCache)
        .map((m) => m.toDto())
        .toList();

    final combined = _of(
      cacheSubList,
      api,
    ).combine(cacheSubList, api, limit: limit).map(Message.fromDto);
    return [...cache.where((m) => !m.fromCache), ...combined];
  }

  _Combiner _of(List<MessageDto> cache, List<MessageDto> api) {
    if (cache.isEmpty || api.isEmpty) {
      return _Any_NOut(_messagesLocal);
    }

    final firstIndex = cache.indexWhere((e) => e.id == api.first.id);
    var lastIndex = cache.indexWhere((e) => e.id == api.last.id);

    if (lastIndex > -1) {
      if (cache.last.id == api.last.id) {
        lastIndex = 0;
      } else {
        lastIndex = 1;
      }
    }

    final combiner = _cases[(firstIndex.clamp(-1, 1), lastIndex)]!;
    // print('type: ${combiner.runtimeType}');
    return combiner;
  }

  /// 0 => 0, -1 => -1, 1 => >0
  late final Map<(int, int), _Combiner> _cases = {
    (0, 0): _Any_NOut(_messagesLocal),
    (0, -1): _Any_NOut(_messagesLocal),
    (0, 1): _Any_In(_messagesLocal),
    (-1, 0): _Any_NOut(_messagesLocal),
    (-1, -1): _Any_NOut(_messagesLocal),
    (-1, 1): _Any_In(_messagesLocal),
    (1, 0): _Any_NOut(_messagesLocal),
    (1, -1): _Any_NOut(_messagesLocal),
    (1, 1): _Any_In(_messagesLocal),
  };
}

abstract class _Combiner {
  final MessagesLocalDataSource _local;

  const _Combiner(this._local);

  Iterable<MessageDto> combine(
    List<MessageDto> cache,
    List<MessageDto> api, {
    int limit,
  });
}

class _Any_NOut extends _Combiner {
  _Any_NOut(super.local);

  @override
  Iterable<MessageDto> combine(
    List<MessageDto> cache,
    List<MessageDto> api, {
    int? limit,
  }) {
    _local.deleteAllWithIds(cache.map((m) => m.id));
    _local.insertAll(api);
    return api;
  }
}

class _Any_In extends _Combiner {
  _Any_In(super.local);

  @override
  Iterable<MessageDto> combine(
    List<MessageDto> cache,
    List<MessageDto> api, {
    int limit = AppConstants.msgPagingLimit,
  }) {
    if (api.length < limit) {
      _local.deleteAllWithIds(cache.map((m) => m.id));
      _local.insertAll(api);
      return api;
    }

    _local.deleteAllWithIds(cache.where((m) => m.id < api.last.id).map((m) => m.id));
    _local.insertAll(api);

    final newList = <MessageDto>[...api];
    newList.addAll(cache.sublist(cache.indexWhere((m) => m.id == api.last.id) + 1));
    return newList;
  }
}
