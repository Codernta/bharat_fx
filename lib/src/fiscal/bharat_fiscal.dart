/// Indian Fiscal Quarters (April to March cycle).
enum FiscalQuarter {
  /// Q1: April 1 to June 30.
  q1('Q1 (Apr - Jun)'),

  /// Q2: July 1 to September 30.
  q2('Q2 (Jul - Sep)'),

  /// Q3: October 1 to December 31.
  q3('Q3 (Oct - Dec)'),

  /// Q4: January 1 to March 31.
  q4('Q4 (Jan - Mar)');

  final String description;
  const FiscalQuarter(this.description);
}

/// Advance Tax Installment schedule mandated by the Income Tax Department of India.
class AdvanceTaxInstallment {
  final String title;
  final DateTime dueDate;
  final int cumulativePercentage;

  const AdvanceTaxInstallment({
    required this.title,
    required this.dueDate,
    required this.cumulativePercentage,
  });

  @override
  String toString() {
    return '$title: $cumulativePercentage% by ${dueDate.day}/${dueDate.month}/${dueDate.year}';
  }
}

/// Utilities for Indian Financial Year, Fiscal Quarters, RBI Banking Days, and Market Settlement Dates.
class BharatFiscal {
  /// Returns the Indian Financial Year string (e.g. `FY 2024-25`).
  ///
  /// In India, the Financial Year starts on April 1 and ends on March 31.
  ///
  /// Examples:
  /// ```dart
  /// BharatFiscal.financialYear(date: DateTime(2024, 7, 15)); // "FY 2024-25"
  /// BharatFiscal.financialYear(date: DateTime(2025, 2, 10)); // "FY 2024-25"
  /// ```
  static String financialYear({DateTime? date}) {
    final target = date ?? DateTime.now();
    final year = target.year;
    final isAfterApril = target.month >= 4;

    final startYear = isAfterApril ? year : year - 1;
    final endYear = (startYear + 1) % 100;
    final endYearStr = endYear.toString().padLeft(2, '0');

    return 'FY $startYear-$endYearStr';
  }

  /// Returns the Indian Assessment Year string (e.g. `AY 2025-26`).
  ///
  /// The Assessment Year is the year following the relevant Financial Year.
  static String assessmentYear({DateTime? date}) {
    final target = date ?? DateTime.now();
    final year = target.year;
    final isAfterApril = target.month >= 4;

    final startYear = (isAfterApril ? year : year - 1) + 1;
    final endYear = (startYear + 1) % 100;
    final endYearStr = endYear.toString().padLeft(2, '0');

    return 'AY $startYear-$endYearStr';
  }

  /// Returns the current Indian fiscal quarter for a given date.
  static FiscalQuarter quarter({DateTime? date}) {
    final month = (date ?? DateTime.now()).month;
    if (month >= 4 && month <= 6) return FiscalQuarter.q1;
    if (month >= 7 && month <= 9) return FiscalQuarter.q2;
    if (month >= 10 && month <= 12) return FiscalQuarter.q3;
    return FiscalQuarter.q4;
  }

  /// Returns the statutory Advance Tax installment deadlines for a given fiscal year.
  static List<AdvanceTaxInstallment> advanceTaxDueDates(
      {int? fiscalStartYear}) {
    final currentFYStart = (DateTime.now().month >= 4)
        ? DateTime.now().year
        : DateTime.now().year - 1;
    final start = fiscalStartYear ?? currentFYStart;

    return [
      AdvanceTaxInstallment(
        title: '1st Installment',
        dueDate: DateTime(start, 6, 15),
        cumulativePercentage: 15,
      ),
      AdvanceTaxInstallment(
        title: '2nd Installment',
        dueDate: DateTime(start, 9, 15),
        cumulativePercentage: 45,
      ),
      AdvanceTaxInstallment(
        title: '3rd Installment',
        dueDate: DateTime(start, 12, 15),
        cumulativePercentage: 75,
      ),
      AdvanceTaxInstallment(
        title: '4th Installment',
        dueDate: DateTime(start + 1, 3, 15),
        cumulativePercentage: 100,
      ),
    ];
  }

  /// Checks if [date] is a non-clearing Indian banking holiday or weekend.
  ///
  /// Evaluates:
  /// - All Sundays.
  /// - 2nd and 4th Saturdays of every calendar month (RBI norm).
  /// - Mandatory National Gazetted Holidays: Republic Day (Jan 26), Independence Day (Aug 15),
  ///   Mahatma Gandhi Jayanti (Oct 2), May Day (May 1).
  static bool isBankHoliday(DateTime date) {
    // 1. All Sundays
    if (date.weekday == DateTime.sunday) return true;

    // 2. 2nd and 4th Saturdays
    if (date.weekday == DateTime.saturday) {
      final weekOfMonth = ((date.day - 1) ~/ 7) + 1;
      if (weekOfMonth == 2 || weekOfMonth == 4) return true;
    }

    // 3. National Gazetted holidays
    final month = date.month;
    final day = date.day;
    if (month == 1 && day == 26) return true; // Republic Day
    if (month == 5 && day == 1) return true; // May Day / Labour Day
    if (month == 8 && day == 15) return true; // Independence Day
    if (month == 10 && day == 2) return true; // Gandhi Jayanti

    return false;
  }

  /// Calculates the next trade / payout settlement date (e.g. T+1 or T+2),
  /// skipping Indian bank holidays, 2nd/4th Saturdays, and Sundays.
  ///
  /// Examples:
  /// ```dart
  /// // Wednesday before August 15 (T+1 settlement)
  /// final settlement = BharatFiscal.calculateSettlementDate(
  ///   DateTime(2024, 8, 14),
  ///   settlementDays: 1,
  /// ); // Resolves to Friday, Aug 16 (skips Aug 15)
  /// ```
  static DateTime calculateSettlementDate(
    DateTime tradeDate, {
    int settlementDays = 1,
  }) {
    DateTime current = DateTime(tradeDate.year, tradeDate.month, tradeDate.day);
    int addedDays = 0;

    while (addedDays < settlementDays) {
      current = current.add(const Duration(days: 1));
      if (!isBankHoliday(current)) {
        addedDays++;
      }
    }

    return current;
  }
}
