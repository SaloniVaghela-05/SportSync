import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000/api';

const HomePage = () => {
  const [dbStatus, setDbStatus] = useState<{ 
    status: string; 
    database?: string; 
    error?: string;
    host?: string;
    port?: number | string;
    postgres_version?: string;
    code?: string;
    suggestion?: string;
  } | null>(null);

  useEffect(() => {
    checkDatabaseConnection();
  }, []);

  const checkDatabaseConnection = async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/db-check`);
      setDbStatus(response.data);
    } catch (error: any) {
      if (error.response?.data) {
        setDbStatus(error.response.data);
      } else {
        setDbStatus({
          status: 'Disconnected',
          error: error.message || 'Unable to check database connection',
          suggestion: 'Make sure the backend server is running on port 5000',
        });
      }
    }
  };

  // SVG Icons
  const Icons = {
    registerPerson: (
      <svg className="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
      </svg>
    ),
    createTournament: (
      <svg className="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
      </svg>
    ),
    insertPlayer: (
      <svg className="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
      </svg>
    ),
    updatePlayer: (
      <svg className="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
      </svg>
    ),
    deletePlayer: (
      <svg className="w-6 h-6 text-rose-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
      </svg>
    ),
    organizers: (
      <svg className="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
      </svg>
    ),
    undefeated: (
      <svg className="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
      </svg>
    ),
    topScoring: (
      <svg className="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.907c.969 0 1.371 1.24.588 1.81l-3.97 2.883a1 1 0 00-.364 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.971-2.883a1 1 0 00-1.175 0l-3.97 2.883c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.364-1.118l-3.97-2.883c-.783-.57-.38-1.81.588-1.81h4.906a1 1 0 00.951-.69l1.519-4.674z" />
      </svg>
    ),
    stats: (
      <svg className="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2z" />
      </svg>
    ),
    participants: (
      <svg className="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
      </svg>
    ),
    dbFunction: (
      <svg className="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
      </svg>
    )
  };

  const managementQueries = [
    { title: 'Register Person', path: '/insert/person', description: 'Register a new person (Player or Spectator) with conditional forms.', icon: Icons.registerPerson },
    { title: 'Create Tournament', path: '/insert/tournament', description: 'Create a new tournament in the database system.', icon: Icons.createTournament },
    { title: 'Insert Player', path: '/insert/player', description: 'Insert a new player with specialized information.', icon: Icons.insertPlayer },
    { title: 'Update Player', path: '/update/player', description: 'Modify existing player profiles, height, weight, etc.', icon: Icons.updatePlayer },
    { title: 'Delete Player', path: '/delete/player', description: 'Remove a player record from the system completely.', icon: Icons.deletePlayer, isDanger: true },
  ];

  const reportQueries = [
    { title: 'Tournament Participants', path: '/report/tournament-participants', description: 'View full player roster lists organized by tournaments.', icon: Icons.participants },
    { title: 'Top Scoring Players', path: '/report/top-scoring', description: 'Display the top 10 players by total game scores.', icon: Icons.topScoring },
    { title: 'Team Win Statistics', path: '/report/team-stats', description: 'Review win, loss, and draw counts for all active teams.', icon: Icons.stats },
    { title: 'Multi-Department Organizers', path: '/report/q22', description: 'Identify organizers who served in both Logistics and Marketing.', icon: Icons.organizers },
    { title: 'Fall Undefeated Teams', path: '/report/q30', description: 'Check teams who achieved full undefeated outcomes in the Fall.', icon: Icons.undefeated },
  ];

  const dbFunctions = [
    { title: 'Player Team & College', path: '/function/q36', description: 'Call the PostgreSQL stored function to fetch active team and college details by player ID.', icon: Icons.dbFunction },
  ];

  return (
    <div className="min-h-screen bg-slate-50 font-sans antialiased text-slate-800">
      {/* Top Header Section */}
      <header className="border-b border-slate-200 bg-white py-6">
        <div className="container mx-auto px-6 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div>
            <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">
              Sport Sync Dashboard
            </h1>
            <p className="text-sm text-slate-500 mt-1">
              Tournament Database Manager and Query Portal
            </p>
          </div>

          {/* Database Connection Status inside Header */}
          {dbStatus && (
            <div className={`flex items-center gap-3 px-4 py-2.5 rounded-lg border text-sm font-medium ${
              dbStatus.status === 'Connected' 
                ? 'bg-emerald-50 border-emerald-100 text-emerald-800' 
                : 'bg-rose-50 border-rose-100 text-rose-800'
            }`}>
              <span className={`relative flex h-2 w-2`}>
                <span className={`animate-ping absolute inline-flex h-full w-full rounded-full opacity-75 ${
                  dbStatus.status === 'Connected' ? 'bg-emerald-400' : 'bg-rose-400'
                }`}></span>
                <span className={`relative inline-flex rounded-full h-2 w-2 ${
                  dbStatus.status === 'Connected' ? 'bg-emerald-500' : 'bg-rose-500'
                }`}></span>
              </span>
              <span>
                DB Status: <strong>{dbStatus.status}</strong>
                {dbStatus.database && ` (${dbStatus.database})`}
              </span>
              <button
                onClick={checkDatabaseConnection}
                className="ml-2 hover:bg-white/50 p-1 rounded transition-colors"
                title="Refresh Status"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 1121.21 7.89H18" />
                </svg>
              </button>
            </div>
          )}
        </div>
      </header>

      {/* Main Content Area */}
      <main className="container mx-auto px-6 py-10 space-y-12">
        {/* Error Status Alert Banner */}
        {dbStatus && dbStatus.status === 'Disconnected' && (
          <div className="p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 max-w-4xl mx-auto space-y-2">
            <div className="flex items-center gap-2 font-semibold">
              <svg className="w-5 h-5 text-rose-500" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
              Database Connection Failed
            </div>
            {dbStatus.error && <p className="text-sm"><strong>Error:</strong> {dbStatus.error}</p>}
            {dbStatus.suggestion && <p className="text-xs italic bg-white/60 p-2 rounded mt-1">💡 {dbStatus.suggestion}</p>}
            {dbStatus.host && <p className="text-xs text-rose-600">Attempted connection: {dbStatus.host}:{dbStatus.port}</p>}
          </div>
        )}

        {/* SECTION 1: QUICK MANAGEMENT ACTIONS */}
        <section className="space-y-4">
          <div className="flex items-center gap-2">
            <span className="w-1.5 h-6 bg-indigo-600 rounded-full"></span>
            <h2 className="text-xl font-bold text-slate-900 uppercase tracking-wider text-xs">
              Management & Operations
            </h2>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {managementQueries.map((query, idx) => (
              <Link
                key={idx}
                to={query.path}
                className="group relative bg-white border border-slate-100 rounded-xl p-6 shadow-sm hover:shadow-md transition-all duration-200 transform hover:-translate-y-0.5 flex flex-col justify-between"
              >
                <div>
                  <div className={`p-3 rounded-lg w-fit mb-4 ${query.isDanger ? 'bg-rose-50' : 'bg-indigo-50'}`}>
                    {query.icon}
                  </div>
                  <h3 className="text-lg font-bold text-slate-800 group-hover:text-indigo-600 transition-colors">
                    {query.title}
                  </h3>
                  <p className="text-sm text-slate-500 mt-2 leading-relaxed">
                    {query.description}
                  </p>
                </div>
                <div className="mt-5 flex items-center gap-1 text-sm font-semibold text-indigo-600 group-hover:gap-2 transition-all">
                  <span>Open Form</span>
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                  </svg>
                </div>
              </Link>
            ))}
          </div>
        </section>

        {/* SECTION 2: ANALYTICAL REPORTS */}
        <section className="space-y-4">
          <div className="flex items-center gap-2">
            <span className="w-1.5 h-6 bg-indigo-600 rounded-full"></span>
            <h2 className="text-xl font-bold text-slate-900 uppercase tracking-wider text-xs">
              Database Analytical Reports
            </h2>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {reportQueries.map((query, idx) => (
              <Link
                key={idx}
                to={query.path}
                className="group bg-white border border-slate-100 rounded-xl p-6 shadow-sm hover:shadow-md transition-all duration-200 transform hover:-translate-y-0.5 flex flex-col justify-between"
              >
                <div>
                  <div className="p-3 bg-indigo-50 rounded-lg w-fit mb-4">
                    {query.icon}
                  </div>
                  <h3 className="text-lg font-bold text-slate-800 group-hover:text-indigo-600 transition-colors">
                    {query.title}
                  </h3>
                  <p className="text-sm text-slate-500 mt-2 leading-relaxed">
                    {query.description}
                  </p>
                </div>
                <div className="mt-5 flex items-center gap-1 text-sm font-semibold text-indigo-600 group-hover:gap-2 transition-all">
                  <span>View Report</span>
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                  </svg>
                </div>
              </Link>
            ))}
          </div>
        </section>

        {/* SECTION 3: DATABASE FUNCTION QUERIES */}
        <section className="space-y-4">
          <div className="flex items-center gap-2">
            <span className="w-1.5 h-6 bg-indigo-600 rounded-full"></span>
            <h2 className="text-xl font-bold text-slate-900 uppercase tracking-wider text-xs">
              Stored Functions & Queries
            </h2>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {dbFunctions.map((query, idx) => (
              <Link
                key={idx}
                to={query.path}
                className="group bg-white border border-slate-100 rounded-xl p-6 shadow-sm hover:shadow-md transition-all duration-200 transform hover:-translate-y-0.5 flex flex-col justify-between"
              >
                <div>
                  <div className="p-3 bg-indigo-50 rounded-lg w-fit mb-4">
                    {query.icon}
                  </div>
                  <h3 className="text-lg font-bold text-slate-800 group-hover:text-indigo-600 transition-colors">
                    {query.title}
                  </h3>
                  <p className="text-sm text-slate-500 mt-2 leading-relaxed">
                    {query.description}
                  </p>
                </div>
                <div className="mt-5 flex items-center gap-1 text-sm font-semibold text-indigo-600 group-hover:gap-2 transition-all">
                  <span>Execute Function</span>
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                  </svg>
                </div>
              </Link>
            ))}
          </div>
        </section>
      </main>

      <footer className="border-t border-slate-200 bg-white py-6 mt-16 text-center text-xs text-slate-400">
        Sport Tournament Database Manager &copy; {new Date().getFullYear()} - Designed with Tailwind CSS
      </footer>
    </div>
  );
};

export default HomePage;
