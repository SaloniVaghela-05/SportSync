import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000/api';

interface TournamentFormData {
  tournament_id: string;
  tournament_year: number | string;
  season: string;
  start_date: string;
  end_date: string;
}

const TournamentInsertPage: React.FC = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState<TournamentFormData>({
    tournament_id: '',
    tournament_year: '',
    season: '',
    start_date: '',
    end_date: '',
  });
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [tournamentIdError, setTournamentIdError] = useState<string>('');
  const [checkingTournamentId, setCheckingTournamentId] = useState(false);

  const checkTournamentId = async (tournamentId: string) => {
    if (!tournamentId || tournamentId.trim() === '') {
      setTournamentIdError('');
      return false;
    }

    setCheckingTournamentId(true);
    setTournamentIdError('');

    try {
      const response = await axios.get(`${API_BASE_URL}/tournament/${tournamentId}`);
      if (response.data.tournament_id) {
        setTournamentIdError(`Tournament ID already exists. Please enter another tournament ID.`);
        return true; 
      }
      return false; 
    } catch (error: any) {
      if (error.response?.status === 404) {
        return false;
      }
      console.error('Error checking tournament ID:', error);
      return false;
    } finally {
      setCheckingTournamentId(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: name === 'tournament_year' 
        ? (value === '' ? '' : parseInt(value, 10))
        : value,
    }));

    if (name === 'tournament_id') {
      setTournamentIdError('');
    }
  };

  const handleTournamentIdBlur = async () => {
    if (formData.tournament_id && formData.tournament_id.trim() !== '') {
      await checkTournamentId(formData.tournament_id);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);

    if (!formData.tournament_id || !formData.tournament_year || !formData.season || 
        !formData.start_date || !formData.end_date) {
      setMessage({ type: 'error', text: 'Please fill all required fields' });
      setLoading(false);
      return;
    }

    const year = typeof formData.tournament_year === 'string' 
      ? parseInt(formData.tournament_year, 10) 
      : formData.tournament_year;
    
    if (year < 2000 || year > 2035) {
      setMessage({ type: 'error', text: 'Tournament year must be between 2000 and 2035' });
      setLoading(false);
      return;
    }

    const startDate = new Date(formData.start_date);
    const endDate = new Date(formData.end_date);
    
    if (endDate < startDate) {
      setMessage({ type: 'error', text: 'End date must be greater than or equal to start date' });
      setLoading(false);
      return;
    }

    const idExists = await checkTournamentId(formData.tournament_id);
    if (idExists) {
      setMessage({ type: 'error', text: 'Please enter another tournament ID as this ID already exists' });
      setLoading(false);
      return;
    }

    try {
      const response = await axios.post(`${API_BASE_URL}/tournament`, formData);
      setMessage({ type: 'success', text: response.data.message || 'Tournament created successfully!' });
      
      setTimeout(() => {
        setFormData({
          tournament_id: '',
          tournament_year: '',
          season: '',
          start_date: '',
          end_date: '',
        });
      }, 2000);
    } catch (error: any) {
      setMessage({
        type: 'error',
        text: error.response?.data?.error || 'Failed to create tournament',
      });
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
            Create Tournament
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            Configure a new athletic tournament season schedule in the database system.
          </p>
        </div>

        {/* Notifications */}
        {message && (
          <div
            className={`mb-6 p-4 rounded-xl border flex items-start gap-3 text-sm ${
              message.type === 'success'
                ? 'bg-emerald-50 border-emerald-100 text-emerald-800'
                : 'bg-rose-50 border-rose-100 text-rose-800'
            }`}
          >
            {message.type === 'success' ? (
              <svg className="w-5 h-5 text-emerald-500 shrink-0" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            ) : (
              <svg className="w-5 h-5 text-rose-500 shrink-0" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
            )}
            <div>
              <p className="font-semibold">{message.type === 'success' ? 'Tournament Created' : 'Validation Error'}</p>
              <p className="mt-0.5">{message.text}</p>
            </div>
          </div>
        )}

        {/* Tournament Form Panel */}
        <div className="bg-white border border-slate-100 rounded-xl shadow-sm p-6 md:p-8">
          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="border-b border-slate-100 pb-4">
              <h2 className="text-xl font-bold text-slate-800">Tournament Configuration</h2>
              <p className="text-xs text-slate-400 mt-1">Provide tournament ID, active year, and season dates.</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Tournament ID */}
              <div>
                <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                  Tournament ID *
                </label>
                <div className="relative">
                  <input
                    type="text"
                    name="tournament_id"
                    value={formData.tournament_id}
                    onChange={handleChange}
                    onBlur={handleTournamentIdBlur}
                    required
                    maxLength={10}
                    className={`w-full border rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400 ${
                      tournamentIdError 
                        ? 'border-rose-300 focus:ring-rose-500/20 focus:border-rose-500 bg-rose-50/20' 
                        : formData.tournament_id && !tournamentIdError && !checkingTournamentId
                          ? 'border-emerald-300 focus:ring-emerald-500/20 focus:border-emerald-500 bg-emerald-50/10'
                          : 'border-slate-200 focus:ring-indigo-500/20 focus:border-indigo-600'
                    }`}
                    placeholder="e.g. T2026"
                    disabled={checkingTournamentId}
                  />
                  {checkingTournamentId && (
                    <span className="absolute right-3 top-3.5 flex h-2 w-2">
                      <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-indigo-400 opacity-75"></span>
                      <span className="relative inline-flex rounded-full h-2 w-2 bg-indigo-500"></span>
                    </span>
                  )}
                </div>
                {checkingTournamentId && (
                  <p className="mt-1.5 text-xs text-slate-400">Verifying unique ID availability...</p>
                )}
                {tournamentIdError && (
                  <p className="mt-1.5 text-xs text-rose-600 font-semibold flex items-center gap-1">
                    <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                    </svg>
                    {tournamentIdError}
                  </p>
                )}
                {formData.tournament_id && !tournamentIdError && !checkingTournamentId && (
                  <p className="mt-1.5 text-xs text-emerald-600 font-semibold flex items-center gap-1">
                    <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                    </svg>
                    Tournament ID is available
                  </p>
                )}
              </div>

              {/* Tournament Year */}
              <div>
                <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                  Tournament Year * (2000-2035)
                </label>
                <input
                  type="number"
                  name="tournament_year"
                  value={formData.tournament_year}
                  onChange={handleChange}
                  required
                  min="2000"
                  max="2035"
                  placeholder="e.g. 2026"
                  className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400"
                />
              </div>

              {/* Season Select */}
              <div>
                <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                  Season *
                </label>
                <select
                  name="season"
                  value={formData.season}
                  onChange={handleChange}
                  required
                  className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800"
                >
                  <option value="">Select Season</option>
                  <option value="fall">Fall</option>
                  <option value="spring">Spring</option>
                </select>
              </div>

              {/* Start Date */}
              <div>
                <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                  Start Date *
                </label>
                <input
                  type="date"
                  name="start_date"
                  value={formData.start_date}
                  onChange={handleChange}
                  required
                  className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800"
                />
              </div>

              {/* End Date */}
              <div>
                <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                  End Date * (must be &gt;= start date)
                </label>
                <input
                  type="date"
                  name="end_date"
                  value={formData.end_date}
                  onChange={handleChange}
                  required
                  min={formData.start_date || undefined}
                  className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800"
                />
              </div>
            </div>

            {/* Action Bar */}
            <div className="flex gap-4 pt-4 border-t border-slate-100">
              <button
                type="submit"
                disabled={loading || !!tournamentIdError}
                className="px-6 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-lg shadow-sm hover:shadow transition-all text-sm disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center min-w-[120px]"
              >
                {loading ? (
                  <span className="flex items-center gap-2">
                    <svg className="animate-spin h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Creating...
                  </span>
                ) : (
                  'Create Tournament'
                )}
              </button>
              <button
                type="button"
                onClick={() => navigate('/')}
                className="px-6 py-2.5 border border-slate-200 hover:bg-slate-50 text-slate-600 rounded-lg font-semibold transition-colors text-sm"
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default TournamentInsertPage;
