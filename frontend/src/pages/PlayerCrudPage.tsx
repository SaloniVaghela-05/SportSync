import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000/api';

interface PlayerFormData {
  person_id: string;
  person_name: string;
  gender: string;
  dob: string;
  contact_no: string;
  college_name: string;
  roles: string;
  height: number | string;
  weight: number | string;
  bloodgroup: string;
  joining_year: number | string;
}

const PlayerCrudPage: React.FC<{ mode: 'insert' | 'update' | 'delete' }> = ({ mode }) => {
  const navigate = useNavigate();
  const { id } = useParams<{ id?: string }>();
  const [formData, setFormData] = useState<PlayerFormData>({
    person_id: id || '',
    person_name: '',
    gender: '',
    dob: '',
    contact_no: '',
    college_name: '',
    roles: mode === 'insert' ? 'Player' : '',
    height: '',
    weight: '',
    bloodgroup: '',
    joining_year: '',
  });
  const [oldData, setOldData] = useState<PlayerFormData | null>(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [fetchId, setFetchId] = useState(id || '');

  useEffect(() => {
    if (mode === 'update' && id) {
      fetchPlayerData(id);
    }
  }, [mode, id]);

  const fetchPlayerData = async (playerId: string) => {
    setLoading(true);
    try {
      const response = await axios.get(`${API_BASE_URL}/player/${playerId}`);
      const player = response.data;
      setFormData({
        person_id: player.person_id,
        person_name: player.person_name || '',
        gender: player.gender || '',
        dob: player.dob ? player.dob.split('T')[0] : '',
        contact_no: player.contact_no || '',
        college_name: player.college_name || '',
        roles: player.roles || '',
        height: player.height || '',
        weight: player.weight || '',
        bloodgroup: player.bloodgroup || '',
        joining_year: player.joining_year || '',
      });
      setOldData({
        person_id: player.person_id,
        person_name: player.person_name || '',
        gender: player.gender || '',
        dob: player.dob ? player.dob.split('T')[0] : '',
        contact_no: player.contact_no || '',
        college_name: player.college_name || '',
        roles: player.roles || '',
        height: player.height || '',
        weight: player.weight || '',
        bloodgroup: player.bloodgroup || '',
        joining_year: player.joining_year || '',
      });
      setMessage({ type: 'success', text: 'Player data loaded successfully' });
    } catch (error: any) {
      setMessage({
        type: 'error',
        text: error.response?.data?.error || 'Failed to fetch player data',
      });
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);

    try {
      if (mode === 'insert') {
        const response = await axios.post(`${API_BASE_URL}/player`, formData);
        setMessage({ type: 'success', text: response.data.message || 'Player inserted successfully!' });

        setFormData({
          person_id: '',
          person_name: '',
          gender: '',
          dob: '',
          contact_no: '',
          college_name: '',
          roles: '',
          height: '',
          weight: '',
          bloodgroup: '',
          joining_year: '',
        });
      } else if (mode === 'update') {
        const updateData: Partial<PlayerFormData> = {};
        
        if (formData.contact_no !== oldData?.contact_no) {
          updateData.contact_no = formData.contact_no;
        }
        if (formData.college_name !== oldData?.college_name) {
          updateData.college_name = formData.college_name;
        }
        if (formData.height !== oldData?.height) {
          updateData.height = formData.height;
        }
        if (formData.weight !== oldData?.weight) {
          updateData.weight = formData.weight;
        }
        if (formData.bloodgroup !== oldData?.bloodgroup) {
          updateData.bloodgroup = formData.bloodgroup;
        }

        if (Object.keys(updateData).length === 0) {
          setMessage({ type: 'error', text: 'No changes detected' });
          setLoading(false);
          return;
        }

        const response = await axios.put(`${API_BASE_URL}/player/${formData.person_id}`, updateData);
        setMessage({ type: 'success', text: response.data.message || 'Player updated successfully!' });
        
        if (response.data.new) {
          setOldData({ ...oldData, ...response.data.new } as PlayerFormData);
        }
      } else if (mode === 'delete') {
        if (!formData.person_id) {
          setMessage({ type: 'error', text: 'Please enter a player ID' });
          setLoading(false);
          return;
        }

        const response = await axios.delete(`${API_BASE_URL}/player/${formData.person_id}`);
        setMessage({ type: 'success', text: response.data.message || 'Player deleted successfully!' });
        
        setFormData({
          person_id: '',
          person_name: '',
          gender: '',
          dob: '',
          contact_no: '',
          college_name: '',
          roles: '',
          height: '',
          weight: '',
          bloodgroup: '',
          joining_year: '',
        });
      }
    } catch (error: any) {
      setMessage({
        type: 'error',
        text: error.response?.data?.error || `Failed to ${mode} player`,
      });
    } finally {
      setLoading(false);
    }
  };

  const handleFetchClick = () => {
    if (fetchId) {
      fetchPlayerData(fetchId);
      setFormData((prev) => ({ ...prev, person_id: fetchId }));
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: 
        name === 'height' || name === 'weight' || name === 'joining_year'
          ? (value === '' ? '' : (name === 'joining_year' ? parseInt(value, 10) : parseFloat(value)))
          : value,
    }));
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
          <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight capitalize">
            {mode} Player
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            {mode === 'insert' && 'Insert a new player into both the Person and Player database tables.'}
            {mode === 'update' && 'Update contact number, college name, or physical attributes for an existing player.'}
            {mode === 'delete' && 'Delete a player profile and associated records permanently.'}
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
              <p className="font-semibold">{message.type === 'success' ? 'Operation Success' : 'Database Notice'}</p>
              <p className="mt-0.5">{message.text}</p>
            </div>
          </div>
        )}

        {/* Fetch Card (Update Mode Only) */}
        {mode === 'update' && (
          <div className="bg-white border border-slate-100 rounded-xl p-5 shadow-sm mb-6 flex flex-col sm:flex-row gap-4 items-end">
            <div className="flex-1 w-full">
              <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                Search Player ID
              </label>
              <input
                type="text"
                placeholder="e.g. P001"
                value={fetchId}
                onChange={(e) => setFetchId(e.target.value)}
                className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400"
              />
            </div>
            <button
              type="button"
              onClick={handleFetchClick}
              disabled={loading || !fetchId}
              className="w-full sm:w-auto px-6 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-lg shadow-sm hover:shadow transition-all text-sm disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
              Fetch Player Profile
            </button>
          </div>
        )}

        {/* Main Action Form Card */}
        <div className="bg-white border border-slate-100 rounded-xl shadow-sm p-6 md:p-8">
          <form onSubmit={handleSubmit} className="space-y-6">
            {mode !== 'delete' ? (
              <>
                <div className="border-b border-slate-100 pb-4">
                  <h2 className="text-xl font-bold text-slate-800">Player Profile Details</h2>
                  <p className="text-xs text-slate-400 mt-1">Fields marked with * are required parameters.</p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Person ID */}
                  <div>
                    <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                      Person ID *
                    </label>
                    <input
                      type="text"
                      name="person_id"
                      value={formData.person_id}
                      onChange={handleChange}
                      required
                      disabled={mode === 'update'}
                      maxLength={10}
                      className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400 disabled:bg-slate-100 disabled:text-slate-400 disabled:border-slate-200"
                      placeholder="e.g. P001"
                    />
                  </div>

                  {/* Person Name */}
                  <div>
                    <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                      Person Name *
                    </label>
                    <input
                      type="text"
                      name="person_name"
                      value={formData.person_name}
                      onChange={handleChange}
                      required={mode === 'insert'}
                      disabled={mode === 'update'}
                      className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400 disabled:bg-slate-100 disabled:text-slate-400 disabled:border-slate-200"
                      placeholder="Enter full name"
                    />
                  </div>

                  {/* Gender */}
                  <div>
                    <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                      Gender *
                    </label>
                    <select
                      name="gender"
                      value={formData.gender}
                      onChange={handleChange}
                      required={mode === 'insert'}
                      disabled={mode === 'update'}
                      className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 disabled:bg-slate-100 disabled:text-slate-400 disabled:border-slate-200"
                    >
                      <option value="">Select Gender</option>
                      <option value="Male">Male</option>
                      <option value="Female">Female</option>
                      <option value="Other">Other</option>
                    </select>
                  </div>

                  {/* Date of Birth */}
                  <div>
                    <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                      Date of Birth *
                    </label>
                    <input
                      type="date"
                      name="dob"
                      value={formData.dob}
                      onChange={handleChange}
                      required={mode === 'insert'}
                      disabled={mode === 'update'}
                      className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 disabled:bg-slate-100 disabled:text-slate-400 disabled:border-slate-200"
                    />
                  </div>

                  {/* Contact Number */}
                  <div>
                    <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                      Contact Number * (10 digits)
                    </label>
                    <input
                      type="text"
                      name="contact_no"
                      value={formData.contact_no}
                      onChange={handleChange}
                      required={mode === 'insert'}
                      maxLength={10}
                      pattern="[0-9]{10}"
                      placeholder="e.g. 9876543210"
                      className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400"
                    />
                  </div>

                  {/* College Name */}
                  <div>
                    <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                      College Name
                    </label>
                    <input
                      type="text"
                      name="college_name"
                      value={formData.college_name}
                      onChange={handleChange}
                      placeholder="Enter college affiliation"
                      className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400"
                    />
                  </div>

                  {/* Roles */}
                  <div>
                    <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                      Roles
                    </label>
                    <input
                      type="text"
                      name="roles"
                      value={formData.roles}
                      onChange={handleChange}
                      disabled={mode === 'insert' || mode === 'update'}
                      className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400 disabled:bg-slate-100 disabled:text-slate-400 disabled:border-slate-200"
                      placeholder="Player"
                    />
                  </div>

                  {/* Height */}
                  <div>
                    <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                      Height (cm) *
                    </label>
                    <input
                      type="number"
                      name="height"
                      value={formData.height}
                      onChange={handleChange}
                      required={mode === 'insert'}
                      min="0"
                      step="0.01"
                      placeholder="e.g. 178.5"
                      className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400"
                    />
                  </div>

                  {/* Weight */}
                  <div>
                    <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                      Weight (kg) *
                    </label>
                    <input
                      type="number"
                      name="weight"
                      value={formData.weight}
                      onChange={handleChange}
                      required={mode === 'insert'}
                      min="0"
                      step="0.01"
                      placeholder="e.g. 68.4"
                      className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400"
                    />
                  </div>

                  {/* Blood Group */}
                  <div>
                    <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                      Blood Group
                    </label>
                    <select
                      name="bloodgroup"
                      value={formData.bloodgroup}
                      onChange={handleChange}
                      className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800"
                    >
                      <option value="">Select Blood Group</option>
                      <option value="A+">A+</option>
                      <option value="A-">A-</option>
                      <option value="B+">B+</option>
                      <option value="B-">B-</option>
                      <option value="O+">O+</option>
                      <option value="O-">O-</option>
                      <option value="AB+">AB+</option>
                      <option value="AB-">AB-</option>
                    </select>
                  </div>

                  {/* Joining Year */}
                  <div>
                    <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                      Joining Year *
                    </label>
                    <input
                      type="number"
                      name="joining_year"
                      value={formData.joining_year}
                      onChange={handleChange}
                      required={mode === 'insert'}
                      disabled={mode === 'update'}
                      min="2000"
                      max="2099"
                      placeholder="e.g. 2026"
                      className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400 disabled:bg-slate-100 disabled:text-slate-400 disabled:border-slate-200"
                    />
                  </div>
                </div>

                {/* Comparison Card Block */}
                {mode === 'update' && oldData && (
                  <div className="mt-8 border border-slate-100 bg-slate-50/50 rounded-xl p-5 shadow-sm">
                    <h3 className="text-xs font-bold text-slate-900 uppercase tracking-wider mb-4 flex items-center gap-1.5">
                      <svg className="w-4 h-4 text-indigo-600" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                      </svg>
                      Proposed Changes (Old vs New)
                    </h3>
                    <div className="overflow-x-auto">
                      <table className="min-w-full text-sm">
                        <thead>
                          <tr className="border-b border-slate-200/60 text-slate-400 font-semibold text-xs text-left">
                            <th className="pb-2">Field</th>
                            <th className="pb-2">Original Value</th>
                            <th className="pb-2">New Proposed Value</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                          {[
                            { label: 'Contact Number', oldVal: oldData.contact_no, newVal: formData.contact_no },
                            { label: 'College Name', oldVal: oldData.college_name || 'N/A', newVal: formData.college_name || 'N/A' },
                            { label: 'Height (cm)', oldVal: oldData.height, newVal: formData.height },
                            { label: 'Weight (kg)', oldVal: oldData.weight, newVal: formData.weight },
                            { label: 'Blood Group', oldVal: oldData.bloodgroup || 'N/A', newVal: formData.bloodgroup || 'N/A' },
                          ].map((item, index) => {
                            const isChanged = String(item.oldVal) !== String(item.newVal);
                            return (
                              <tr key={index} className="hover:bg-slate-100/30">
                                <td className="py-2.5 font-semibold text-slate-700">{item.label}</td>
                                <td className="py-2.5 text-slate-400 font-mono">{String(item.oldVal)}</td>
                                <td className={`py-2.5 font-semibold font-mono ${isChanged ? 'text-indigo-600' : 'text-slate-500'}`}>
                                  {String(item.newVal)}
                                  {isChanged && (
                                    <span className="ml-2 px-1.5 py-0.5 rounded text-[10px] bg-indigo-50 text-indigo-600 font-bold font-sans">
                                      Modified
                                    </span>
                                  )}
                                </td>
                              </tr>
                            );
                          })}
                        </tbody>
                      </table>
                    </div>
                  </div>
                )}
              </>
            ) : (
              <div className="space-y-4">
                <div className="border-b border-slate-100 pb-4">
                  <h2 className="text-xl font-bold text-slate-800">Select Player to Delete</h2>
                  <p className="text-xs text-slate-400 mt-1">This operation is destructive and cannot be undone.</p>
                </div>
                <div>
                  <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                    Player ID *
                  </label>
                  <input
                    type="text"
                    name="person_id"
                    value={formData.person_id}
                    onChange={handleChange}
                    required
                    placeholder="Enter unique Player ID (e.g. P001)"
                    maxLength={10}
                    className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-rose-500/20 focus:border-rose-600 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400"
                  />
                </div>
              </div>
            )}

            {/* Action Bar */}
            <div className="flex gap-4 pt-4 border-t border-slate-100">
              <button
                type="submit"
                disabled={loading}
                className={`px-6 py-2.5 rounded-lg font-bold shadow-sm hover:shadow text-sm transition-all flex items-center justify-center min-w-[120px] ${
                  mode === 'delete'
                    ? 'bg-rose-600 hover:bg-rose-700 text-white focus:ring-4 focus:ring-rose-100'
                    : 'bg-indigo-600 hover:bg-indigo-700 text-white focus:ring-4 focus:ring-indigo-100'
                } disabled:opacity-50 disabled:cursor-not-allowed`}
              >
                {loading ? (
                  <span className="flex items-center gap-2">
                    <svg className="animate-spin h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Processing...
                  </span>
                ) : mode === 'delete' ? (
                  'Delete Player Profile'
                ) : (
                  `Submit Player ${mode === 'insert' ? 'Insert' : 'Update'}`
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

export default PlayerCrudPage;
