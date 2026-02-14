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
    print('type: ${combiner.runtimeType}');
    return combiner;
  }

  /// 0 => 0, -1 => -1, 1 => >0
  late final Map<(int, int), _Combiner> _cases = {
    (0, 0): _NN(_messagesLocal),
    (0, -1): _NOut(_messagesLocal),
    (0, 1): _NIn(_messagesLocal),
    (-1, 0): _OutN(_messagesLocal),
    (-1, -1): _OutOut(_messagesLocal),
    (-1, 1): _OutIn(_messagesLocal),
    (1, 0): _InN(_messagesLocal),
    (1, -1): _InOut(_messagesLocal),
    (1, 1): _InIn(_messagesLocal),
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

/// cases
class _NN extends _Combiner {
  _NN(super.local);

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

class _NOut extends _Combiner {
  _NOut(super.local);

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

class _NIn extends _Combiner {
  _NIn(super.local);

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

    final newList = <MessageDto>[];
    newList.addAll(api);
    newList.addAll(cache.sublist(cache.indexWhere((m) => m.id == api.last.id) + 1));
    return newList;
  }
}

class _OutN extends _Combiner {
  _OutN(super.local);

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

class _OutOut extends _Combiner {
  _OutOut(super.local);

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

class _OutIn extends _Combiner {
  _OutIn(super.local);

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

    final newList = <MessageDto>[];
    newList.addAll(api);
    newList.addAll(cache.sublist(cache.indexWhere((m) => m.id == api.last.id) + 1));
    return newList;
  }
}

class _InN extends _Combiner {
  _InN(super.local);

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

class _InOut extends _Combiner {
  _InOut(super.local);

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

class _InIn extends _Combiner {
  _InIn(super.local);

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

    final newList = <MessageDto>[];
    newList.addAll(api);
    newList.addAll(cache.sublist(cache.indexWhere((m) => m.id == api.last.id) + 1));
    return newList;
  }
}
