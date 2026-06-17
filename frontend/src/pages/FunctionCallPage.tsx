import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000/api';

const FunctionCallPage: React.FC = () => {
  const navigate = useNavigate();
  const [playerId, setPlayerId] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!playerId) {
      setError('Please enter a player ID');
      return;
    }

    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await axios.get(`${API_BASE_URL}/function/player-team-college/${playerId}`);
      setResult(response.data);
    } catch (err: any) {
      console.error('Error calling function:', err);
      console.error('Error response:', err.response?.data);
      const errorMessage = err.response?.data?.error || err.response?.data?.details || 'Failed to fetch player team and college information';
      setError(errorMessage);
      
      if (err.response?.data) {
        setResult({ sql_error: err.response.data.sql_error, solution: err.response.data.solution, hint: err.response.data.hint });
      }
      if (err.response?.data?.details && err.response.data.details.includes('does not exist')) {
        console.error('Function does not exist. Please create it using FUNCTION_FIX.sql');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 py-10 font-sans antialiased text-slate-800">
      <div className="container mx-auto px-6 max-w-3xl">
        {/* Navigation & Header */}
        <div className="mb-8">
          <button
            onClick={() => navigate('/')}
            className="group flex items-center gap-2 text-indigo-600 hover:text-indigo-800 font-semibold transition-colors mb-4 text-sm"
          >
            <svg className="w-4 h-4 transform group-hover:-translate-x-0.5 transition-transform" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
            Back to Dashboard
          </button>
          <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">
            Player Team & College Query
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            Call the PostgreSQL stored function to fetch active team and college details by player ID.
          </p>
        </div>

        {/* Input Form Panel */}
        <div className="bg-white border border-slate-100 rounded-xl shadow-sm p-6 mb-6">
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                Enter Player ID
              </label>
              <div className="flex flex-col sm:flex-row gap-4">
                <input
                  type="text"
                  value={playerId}
                  onChange={(e) => setPlayerId(e.target.value)}
                  placeholder="e.g. P001"
                  required
                  className="flex-1 px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400"
                />
                <button
                  type="submit"
                  disabled={loading}
                  className="px-6 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-lg shadow-sm hover:shadow transition-all text-sm disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                >
                  {loading ? (
                    <>
                      <svg className="animate-spin h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      Executing...
                    </>
                  ) : (
                    <>
                      <span>Execute Function</span>
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z" />
                      </svg>
                    </>
                  )}
                </button>
              </div>
            </div>
          </form>
        </div>

        {/* Error Details Panel */}
        {error && (
          <div className="bg-rose-50 border border-rose-100 rounded-xl p-5 mb-6 text-sm text-rose-800 space-y-3">
            <div className="flex items-center gap-2 font-bold">
              <svg className="w-5 h-5 text-rose-500" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
              Stored Procedure Execution Failed
            </div>
            <div>{error}</div>
            {result?.sql_error && (
              <div className="p-3 bg-white/60 border border-rose-200/50 rounded-lg font-mono text-xs text-rose-950 space-y-2">
                <div className="font-bold">SQL Error Logs:</div>
                <div className="overflow-x-auto whitespace-pre-wrap">{result.sql_error}</div>
                {result.solution && (
                  <div className="text-sm font-sans mt-2">
                    <strong className="text-rose-900">Recommended Solution:</strong> {result.solution}
                  </div>
                )}
                {result.hint && (
                  <div className="text-sm font-sans">
                    <strong className="text-rose-900">Hint:</strong> {result.hint}
                  </div>
                )}
              </div>
            )}
          </div>
        )}

        {/* Result Table Panel */}
        {result && !error && (
          <div className="bg-white border border-slate-100 rounded-xl shadow-sm p-6 mb-6 space-y-6">
            <div className="border-b border-slate-100 pb-3 flex justify-between items-center">
              <h2 className="text-lg font-bold text-slate-800">
                SQL Execution Output
              </h2>
              <span className="px-2.5 py-0.5 rounded-full text-xs font-bold bg-indigo-50 text-indigo-700">
                SUCCESS
              </span>
            </div>

            {/* Query Metadata Box */}
            <div className="bg-indigo-50/30 border border-indigo-100/50 p-4 rounded-lg space-y-2 text-xs text-slate-600">
              <div>
                <strong>SQL Command Executed:</strong>
                <code className="block bg-white border border-indigo-100/50 px-2.5 py-1.5 rounded-md font-mono mt-1 text-slate-700 overflow-x-auto">
                  {result.query}
                </code>
              </div>
              <div className="flex justify-between items-center pt-1 text-[11px] text-slate-400">
                <span><strong>Target:</strong> {result.description}</span>
                <span><strong>Param ID:</strong> {result.player_id}</span>
              </div>
            </div>

            {/* Structured Table Result */}
            {result.data && (
              <div className="border border-slate-100 rounded-xl overflow-hidden">
                <table className="min-w-full text-sm">
                  <thead>
                    <tr className="bg-slate-50 border-b border-slate-100 text-left text-xs font-bold uppercase tracking-wider text-slate-400">
                      <th className="px-5 py-3">Property</th>
                      <th className="px-5 py-3">Value</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {Object.entries(result.data).map(([key, value]) => (
                      <tr key={key} className="hover:bg-slate-50/50 transition-colors">
                        <td className="px-5 py-3.5 font-bold text-slate-600 uppercase tracking-wide text-xs">
                          {key.replace(/_/g, ' ')}
                        </td>
                        <td className="px-5 py-3.5 font-semibold text-slate-900 font-mono">
                          {value !== null && value !== undefined ? String(value) : (
                            <span className="text-slate-400 font-normal italic">NULL (No Record)</span>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {/* Stored Function Documentation */}
        <div className="bg-white border border-slate-100 rounded-xl shadow-sm p-6">
          <h3 className="text-base font-bold text-slate-800 mb-2 flex items-center gap-1.5">
            <svg className="w-5 h-5 text-indigo-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            Stored Function Definition
          </h3>
          <p className="text-sm text-slate-500 leading-relaxed mb-3">
            This query utilizes a custom PostgreSQL relational database function. It performs joining mechanics internally and returns structured scalar fields to avoid multiple HTTP client requests.
          </p>
          <div className="bg-slate-50 border border-slate-100 p-3 rounded-lg text-xs font-mono text-slate-600 overflow-x-auto">
            get_player_current_team_info(p_player_id VARCHAR)
          </div>
        </div>
      </div>
    </div>
  );
};

export default FunctionCallPage;
