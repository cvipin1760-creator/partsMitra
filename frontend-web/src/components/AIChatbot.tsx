import React, { useState, useRef, useEffect } from 'react';
import api from '../services/api';
import { MessageSquare, Send, X, Bot, User, Loader2 } from 'lucide-react';

interface Message {
  text: string;
  isBot: boolean;
}

const AIChatbot: React.FC = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [messages, setMessages] = useState<Message[]>([
    { text: "Hello! I'm your Spares Hub AI assistant. How can I help you today?", isBot: true }
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSend = async () => {
    if (!input.trim()) return;

    const userMessage = { text: input, isBot: false };
    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setLoading(true);

    try {
      const res = await api.post('/ai/chat', { prompt: input });
      const botMessage = { text: res.data.response, isBot: true };
      setMessages(prev => [...prev, botMessage]);
    } catch (error) {
      console.error('AI Chat Error:', error);
      const errorMessage = { text: "Sorry, I'm having trouble connecting to my brain right now.", isBot: true };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed bottom-6 right-6 z-[100]">
      {isOpen ? (
        <div className="bg-white rounded-3xl shadow-2xl border border-gray-100 w-[340px] md:w-[400px] flex flex-col h-[550px] overflow-hidden transition-all duration-500 animate-in slide-in-from-bottom-12">
          {/* Header */}
          <div className="bg-gradient-to-br from-blue-600 to-blue-500 p-5 flex items-center justify-between text-white shadow-lg relative overflow-hidden">
            <div className="absolute top-0 right-0 p-4 opacity-10">
              <Bot size={80} />
            </div>
            <div className="flex items-center gap-3 relative z-10">
              <div className="bg-white/20 p-2 rounded-xl backdrop-blur-sm">
                <Bot className="w-6 h-6" />
              </div>
              <div>
                <h3 className="font-bold text-lg leading-tight">Spares Hub AI</h3>
                <p className="text-blue-100 text-[10px] font-medium uppercase tracking-widest flex items-center gap-1.5">
                  <span className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></span>
                  Always Active
                </p>
              </div>
            </div>
            <button 
              onClick={(e) => {
                e.preventDefault();
                e.stopPropagation();
                setIsOpen(false);
              }} 
              className="hover:bg-white/20 p-2.5 rounded-2xl transition-all duration-300 active:scale-75 z-20 group/close cursor-pointer"
              aria-label="Close Chat"
            >
              <X className="w-6 h-6 text-white group-hover/close:rotate-90 transition-transform duration-300" />
            </button>
          </div>

          {/* Messages */}
          <div className="flex-grow p-5 overflow-y-auto space-y-5 bg-slate-50/50">
            {messages.map((msg, idx) => (
              <div key={idx} className={`flex ${msg.isBot ? 'justify-start' : 'justify-end'} animate-in fade-in slide-in-from-bottom-2 duration-300`}>
                <div className={`max-w-[85%] p-4 rounded-2xl text-[13px] leading-relaxed shadow-sm transition-all ${
                  msg.isBot 
                    ? 'bg-white border border-gray-100 text-slate-700 rounded-tl-none ring-1 ring-black/5' 
                    : 'bg-blue-600 text-white rounded-tr-none shadow-blue-200 shadow-md'
                }`}>
                  <div className={`flex items-center gap-1.5 mb-1.5 opacity-50 text-[9px] font-bold uppercase tracking-wider ${msg.isBot ? 'text-blue-600' : 'text-blue-50'}`}>
                    {msg.isBot ? <Bot className="w-3 h-3" /> : <User className="w-3 h-3" />}
                    {msg.isBot ? 'Assistant' : 'You'}
                  </div>
                  {msg.text}
                </div>
              </div>
            ))}
            {loading && (
              <div className="flex justify-start animate-pulse">
                <div className="bg-white border border-gray-100 p-4 rounded-2xl rounded-tl-none shadow-sm ring-1 ring-black/5 flex items-center gap-3">
                  <div className="flex gap-1">
                    <span className="w-1.5 h-1.5 bg-blue-400 rounded-full animate-bounce"></span>
                    <span className="w-1.5 h-1.5 bg-blue-400 rounded-full animate-bounce [animation-delay:0.2s]"></span>
                    <span className="w-1.5 h-1.5 bg-blue-400 rounded-full animate-bounce [animation-delay:0.4s]"></span>
                  </div>
                  <span className="text-[11px] text-slate-400 font-medium tracking-tight">AI is crafting a response...</span>
                </div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          {/* Input */}
          <div className="p-5 bg-white border-t border-slate-100">
            <div className="flex items-center gap-2 bg-slate-50 p-1.5 rounded-2xl border border-slate-200 focus-within:border-blue-400 focus-within:ring-4 focus-within:ring-blue-50 transition-all duration-300">
              <input
                type="text"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && handleSend()}
                placeholder="How can I help you today?"
                className="flex-grow bg-transparent border-none focus:outline-none text-sm px-3 py-2 text-slate-700 placeholder:text-slate-400"
                disabled={loading}
              />
              <button 
                onClick={handleSend}
                disabled={loading || !input.trim()}
                className={`p-2.5 rounded-xl transition-all duration-300 active:scale-95 ${
                  input.trim() ? 'bg-blue-600 text-white shadow-lg shadow-blue-200 hover:bg-blue-700' : 'bg-slate-200 text-slate-400'
                }`}
              >
                <Send className="w-4 h-4" />
              </button>
            </div>
            <p className="text-center text-[9px] text-slate-400 mt-3 font-medium uppercase tracking-tighter">Powered by Spares Hub AI Engine</p>
          </div>
        </div>
      ) : (
        <div className="flex flex-col items-end gap-3 group">
          <div className="bg-slate-900 text-white text-[11px] font-bold px-4 py-2.5 rounded-2xl opacity-0 translate-y-2 group-hover:opacity-100 group-hover:translate-y-0 transition-all duration-300 shadow-2xl pointer-events-none relative mb-1">
            Need help with parts? Ask AI
            <div className="absolute bottom-[-6px] right-6 w-3 h-3 bg-slate-900 rotate-45"></div>
          </div>
          <button
            onClick={() => setIsOpen(true)}
            className="bg-gradient-to-br from-blue-600 to-blue-500 text-white p-5 rounded-3xl shadow-2xl hover:shadow-blue-200/50 hover:scale-110 transition-all duration-500 active:scale-95 relative"
          >
            <MessageSquare className="w-7 h-7" />
            <span className="absolute -top-1 -right-1 w-4 h-4 bg-green-500 border-2 border-white rounded-full"></span>
          </button>
        </div>
      )}
    </div>
  );
};

export default AIChatbot;
