import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000/api';

interface PersonFormData {
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
  tournament_id: string;
  pass_type: string;
}

interface Tournament {
  tournament_id: string;
  tournament_year: number;
  season: string;
  start_date: string;
  end_date: string;
}

const PersonInsertPage: React.FC = () => {
  const navigate = useNavigate();
  const [step, setStep] = useState<'basic' | 'role'>('basic');
  const [formData, setFormData] = useState<PersonFormData>({
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
    tournament_id: '',
    pass_type: '',
  });
  const [tournaments, setTournaments] = useState<Tournament[]>([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [personIdError, setPersonIdError] = useState<string>('');
  const [checkingPersonId, setCheckingPersonId] = useState(false);

  useEffect(() => {
    if (formData.roles === 'Spectator') {
      fetchUpcomingTournaments();
    }
  }, [formData.roles]);

  const fetchUpcomingTournaments = async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/tournament/upcoming`);
      console.log('Tournaments fetched:', response.data);
      setTournaments(response.data.data || []);
      if (response.data.data && response.data.data.length > 0) {
        setMessage(null);
      }
    } catch (error: any) {
      console.error('Error fetching upcoming tournaments:', error);
      console.error('Error details:', error.response?.data);
      setTournaments([]);
    }
  };

  const checkPersonId = async (personId: string) => {
    if (!personId || personId.trim() === '') {
      setPersonIdError('');
      return false;
    }

    setCheckingPersonId(true);
    setPersonIdError('');

    try {
      const response = await axios.get(`${API_BASE_URL}/person/check/${encodeURIComponent(personId)}`);
      console.log('Person ID check response:', response.data);
      if (response.data && response.data.exists === true) {
        console.log(`Person ID ${personId} EXISTS in database`);
        setPersonIdError(`Person ID already exists. Please enter another person ID.`);
        return true; 
      } else if (response.data && response.data.exists === false) {
        console.log(`Person ID ${personId} is AVAILABLE (not in database)`);
        setPersonIdError(''); 
        return false; 
      } else {
        console.error('Unexpected response format:', response.data);
        setPersonIdError('');
        return false;
      }
    } catch (error: any) {
      console.error('Error checking person ID:', error);
      if (!error.response) {
        console.warn('Network error: Cannot reach backend server');
        setPersonIdError(''); 
        return false;
      }
      if (error.response.status === 404) {
        setPersonIdError('');
        return false;
      }
      if (error.response.status >= 500) {
        setPersonIdError('');
        return false;
      }
      setPersonIdError('');
      return false;
    } finally {
      setCheckingPersonId(false);
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
    
    if (name === 'person_id') {
      setPersonIdError('');
    }
  };

  const handlePersonIdBlur = async () => {
    if (formData.person_id && formData.person_id.trim() !== '') {
      await checkPersonId(formData.person_id);
    }
  };

  const handleBasicInfoSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.person_id || !formData.person_name || !formData.gender || !formData.dob || !formData.contact_no) {
      setMessage({ type: 'error', text: 'Please fill all required fields' });
      return;
    }
    if (!/^[0-9]{10}$/.test(formData.contact_no)) {
      setMessage({ type: 'error', text: 'Contact number must be exactly 10 digits' });
      return;
    }
    
    const idExists = await checkPersonId(formData.person_id);
    if (idExists) {
      setMessage({ type: 'error', text: 'Please enter another person ID as this ID already exists' });
      return;
    }
    
    setStep('role');
    setMessage(null);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);

    const idExists = await checkPersonId(formData.person_id);
    if (idExists) {
      setMessage({ type: 'error', text: 'Please enter another person ID as this ID already exists' });
      setLoading(false);
      return;
    }

    try {
      if (formData.roles === 'Player') {
        if (!formData.height || !formData.weight || !formData.joining_year) {
          setMessage({ type: 'error', text: 'Please fill all required player fields' });
          setLoading(false);
          return;
        }
        const response = await axios.post(`${API_BASE_URL}/person/player`, formData);
        setMessage({ type: 'success', text: response.data.message || 'Player created successfully!' });
      } else if (formData.roles === 'Spectator') {
        if (!formData.tournament_id || !formData.pass_type) {
          setMessage({ type: 'error', text: 'Please select tournament and pass type' });
          setLoading(false);
          return;
        }
        const response = await axios.post(`${API_BASE_URL}/person/spectator`, formData);
        setMessage({ type: 'success', text: response.data.message || 'Spectator created successfully!' });
      } else {
        setMessage({ type: 'error', text: 'Please select a role' });
        setLoading(false);
        return;
      }

      setTimeout(() => {
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
          tournament_id: '',
          pass_type: '',
        });
        setStep('basic');
      }, 2000);
    } catch (error: any) {
      setMessage({
        type: 'error',
        text: error.response?.data?.error || 'Failed to create person',
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
            Register New Person
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            Add a new spectator or player record to the tournament database.
          </p>
        </div>

        {/* Premium Visual Stepper Component */}
        <div className="mb-8 bg-white border border-slate-100 rounded-xl p-5 shadow-sm">
          <div className="flex items-center justify-center max-w-md mx-auto">
            {/* Step 1 */}
            <div className="flex items-center gap-3">
              <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold transition-all duration-200 ${
                step === 'basic' 
                  ? 'bg-indigo-600 text-white ring-4 ring-indigo-100' 
                  : 'bg-emerald-500 text-white'
              }`}>
                {step === 'basic' ? '1' : (
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth="3" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                  </svg>
                )}
              </div>
              <span className={`text-sm font-bold ${step === 'basic' ? 'text-slate-800' : 'text-slate-400'}`}>
                Basic Info
              </span>
            </div>

            {/* Connector Line */}
            <div className={`flex-1 h-0.5 mx-4 transition-all duration-300 ${
              step === 'role' ? 'bg-emerald-500' : 'bg-slate-200'
            }`} />

            {/* Step 2 */}
            <div className="flex items-center gap-3">
              <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold transition-all duration-200 ${
                step === 'role' 
                  ? 'bg-indigo-600 text-white ring-4 ring-indigo-100' 
                  : 'bg-slate-200 text-slate-400'
              }`}>
                2
              </div>
              <span className={`text-sm font-bold ${step === 'role' ? 'text-slate-800' : 'text-slate-400'}`}>
                Role & Details
              </span>
            </div>
          </div>
        </div>

        {/* Notification Banner */}
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
              <p className="font-semibold">{message.type === 'success' ? 'Operation Successful' : 'Verification Error'}</p>
              <p className="mt-0.5">{message.text}</p>
            </div>
          </div>
        )}

        {/* Form Panel Container */}
        <div className="bg-white border border-slate-100 rounded-xl shadow-sm p-6 md:p-8">
          {step === 'basic' ? (
            <form onSubmit={handleBasicInfoSubmit} className="space-y-6">
              <div className="border-b border-slate-100 pb-4">
                <h2 className="text-xl font-bold text-slate-800">Basic Information</h2>
                <p className="text-xs text-slate-400 mt-1">Please provide personal identification and contact info.</p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Person ID */}
                <div>
                  <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                    Person ID *
                  </label>
                  <div className="relative">
                    <input
                      type="text"
                      name="person_id"
                      value={formData.person_id}
                      onChange={handleChange}
                      onBlur={handlePersonIdBlur}
                      required
                      maxLength={10}
                      className={`w-full border rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400 ${
                        personIdError 
                          ? 'border-rose-300 focus:ring-rose-500/20 focus:border-rose-500 bg-rose-50/20' 
                          : formData.person_id && !personIdError && !checkingPersonId
                            ? 'border-emerald-300 focus:ring-emerald-500/20 focus:border-emerald-500 bg-emerald-50/10'
                            : 'border-slate-200 focus:ring-indigo-500/20 focus:border-indigo-600'
                      }`}
                      placeholder="e.g. P001"
                      disabled={checkingPersonId}
                    />
                    {checkingPersonId && (
                      <span className="absolute right-3 top-3.5 flex h-2 w-2">
                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-indigo-400 opacity-75"></span>
                        <span className="relative inline-flex rounded-full h-2 w-2 bg-indigo-500"></span>
                      </span>
                    )}
                  </div>
                  {checkingPersonId && (
                    <p className="mt-1.5 text-xs text-slate-400">Verifying unique ID availability...</p>
                  )}
                  {personIdError && (
                    <p className="mt-1.5 text-xs text-rose-600 font-semibold flex items-center gap-1">
                      <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                      </svg>
                      {personIdError}
                    </p>
                  )}
                  {formData.person_id && !personIdError && !checkingPersonId && (
                    <p className="mt-1.5 text-xs text-emerald-600 font-semibold flex items-center gap-1">
                      <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                      </svg>
                      ID is available
                    </p>
                  )}
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
                    required
                    placeholder="Enter full name"
                    className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400"
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
                    required
                    className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800"
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
                    required
                    className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800"
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
                    required
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
                    placeholder="Enter college/affiliation"
                    className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800 placeholder-slate-400"
                  />
                </div>
              </div>

              {/* Navigation Action Buttons */}
              <div className="flex gap-4 pt-4 border-t border-slate-100">
                <button
                  type="submit"
                  className="px-6 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-bold shadow-sm hover:shadow transition-all text-sm flex items-center gap-2"
                >
                  Next: Select Role
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                  </svg>
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
          ) : (
            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="flex items-center justify-between border-b border-slate-100 pb-4">
                <div>
                  <h2 className="text-xl font-bold text-slate-800">Role Selection & Details</h2>
                  <p className="text-xs text-slate-400 mt-1">Specify role details as Player or Tournament Spectator.</p>
                </div>
                <button
                  type="button"
                  onClick={() => setStep('basic')}
                  className="text-xs font-bold text-indigo-600 hover:text-indigo-800 flex items-center gap-1"
                >
                  <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
                  </svg>
                  Edit Basic Info
                </button>
              </div>

              {/* Role Select */}
              <div>
                <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
                  Role Type *
                </label>
                <select
                  name="roles"
                  value={formData.roles}
                  onChange={handleChange}
                  required
                  className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-slate-50/50 transition-all text-slate-800"
                >
                  <option value="">Select Role</option>
                  <option value="Player">Player</option>
                  <option value="Spectator">Spectator</option>
                </select>
              </div>

              {/* Player Fields */}
              {formData.roles === 'Player' && (
                <div className="border border-indigo-100 bg-indigo-50/10 rounded-xl p-5 space-y-6 animate-fadeIn">
                  <div className="border-b border-indigo-100/50 pb-2">
                    <h3 className="text-base font-bold text-indigo-950">Athletic Measurements</h3>
                    <p className="text-xs text-indigo-400 mt-0.5">Physical specs for athlete logs.</p>
                  </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label className="block text-xs font-bold uppercase tracking-wider text-indigo-900/60 mb-2">
                        Height (cm) *
                      </label>
                      <input
                        type="number"
                        name="height"
                        value={formData.height}
                        onChange={handleChange}
                        required
                        min="0"
                        step="0.01"
                        placeholder="e.g. 182.5"
                        className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-white transition-all text-slate-800 placeholder-slate-400"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-bold uppercase tracking-wider text-indigo-900/60 mb-2">
                        Weight (kg) *
                      </label>
                      <input
                        type="number"
                        name="weight"
                        value={formData.weight}
                        onChange={handleChange}
                        required
                        min="0"
                        step="0.01"
                        placeholder="e.g. 74.2"
                        className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-white transition-all text-slate-800 placeholder-slate-400"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-bold uppercase tracking-wider text-indigo-900/60 mb-2">
                        Blood Group
                      </label>
                      <select
                        name="bloodgroup"
                        value={formData.bloodgroup}
                        onChange={handleChange}
                        className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-white transition-all text-slate-800"
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
                    <div>
                      <label className="block text-xs font-bold uppercase tracking-wider text-indigo-900/60 mb-2">
                        Joining Year *
                      </label>
                      <input
                        type="number"
                        name="joining_year"
                        value={formData.joining_year}
                        onChange={handleChange}
                        required
                        min="2000"
                        max="2099"
                        placeholder="e.g. 2026"
                        className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-white transition-all text-slate-800 placeholder-slate-400"
                      />
                    </div>
                  </div>
                </div>
              )}

              {/* Spectator Fields */}
              {formData.roles === 'Spectator' && (
                <div className="border border-indigo-100 bg-indigo-50/10 rounded-xl p-5 space-y-6 animate-fadeIn">
                  <div className="border-b border-indigo-100/50 pb-2">
                    <h3 className="text-base font-bold text-indigo-950">Spectator Pass Details</h3>
                    <p className="text-xs text-indigo-400 mt-0.5">Link spectator to an upcoming tournament pass.</p>
                  </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="md:col-span-2">
                      <label className="block text-xs font-bold uppercase tracking-wider text-indigo-900/60 mb-2">
                        Select Tournament * (Upcoming Only)
                      </label>
                      {tournaments.length > 0 ? (
                        <select
                          name="tournament_id"
                          value={formData.tournament_id}
                          onChange={handleChange}
                          required
                          className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-white transition-all text-slate-800 text-sm"
                        >
                          <option value="">Select Tournament</option>
                          {tournaments.map((tournament) => {
                            const startDate = new Date(tournament.start_date).toLocaleDateString();
                            const isUpcoming = new Date(tournament.start_date) > new Date();
                            return (
                              <option key={tournament.tournament_id} value={tournament.tournament_id}>
                                ID: {tournament.tournament_id} | Start: {startDate} | {tournament.tournament_year} - {tournament.season} {isUpcoming ? '(Upcoming)' : '(Ongoing)'}
                              </option>
                            );
                          })}
                        </select>
                      ) : (
                        <div className="px-4 py-3 border border-amber-200 bg-amber-50 rounded-lg text-amber-800 text-xs flex gap-2">
                          <svg className="w-4 h-4 text-amber-500 shrink-0" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                          </svg>
                          No upcoming tournaments available. Please create a tournament first to enable registration.
                        </div>
                      )}
                    </div>
                    <div className="md:col-span-2">
                      <label className="block text-xs font-bold uppercase tracking-wider text-indigo-900/60 mb-2">
                        Pass Category Type *
                      </label>
                      <select
                        name="pass_type"
                        value={formData.pass_type}
                        onChange={handleChange}
                        required
                        className="w-full border border-slate-200 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 bg-white transition-all text-slate-800"
                      >
                        <option value="">Select Pass Type</option>
                        <option value="gold">Gold</option>
                        <option value="silver">Silver</option>
                        <option value="regular">Regular</option>
                      </select>
                    </div>
                  </div>
                </div>
              )}

              {/* Submit Buttons */}
              <div className="flex gap-4 pt-4 border-t border-slate-100">
                <button
                  type="submit"
                  disabled={loading || (formData.roles === 'Spectator' && tournaments.length === 0)}
                  className="px-6 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-bold shadow-sm hover:shadow transition-all text-sm disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center min-w-[120px]"
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
                    `Submit ${formData.roles || 'Registration'}`
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
          )}
        </div>
      </div>
    </div>
  );
};

export default PersonInsertPage;
