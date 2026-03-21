import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Phone, LogOut, Hourglass } from 'lucide-react';

const PendingApproval: React.FC = () => {
  const { currentUser, logout } = useAuth();
  const navigate = useNavigate();

  const handleCall = () => {
    window.location.href = 'tel:7039164773';
  };

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const isLoggedOut = !currentUser;
  const userName = currentUser?.name || 'User';

  return (
    <div className="min-h-screen bg-gradient-to-b from-orange-400 to-orange-600 flex items-center justify-center px-4">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-2xl p-8 text-center">
        <div className="flex justify-center mb-6">
          <div className="bg-orange-100 p-4 rounded-full">
            <Hourglass className="w-16 h-16 text-orange-600 animate-pulse" />
          </div>
        </div>
        
        <h1 className="text-2xl font-bold text-gray-800 mb-2">
          {isLoggedOut ? 'Registration Received!' : `Hello, ${userName}!`}
        </h1>
        
        <h2 className="text-xl font-semibold text-orange-600 mb-4">
          Your account is pending approval
        </h2>
        
        <p className="text-gray-600 mb-8 leading-relaxed">
          Our administrators are reviewing your registration. You will be able to access the dashboard once your account is activated.
        </p>

        <div className="space-y-4">
          <button
            onClick={handleCall}
            className="w-full flex items-center justify-center gap-2 bg-orange-600 text-white py-3 rounded-xl font-bold hover:bg-orange-700 transition-colors shadow-lg"
          >
            <Phone className="w-5 h-5" />
            Call for Quick Approval
          </button>
          
          <button
            onClick={handleLogout}
            className="w-full flex items-center justify-center gap-2 border-2 border-orange-600 text-orange-600 py-3 rounded-xl font-bold hover:bg-orange-50 transition-colors"
          >
            {isLoggedOut ? <LogOut className="w-5 h-5" /> : <LogOut className="w-5 h-5" />}
            {isLoggedOut ? 'Go to Login' : 'Back to Login'}
          </button>
        </div>
      </div>
    </div>
  );
};

export default PendingApproval;
