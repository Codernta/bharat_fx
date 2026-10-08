import 'package:flutter/material.dart';
import '../currency/bharat_currency.dart';
import '../currency/words_languages.dart';

/// A display widget for Indian Currency, with Indian comma formatting,
/// compact scale notation, and optional number-to-words subtitle or tooltip.
class BharatCurrencyText extends StatelessWidget {
  final num amount;
  final bool compact;
  final bool shortUnit;
  final int? decimalDigits;
  final bool showSymbol;
  final String symbol;
  final TextStyle? style;
  final TextStyle? symbolStyle;
  final bool showWordsSubtitle;
  final bool showWordsTooltip;
  final BharatLanguage wordsLanguage;
  final CrossAxisAlignment crossAxisAlignment;

  const BharatCurrencyText(
    this.amount, {
    super.key,
    this.compact = false,
    this.shortUnit = true,
    this.decimalDigits,
    this.showSymbol = true,
    this.symbol = BharatCurrency.rupeeSymbol,
    this.style,
    this.symbolStyle,
    this.showWordsSubtitle = false,
    this.showWordsTooltip = true,
    this.wordsLanguage = BharatLanguage.english,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = style ?? theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 24);
    final symStyle = symbolStyle ??
        textStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: textStyle.color?.withValues(alpha: 0.85),
        );

    final formattedNumber = compact
        ? BharatCurrency.compact(
            amount,
            symbol: '',
            showSymbol: false,
            shortUnit: shortUnit,
            decimalDigits: decimalDigits ?? 2,
          )
        : BharatCurrency.format(
            amount,
            symbol: '',
            showSymbol: false,
            decimalDigits: decimalDigits,
          );

    final words = BharatCurrency.toWords(
      amount,
      language: wordsLanguage,
    );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (showSymbol) ...[
          Text(symbol, style: symStyle),
          const SizedBox(width: 3),
        ],
        Text(formattedNumber, style: textStyle),
      ],
    );

    if (showWordsTooltip) {
      content = Tooltip(
        message: words,
        child: content,
      );
    }

    if (showWordsSubtitle) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          content,
          const SizedBox(height: 2),
          Text(
            words,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return content;
  }
}
