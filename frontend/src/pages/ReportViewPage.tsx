import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import ReportTable from '../components/ReportTable';

const API_BASE_URL = 'http://localhost:5000/api';

interface ReportViewPageProps {
  reportType: 'multidept-organizers' | 'fall-undefeated' | 'top-scoring-players' | 'team-win-statistics' | 'tournament-participants';
}

const ReportViewPage: React.FC<ReportViewPageProps> = ({ reportType }) => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState<any>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchReport();
  }, [reportType]);

  const fetchReport = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await axios.get(`${API_BASE_URL}/report/${reportType}`);
      setData(response.data);
    } catch (err: any) {
      setError(err.response?.data?.error || 'Failed to fetch report');
    } finally {
      setLoading(false);
    }
  };

  const getReportInfo = () => {
    const reportInfoMap: Record<string, { title: string; description: string }> = {
      'multidept-organizers': {
        title: 'Q22 - Multi-Department Organizers',
        description: 'Organizers who worked in both Logistics and Marketing departments.',
      },
      'fall-undefeated': {
        title: 'Q30 - Fall Undefeated Teams',
        description: 'Teams with a win outcome in every Fall match.',
      },
      'top-scoring-players': {
        title: 'Top Scoring Players',
        description: 'Top 10 players with the highest total scores across all matches.',
      },
      'team-win-statistics': {
        title: 'Team Win Statistics',
        description: 'Detailed win, loss, and draw counts for all active teams.',
      },
      'tournament-participants': {
        title: 'Tournament Participants',
        description: 'Roster of all participating players grouped by tournament.',
      },
    };

    return reportInfoMap[reportType] || {
      title: 'Report',
      description: 'View report data',
    };
  };

  const reportInfo = getReportInfo();

  return (
    <div className="min-h-screen bg-slate-50 py-10 font-sans antialiased text-slate-800">
      <div className="container mx-auto px-6 max-w-7xl">
        {/* Navigation & Header */}
        <div className="mb-8 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div>
            <button
              onClick={() => navigate('/')}
              className="group flex items-center gap-2 text-indigo-600 hover:text-indigo-800 font-semibold transition-colors mb-4 text-sm"
            >
              <svg className="w-4 h-4 transform group-hover:-translate-x-0.5 transition-transform" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
              </svg>
              Back to Dashboard
            </button>
            <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">{reportInfo.title}</h1>
            <p className="text-sm text-slate-500 mt-1">{reportInfo.description}</p>
          </div>

          {/* Action Area */}
          {!loading && !error && data && (
            <div className="flex items-center gap-4 bg-white border border-slate-100 rounded-xl p-3 shadow-sm w-fit self-end">
              <span className="text-xs font-semibold text-slate-400 uppercase tracking-wider pl-2">
                Total Records: <strong className="text-slate-900 font-bold ml-1">{data.count || 0}</strong>
              </span>
              <div className="h-4 w-px bg-slate-200" />
              <button
                onClick={fetchReport}
                className="px-4 py-2 bg-indigo-650 hover:bg-indigo-750 text-indigo-650 font-bold text-xs bg-indigo-50 hover:bg-indigo-100 border border-indigo-100/50 rounded-lg transition-colors flex items-center gap-1.5"
              >
                <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 1121.21 7.89H18" />
                </svg>
                Refresh Data
              </button>
            </div>
          )}
        </div>

        {/* Loading State Overlay */}
        {loading && (
          <div className="bg-white border border-slate-100 rounded-xl shadow-sm p-12 text-center flex flex-col items-center justify-center gap-4">
            <svg className="animate-spin h-8 w-8 text-indigo-600" fill="none" viewBox="0 0 24 24">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <div className="text-sm font-semibold text-slate-500">Querying database view models...</div>
          </div>
        )}

        {/* Error Alert */}
        {error && (
          <div className="bg-rose-50 border border-rose-100 rounded-xl p-5 mb-6 text-sm text-rose-800 flex items-start gap-3">
            <svg className="w-5 h-5 text-rose-500 shrink-0" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
            <div>
              <p className="font-bold">Error Fetching Report</p>
              <p className="mt-0.5">{error}</p>
            </div>
          </div>
        )}

        {/* Report Table Display */}
        {!loading && !error && data && (
          <div className="animate-fadeIn">
            <ReportTable
              data={data.data || []}
              title={data.query}
              description={data.description}
            />
          </div>
        )}
      </div>
    </div>
  );
};

export default ReportViewPage;
