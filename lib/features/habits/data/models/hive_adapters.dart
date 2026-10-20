import 'package:hive_ce/hive_ce.dart';

import 'habit_model.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([AdapterSpec<HabitModel>()])
class HiveAdapters {}
