import '../core/parser.dart';
import '../parser/action/continuation.dart';
import '../parser/utils/types.dart';
import '../reflection/transform.dart';

/// Returns a transformed [Parser] that when being used to read input prints a
/// trace of all activated parsers and their respective parse results.
///
/// For example, the snippet
///
///     final parser = letter() & word().star();
///     trace(parser).parse('f1');
///
/// produces the following output:
///
///     Instance of 'SequenceParser'
///       Instance of 'CharacterParser'[letter expected]
///       Success[1:2]: f
///       Instance of 'PossessiveRepeatingParser'[0..*]
///         Instance of 'CharacterParser'[letter or digit expected]
///         Success[1:3]: 1
///         Instance of 'CharacterParser'[letter or digit expected]
///         Failure[1:3]: letter or digit expected
///       Success[1:3]: [1]
///     Success[1:3]: [f, [1]]
///
/// Indentation signifies the activation of a parser object. Reverse indentation
/// signifies the returning of a parse result either with a success or failure
/// context.
Parser<T> trace<T>(Parser<T> root,
    {VoidCallback<String> output = print, String indent = '  '}) {
  var level = 0;
  return transformParser(root, <T>(each) {
    return each.callCC((continuation, context) {
      output('${indent * level}$each');
      level++;
      final result = continuation(context);
      level--;
      output('${indent * level}$result');
      return result;
    });
  });
}
