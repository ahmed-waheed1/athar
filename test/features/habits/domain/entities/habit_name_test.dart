import 'package:athar/features/habits/domain/entities/habit_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalize trims surrounding whitespace only', () {
    expect(HabitName.normalize('  Read 10 pages \n'), 'Read 10 pages');
    expect(HabitName.normalize('\t '), '');
  });

  test('length counts graphemes of the trimmed name', () {
    expect(HabitName.length('  Learn English  '), 13);
    // Shadda is a combining mark: تعلّم is 4 letters, not 5 code units.
    expect(HabitName.length('تعلّم'), 4);
    expect(HabitName.length('👨‍👩‍👧 family'), 8);
  });

  test('validate: empty, too long, or fine', () {
    expect(HabitName.validate('   '), HabitNameError.empty);
    expect(HabitName.validate('a' * HabitName.maxLength), isNull);
    expect(
      HabitName.validate('a' * (HabitName.maxLength + 1)),
      HabitNameError.tooLong,
    );
    // Spaces around a 40-character name don't push it over.
    expect(HabitName.validate('  ${'a' * HabitName.maxLength}  '), isNull);
    // 40 emoji are 40 characters even though they are 80 UTF-16 units.
    expect(HabitName.validate('😀' * HabitName.maxLength), isNull);
  });
}
