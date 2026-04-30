// RESEARCH-ONLY: entire DAO. Research-only. See RESEARCH_ONLY.md.

import 'package:diplomka/database/entities/ai_attempt_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class AiAttemptDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertAttempt(AiAttemptEntity attempt);

  @Query('''SELECT * FROM AiAttempt ORDER BY timestampMs ASC''')
  Future<List<AiAttemptEntity>> findAllAttempts();

  @Query('''SELECT * FROM AiAttempt WHERE timestampMs >= :startMs AND timestampMs < :endMs ORDER BY timestampMs ASC''')
  Future<List<AiAttemptEntity>> findAttemptsInRange(int startMs, int endMs);
}
