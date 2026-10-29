import 'package:primelearn/core/protocol/json_envelope.dart';
import 'package:primelearn/features/stats/data/models/ranking_dto.dart';

/// 排名响应解析（`GetMarkRankingList` / 学习时长排名）。
class RankingParser {
  /// 创建解析器。
  const RankingParser();

  /// 解析榜单；`success=false` 由 [JsonEnvelope] 统一抛错。
  RankingBoardDto parse(String body) {
    final envelope = JsonEnvelope.decode(body, label: '排名');

    final data = envelope['data'];
    final entries = data is List
        ? [
            for (final item in data)
              if (item is Map<String, dynamic>) RankingEntryDto.fromJson(item),
          ]
        : const <RankingEntryDto>[];

    final message = envelope['message']?.toString().trim() ?? '';
    final parts = message.split('|');
    if (parts.length < 3) {
      return RankingBoardDto(entries: entries);
    }
    return RankingBoardDto(
      entries: entries,
      myName: parts[0].trim(),
      myRank: int.tryParse(parts[1].trim()),
      myMark: double.tryParse(parts[2].trim()),
    );
  }
}
