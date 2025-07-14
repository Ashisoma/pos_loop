import 'package:pos_desktop_loop/db/helpers/database_helper.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ImportExportService {
  Future<String> exportSqliteToExcel() async {
    final db = await DatabaseHelper().database;

    final excel = Excel.createExcel();

    List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
    );

    for (var table in tables) {
      final tableName = table['name'] as String;
      final sheet = excel[tableName];

      final columnInfo = await db.rawQuery('PRAGMA table_info($tableName)');
      final columnNames =
          columnInfo.map((col) => col['name'].toString()).toList();

      sheet.appendRow(columnNames.cast<CellValue?>());

      final rows = await db.rawQuery('SELECT * FROM $tableName');
      for (var row in rows) {
        final rowData = columnNames.map((col) => row[col]).toList();
        sheet.appendRow(rowData.map((e) => e as CellValue?).toList());
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/${db.getVersion()}full_database_export.xlsx',
    );
    await file.writeAsBytes(excel.encode()!);
    return file.path;
  }

  Future<void> importExcelToSqlite() async {
    final db = await DatabaseHelper().database;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      for (var tableName in excel.tables.keys) {
        final sheet = excel.tables[tableName]!;
        final headers =
            sheet.rows.first.map((e) => e?.value.toString() ?? '').toList();

        for (var row in sheet.rows.skip(1)) {
          final values = <String, dynamic>{};
          for (int i = 0; i < headers.length; i++) {
            values[headers[i]] = row[i]?.value;
          }

          await db.insert(
            tableName,
            values,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    }
  }
}
