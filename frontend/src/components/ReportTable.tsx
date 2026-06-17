import React from 'react';

interface ReportTableProps {
  data: any[];
  title?: string;
  description?: string;
}

const ReportTable: React.FC<ReportTableProps> = ({ data, title, description }) => {
  if (!data || data.length === 0) {
    return (
      <div className="text-center py-12 bg-white border border-slate-100 rounded-xl shadow-sm text-slate-400">
        <svg className="w-12 h-12 mx-auto text-slate-300 mb-3" fill="none" stroke="currentColor" strokeWidth="1.5" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z" />
        </svg>
        <span className="text-sm font-semibold">No data available for this report view</span>
      </div>
    );
  }

  const columns = Object.keys(data[0]);

  // Dynamic helper to format values into badge pills or distinct styled text
  const renderCellValue = (value: any, columnName: string) => {
    if (value === null || value === undefined) {
      return <span className="text-slate-300 italic font-normal">N/A</span>;
    }
    const strVal = String(value);
    const normalizedVal = strVal.toLowerCase().trim();

    // 1. Seasons Badge Pills
    if (columnName.toLowerCase() === 'season') {
      if (normalizedVal === 'spring') {
        return (
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-teal-50 text-teal-700 border border-teal-100/30 capitalize">
            {strVal}
          </span>
        );
      }
      if (normalizedVal === 'fall') {
        return (
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-100/30 capitalize">
            {strVal}
          </span>
        );
      }
    }

    // 2. Roles Badge Pills
    if (columnName.toLowerCase() === 'roles' || columnName.toLowerCase() === 'role') {
      if (normalizedVal === 'player') {
        return (
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-indigo-50 text-indigo-700 border border-indigo-100/30 capitalize">
            {strVal}
          </span>
        );
      }
      if (normalizedVal === 'spectator') {
        return (
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-sky-50 text-sky-700 border border-sky-100/30 capitalize">
            {strVal}
          </span>
        );
      }
    }

    // 3. Pass Types Badge Pills
    if (columnName.toLowerCase() === 'pass_type') {
      if (normalizedVal === 'gold') {
        return (
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-extrabold bg-amber-50 text-amber-800 border border-amber-200/50 uppercase tracking-wide">
            {strVal}
          </span>
        );
      }
      if (normalizedVal === 'silver') {
        return (
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-slate-100 text-slate-700 border border-slate-200/50 uppercase tracking-wide">
            {strVal}
          </span>
        );
      }
      if (normalizedVal === 'regular') {
        return (
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-slate-50 text-slate-600 border border-slate-200/30 capitalize">
            {strVal}
          </span>
        );
      }
    }

    // 4. Outcome Badge Pills
    if (normalizedVal === 'win') {
      return (
        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-100/30 uppercase tracking-wide">
          {strVal}
        </span>
      );
    }
    if (normalizedVal === 'loss') {
      return (
        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-rose-50 text-rose-700 border border-rose-100/30 uppercase tracking-wide">
          {strVal}
        </span>
      );
    }
    if (normalizedVal === 'draw') {
      return (
        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-slate-100 text-slate-700 border border-slate-200/30 uppercase tracking-wide">
          {strVal}
        </span>
      );
    }

    // 5. Bold Identification Keys (IDs, Names, Titles)
    const isKey = columnName.toLowerCase().includes('id') || columnName.toLowerCase().includes('name') || columnName.toLowerCase().includes('title');
    if (isKey) {
      return <span className="font-bold text-slate-900">{strVal}</span>;
    }

    // 6. Numbers formatting
    const isNumber = !isNaN(Number(strVal)) && normalizedVal !== '';
    if (isNumber) {
      return <span className="font-mono text-slate-600 font-medium">{strVal}</span>;
    }

    // Default Muted Secondary Text
    return <span className="text-slate-500">{strVal}</span>;
  };

  return (
    <div className="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
      {(title || description) && (
        <div className="bg-indigo-50/20 px-6 py-5 border-b border-slate-100">
          {title && <h3 className="text-lg font-bold text-slate-900 mb-1 font-mono text-xs text-indigo-600 uppercase tracking-wider">{title}</h3>}
          {description && <p className="text-sm text-slate-500 leading-relaxed">{description}</p>}
        </div>
      )}
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-slate-100">
          <thead className="bg-slate-50">
            <tr>
              {columns.map((column) => (
                <th
                  key={column}
                  className="px-6 py-3.5 text-left text-xs font-bold text-slate-400 uppercase tracking-wider"
                >
                  {column.replace(/_/g, ' ')}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {data.map((row, rowIndex) => (
              <tr key={rowIndex} className="even:bg-slate-50/20 hover:bg-slate-50/50 transition-colors">
                {columns.map((column) => (
                  <td
                    key={column}
                    className="px-6 py-4 whitespace-nowrap text-sm"
                  >
                    {renderCellValue(row[column], column)}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="bg-slate-50/50 border-t border-slate-100 px-6 py-3.5 text-xs font-semibold text-slate-400 flex justify-between items-center">
        <span>Sport Sync Database View</span>
        <span>Roster Size: <strong className="text-slate-700 ml-0.5">{data.length}</strong></span>
      </div>
    </div>
  );
};

export default ReportTable;
