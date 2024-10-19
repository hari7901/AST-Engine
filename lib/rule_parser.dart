// lib/rule_parser.dart

import 'node.dart';
import 'attribute_catalog.dart';

class RuleParser {
  final String input;
  int pos = 0;
  String? currentToken;

  RuleParser(this.input) {
    currentToken = _nextToken();
  }

  String? _nextToken() {
    if (pos >= input.length) return null;

    // Skip whitespace
    while (pos < input.length && input[pos].trim().isEmpty) {
      pos++;
    }

    if (pos >= input.length) return null;

    StringBuffer token = StringBuffer();

    if (input[pos] == '(' || input[pos] == ')') {
      token.write(input[pos]);
      pos++;
    } else if (_isOperatorChar(input[pos])) {
      while (pos < input.length && _isOperatorChar(input[pos])) {
        token.write(input[pos]);
        pos++;
      }
    } else if (input[pos] == '\'' || input[pos] == '\"') {
      // Parse string literal
      String quote = input[pos];
      token.write(quote);
      pos++;
      while (pos < input.length && input[pos] != quote) {
        token.write(input[pos]);
        pos++;
      }
      if (pos < input.length) {
        token.write(input[pos]); // Closing quote
        pos++;
      } else {
        throw FormatException('Unterminated string at position $pos');
      }
    } else {
      // Parse identifier or number
      while (pos < input.length &&
          !_isOperatorChar(input[pos]) &&
          input[pos] != '(' &&
          input[pos] != ')' &&
          input[pos].trim().isNotEmpty) {
        token.write(input[pos]);
        pos++;
      }
    }

    return token.toString();
  }

  bool _isOperatorChar(String char) {
    return ['<', '>', '=', '!', '&', '|'].contains(char);
  }

  void _consumeToken(String expected) {
    if (currentToken == expected) {
      currentToken = _nextToken();
    } else {
      throw FormatException(
          'Expected "$expected" at position $pos but found "$currentToken"');
    }
  }

  Node parse() {
    Node node = _expression();
    if (currentToken != null) {
      throw FormatException(
          'Unexpected token at position $pos: "$currentToken"');
    }
    return node;
  }

  Node _expression() {
    Node left = _term();
    while (currentToken != null &&
        (currentToken!.toUpperCase() == 'AND' ||
            currentToken!.toUpperCase() == 'OR')) {
      String operator = currentToken!.toUpperCase();
      _consumeToken(currentToken!);
      Node right = _term();
      left = Node(
        type: 'operator',
        value: operator,
        left: left,
        right: right,
      );
    }
    return left;
  }

  Node _term() {
    if (currentToken == '(') {
      _consumeToken('(');
      Node node = _expression();
      if (currentToken != ')') {
        throw FormatException('Expected ")" at position $pos');
      }
      _consumeToken(')');
      return node;
    } else if (_isAttribute(currentToken)) {
      String attribute = currentToken!;
      if (!attributeCatalog.contains(attribute)) {
        throw FormatException('Invalid attribute "$attribute" at position $pos');
      }
      _consumeToken(attribute);

      if (!_isComparisonOperator(currentToken)) {
        throw FormatException(
            'Expected comparison operator at position $pos after "$attribute"');
      }

      String operator = currentToken!;
      _consumeToken(operator);

      if (currentToken == null) {
        throw FormatException('Expected value after operator at position $pos');
      }

      String value = currentToken!;
      _consumeToken(value);

      return Node(
        type: 'operand',
        value: {
          'attribute': attribute,
          'operator': operator,
          'value': _parseValue(value),
        },
      );
    } else {
      throw FormatException('Unexpected token at position $pos: "$currentToken"');
    }
  }

  bool _isComparisonOperator(String? token) {
    return token != null &&
        ['==', '!=', '>', '<', '>=', '<='].contains(token);
  }

  bool _isAttribute(String? token) {
    return token != null &&
        !['AND', 'OR', '(', ')'].contains(token.toUpperCase());
  }

  dynamic _parseValue(String valueToken) {
    if ((valueToken.startsWith('\'') && valueToken.endsWith('\'')) ||
        (valueToken.startsWith('\"') && valueToken.endsWith('\"'))) {
      // String literal
      return valueToken.substring(1, valueToken.length - 1);
    } else if (num.tryParse(valueToken) != null) {
      // Numeric literal
      return num.parse(valueToken);
    } else {
      // Possibly a boolean or invalid token
      String lowerValue = valueToken.toLowerCase();
      if (lowerValue == 'true') return true;
      if (lowerValue == 'false') return false;
      throw FormatException('Invalid value: "$valueToken" at position $pos');
    }
  }
}

Node create_rule(String ruleString) {
  try {
    RuleParser parser = RuleParser(ruleString);
    Node ast = parser.parse();
    return ast;
  } on FormatException catch (e) {
    throw FormatException('Error parsing rule: ${e.message}');
  } catch (e) {
    // Handle other types of exceptions if necessary
    throw FormatException('An unexpected error occurred: $e');
  }
}

