
import { RowData, Column } from '../types';

/**
 * ProjectFlow Formula Engine
 * Supports: 
 * - Row-level references: [Column Name]
 * - Basic Math: +, -, *, /
 * - Logic: IF(condition, trueVal, falseVal)
 * - Aggregates: SUM([Column]), COUNT([Column])
 * - Dates: DATEDIFF([End], [Start])
 */

export const evaluateFormula = (
  formula: string,
  currentRow: RowData,
  allRows: RowData[],
  columns: Column[]
): any => {
  if (!formula.startsWith('=')) return formula;

  let expression = formula.substring(1).trim();

  // 1. Handle Aggregates (e.g., SUM([Progress]))
  const aggregateRegex = /(SUM|COUNT|AVG)\(\s*\[([^\]]+)\]\s*\)/gi;
  expression = expression.replace(aggregateRegex, (match, func, colTitle) => {
    const col = columns.find(c => c.title === colTitle || c.id === colTitle);
    if (!col) return '0';

    const values = allRows.map(r => {
      const val = r[col.id];
      return typeof val === 'number' ? val : parseFloat(String(val || 0)) || 0;
    });

    switch (func.toUpperCase()) {
      case 'SUM':
        return values.reduce((a, b) => a + b, 0).toString();
      case 'COUNT':
        return allRows.filter(r => r[col.id] !== undefined && r[col.id] !== '').length.toString();
      case 'AVG':
        return values.length ? (values.reduce((a, b) => a + b, 0) / values.length).toString() : '0';
      default:
        return '0';
    }
  });

  // 2. Handle Date Functions (e.g., DATEDIFF([Due Date], [Start Date]))
  const dateDiffRegex = /DATEDIFF\(\s*\[([^\]]+)\]\s*,\s*\[([^\]]+)\]\s*\)/gi;
  expression = expression.replace(dateDiffRegex, (match, colA, colB) => {
    const cA = columns.find(c => c.title === colA || c.id === colA);
    const cB = columns.find(c => c.title === colB || c.id === colB);
    if (!cA || !cB) return '0';

    const d1 = new Date(String(currentRow[cA.id] || ''));
    const d2 = new Date(String(currentRow[cB.id] || ''));
    
    if (isNaN(d1.getTime()) || isNaN(d2.getTime())) return '0';
    
    const diffTime = d1.getTime() - d2.getTime();
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24)).toString();
  });

  // 3. Handle Row References (e.g., [Progress])
  // We match [Column Name] or [columnId]
  const refRegex = /\[([^\]]+)\]/g;
  expression = expression.replace(refRegex, (match, colTitle) => {
    const col = columns.find(c => c.title === colTitle || c.id === colTitle);
    if (!col) return '0';
    const val = currentRow[col.id];
    
    if (typeof val === 'number' || typeof val === 'boolean') return String(val);
    if (typeof val === 'string') {
      // If the referenced cell is also a formula, we can't easily recurse without circular check
      // For MVP, we just take the raw string if it's not a formula
      return val.startsWith('=') ? '0' : `"${val}"`;
    }
    return '0';
  });

  // 4. Handle Logical IF (e.g., IF(100 == 100, "Yes", "No"))
  // Very basic implementation using a safe-ish eval or Function
  try {
    // Simple IF replacement: IF(cond, a, b) -> (cond) ? a : b
    const ifRegex = /IF\(([^,]+),([^,]+),([^)]+)\)/gi;
    expression = expression.replace(ifRegex, '($1) ? $2 : $3');

    // Use a sandboxed-ish Function evaluation
    // Note: In a production environment, use a proper formula parser like 'hyperformula'
    const result = new Function(`return ${expression}`)();
    return result;
  } catch (e) {
    console.warn("Formula Error:", expression, e);
    return "#ERROR!";
  }
};

export const computeSheetData = (sheet: { rows: RowData[], columns: Column[] }): RowData[] => {
  return sheet.rows.map(row => {
    const computedRow = { ...row };
    sheet.columns.forEach(col => {
      const value = row[col.id];
      if (typeof value === 'string' && value.startsWith('=')) {
        computedRow[col.id] = evaluateFormula(value, row, sheet.rows, sheet.columns);
      }
    });
    return computedRow;
  });
};
