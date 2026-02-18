import React, { useState } from 'react';
import { Loader2, Edit3, Download } from 'lucide-react';
import { generateProposal } from '../services/proposalService';
import { generatePDFFromProposal } from '../utils/pdfGenerator';

interface ProposalSlide {
  slideNumber: number;
  slideType: string;
  title: string;
  content: string;
  visualLayout?: string;
  keyData?: string[];
  visualComponents?: string[];
}

interface ProposalPageProps {
  // Add any props you might need in the future
}

const ProposalPage: React.FC<ProposalPageProps> = () => {
  const [formData, setFormData] = useState({
    toCompany: '',
    toPerson: '',
    toRole: '',
    fromCompany: '',
    fromPerson: '',
    fromRole: ''
  });
  const [isGenerating, setIsGenerating] = useState(false);
  const [isExporting, setIsExporting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [proposalSlides, setProposalSlides] = useState<ProposalSlide[] | null>(null);
  const [proposalFileName, setProposalFileName] = useState<string>('');

  const handleInputChange = (field: string, value: string) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleCreateProposal = async () => {
    // Validate form data
    if (!formData.toCompany || !formData.toPerson || !formData.fromCompany || !formData.fromPerson) {
      setError('Please fill in all required fields (Company and Person for both Recipient and Sender)');
      return;
    }

    setIsGenerating(true);
    setError(null);

    try {
      // Generate proposal using AI
      const proposal = await generateProposal(formData);
      
      // Store the proposal for editing
      setProposalSlides(proposal.slides);
      setProposalFileName(proposal.fileName);
      
      // Success - proposal is now available for editing
    } catch (err: any) {
      console.error('Error generating proposal:', err);
      setError(err.message || 'Failed to generate proposal. Please try again.');
    } finally {
      setIsGenerating(false);
    }
  };

  const handleUpdateSlide = (slideIndex: number, field: 'title' | 'content' | 'keyData', value: string | string[]) => {
    if (!proposalSlides) return;
    
    const updatedSlides = [...proposalSlides];
    if (field === 'keyData') {
      updatedSlides[slideIndex] = {
        ...updatedSlides[slideIndex],
        keyData: Array.isArray(value) ? value : value.split('\n').filter(line => line.trim())
      };
    } else {
      updatedSlides[slideIndex] = {
        ...updatedSlides[slideIndex],
        [field]: value
      };
    }
    setProposalSlides(updatedSlides);
  };

  const handleExportPDF = async () => {
    if (!proposalSlides) {
      setError('No proposal to export. Please generate a proposal first.');
      return;
    }

    setIsExporting(true);
    setError(null);

    try {
      // Generate and download PDF using the current (possibly edited) slides
      await generatePDFFromProposal(proposalSlides, proposalFileName, formData);
    } catch (err: any) {
      console.error('Error exporting PDF:', err);
      setError(err.message || 'Failed to export PDF. Please try again.');
    } finally {
      setIsExporting(false);
    }
  };

  return (
    <div className="flex-1 flex h-full overflow-hidden bg-[#f7f8f9]">
      {/* Left Side - Form */}
      <div className="w-80 border-r border-[#e3e8ee] bg-white overflow-y-auto custom-scrollbar">
        <div className="p-6">
          <h2 className="text-lg font-bold text-[#1a1f36] mb-6">Proposal Variables</h2>
          
          <form className="space-y-6">
            {/* Recipient Section */}
            <div className="space-y-4">
              <div className="pb-2 border-b border-[#e3e8ee]">
                <h3 className="text-[13px] font-bold text-[#697386] uppercase tracking-wider">Recipient</h3>
              </div>
              
              <div className="space-y-1.5">
                <label className="text-[13px] font-bold text-[#4f566b] uppercase tracking-wider ml-1">
                  Recipient Company: {'{{To Company}}'}
                </label>
                <div className="relative group">
                  <input
                    type="text"
                    value={formData.toCompany}
                    onChange={(e) => handleInputChange('toCompany', e.target.value)}
                    className="w-full px-4 py-3 bg-white border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-medium transition-all group-hover:border-[#cbd5e1]"
                    placeholder="Enter company name"
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-[13px] font-bold text-[#4f566b] uppercase tracking-wider ml-1">
                  Recipient Person: {'{{To Person}}'}
                </label>
                <div className="relative group">
                  <input
                    type="text"
                    value={formData.toPerson}
                    onChange={(e) => handleInputChange('toPerson', e.target.value)}
                    className="w-full px-4 py-3 bg-white border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-medium transition-all group-hover:border-[#cbd5e1]"
                    placeholder="Enter person name"
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-[13px] font-bold text-[#4f566b] uppercase tracking-wider ml-1">
                  Recipient Role: {'{{To Role}}'}
                </label>
                <div className="relative group">
                  <input
                    type="text"
                    value={formData.toRole}
                    onChange={(e) => handleInputChange('toRole', e.target.value)}
                    className="w-full px-4 py-3 bg-white border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-medium transition-all group-hover:border-[#cbd5e1]"
                    placeholder="Enter role"
                  />
                </div>
              </div>
            </div>

            {/* Sender Section */}
            <div className="space-y-4 pt-4">
              <div className="pb-2 border-b border-[#e3e8ee]">
                <h3 className="text-[13px] font-bold text-[#697386] uppercase tracking-wider">Sender</h3>
              </div>
              
              <div className="space-y-1.5">
                <label className="text-[13px] font-bold text-[#4f566b] uppercase tracking-wider ml-1">
                  Sender Company: {'{{From Company}}'}
                </label>
                <div className="relative group">
                  <input
                    type="text"
                    value={formData.fromCompany}
                    onChange={(e) => handleInputChange('fromCompany', e.target.value)}
                    className="w-full px-4 py-3 bg-white border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-medium transition-all group-hover:border-[#cbd5e1]"
                    placeholder="Enter company name"
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-[13px] font-bold text-[#4f566b] uppercase tracking-wider ml-1">
                  Sender Person: {'{{From Person}}'}
                </label>
                <div className="relative group">
                  <input
                    type="text"
                    value={formData.fromPerson}
                    onChange={(e) => handleInputChange('fromPerson', e.target.value)}
                    className="w-full px-4 py-3 bg-white border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-medium transition-all group-hover:border-[#cbd5e1]"
                    placeholder="Enter person name"
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-[13px] font-bold text-[#4f566b] uppercase tracking-wider ml-1">
                  Sender Role: {'{{From Role}}'}
                </label>
                <div className="relative group">
                  <input
                    type="text"
                    value={formData.fromRole}
                    onChange={(e) => handleInputChange('fromRole', e.target.value)}
                    className="w-full px-4 py-3 bg-white border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-medium transition-all group-hover:border-[#cbd5e1]"
                    placeholder="Enter role"
                  />
                </div>
              </div>
            </div>

            {/* Create Proposal Button */}
            <div className="pt-6 mt-6 border-t border-[#e3e8ee] space-y-3">
              {error && (
                <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-red-700 text-sm">
                  {error}
                </div>
              )}
              <button
                onClick={handleCreateProposal}
                disabled={isGenerating}
                className="w-full py-4 bg-[#6366f1] text-white font-bold rounded-xl shadow-xl hover:bg-[#4f46e5] transition-all active:scale-[0.98] flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isGenerating ? (
                  <>
                    <Loader2 className="w-5 h-5 animate-spin" />
                    <span>Generating Proposal...</span>
                  </>
                ) : (
                  <span>Generate Proposal</span>
                )}
              </button>
              {proposalSlides && (
                <button
                  onClick={handleExportPDF}
                  disabled={isExporting}
                  className="w-full py-4 bg-[#10b981] text-white font-bold rounded-xl shadow-xl hover:bg-[#059669] transition-all active:scale-[0.98] flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isExporting ? (
                    <>
                      <Loader2 className="w-5 h-5 animate-spin" />
                      <span>Exporting PDF...</span>
                    </>
                  ) : (
                    <>
                      <Download className="w-5 h-5" />
                      <span>Export PDF</span>
                    </>
                  )}
                </button>
              )}
            </div>
          </form>
        </div>
      </div>

      {/* Right Side - Editable Proposal Content */}
      <div className="flex-1 overflow-y-auto custom-scrollbar bg-[#f7f8f9]">
        <div className="p-10">
          <div className="max-w-4xl mx-auto">
            {!proposalSlides ? (
              <div className="text-center py-20">
                <h1 className="text-2xl font-bold text-[#1a1f36] mb-4">Proposal</h1>
                <p className="text-[#697386]">Generate a proposal to start editing</p>
              </div>
            ) : (
              <div className="space-y-8">
                <div className="flex items-center justify-between mb-6">
                  <h1 className="text-2xl font-bold text-[#1a1f36]">Edit Proposal</h1>
                  <div className="text-sm text-[#697386]">
                    {proposalSlides.length} slides
                  </div>
                </div>
                
                {proposalSlides.map((slide, index) => (
                  <div key={slide.slideNumber} className="bg-white rounded-2xl border border-[#e3e8ee] p-8 shadow-sm">
                    <div className="mb-6 pb-4 border-b border-[#e3e8ee]">
                      <div className="flex items-center justify-between mb-2">
                        <div className="text-[11px] font-bold text-[#697386] uppercase tracking-wider">
                          Slide {slide.slideNumber} • {slide.slideType}
                        </div>
                      </div>
                      <EditableField
                        value={slide.title}
                        onChange={(value) => handleUpdateSlide(index, 'title', value)}
                        className="text-2xl font-bold text-[#1a1f36]"
                        placeholder="Slide title"
                      />
                    </div>
                    
                    <div className="space-y-4">
                      <div>
                        <label className="block text-[13px] font-bold text-[#4f566b] uppercase tracking-wider mb-2">
                          Content
                        </label>
                        <EditableTextarea
                          value={slide.content}
                          onChange={(value) => handleUpdateSlide(index, 'content', value)}
                          className="w-full min-h-[200px] px-4 py-3 bg-[#f7f8f9] border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-medium transition-all resize-y"
                          placeholder="Slide content"
                        />
                      </div>
                      
                      {slide.keyData && slide.keyData.length > 0 && (
                        <div>
                          <label className="block text-[13px] font-bold text-[#4f566b] uppercase tracking-wider mb-2">
                            Key Data Points
                          </label>
                          <EditableTextarea
                            value={slide.keyData.join('\n')}
                            onChange={(value) => handleUpdateSlide(index, 'keyData', value)}
                            className="w-full min-h-[100px] px-4 py-3 bg-[#f7f8f9] border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-mono text-sm transition-all resize-y"
                            placeholder="One data point per line"
                          />
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

// Editable Field Component
interface EditableFieldProps {
  value: string;
  onChange: (value: string) => void;
  className?: string;
  placeholder?: string;
}

const EditableField: React.FC<EditableFieldProps> = ({ value, onChange, className, placeholder }) => {
  const [isEditing, setIsEditing] = useState(false);
  const [tempValue, setTempValue] = useState(value);
  const inputRef = React.useRef<HTMLInputElement>(null);

  React.useEffect(() => {
    if (isEditing) {
      inputRef.current?.focus();
      inputRef.current?.select();
    }
  }, [isEditing]);

  React.useEffect(() => {
    setTempValue(value);
  }, [value]);

  const handleSave = () => {
    onChange(tempValue);
    setIsEditing(false);
  };

  if (isEditing) {
    return (
      <input
        ref={inputRef}
        type="text"
        value={tempValue}
        onChange={(e) => setTempValue(e.target.value)}
        onBlur={handleSave}
        onKeyDown={(e) => {
          if (e.key === 'Enter') handleSave();
          if (e.key === 'Escape') {
            setTempValue(value);
            setIsEditing(false);
          }
        }}
        className={`w-full bg-white border-2 border-[#6366f1] rounded px-2 outline-none ${className}`}
        placeholder={placeholder}
      />
    );
  }

  return (
    <div 
      onClick={() => setIsEditing(true)}
      className={`group flex items-center gap-2 cursor-pointer hover:text-[#6366f1] transition-colors ${className}`}
    >
      <span className="flex-1">{value || <span className="text-[#a3acb9] italic">{placeholder}</span>}</span>
      <Edit3 className="w-4 h-4 text-[#a3acb9] opacity-0 group-hover:opacity-100 transition-opacity shrink-0" />
    </div>
  );
};

// Editable Textarea Component
interface EditableTextareaProps {
  value: string;
  onChange: (value: string) => void;
  className?: string;
  placeholder?: string;
}

const EditableTextarea: React.FC<EditableTextareaProps> = ({ value, onChange, className, placeholder }) => {
  const [isEditing, setIsEditing] = useState(false);
  const [tempValue, setTempValue] = useState(value);
  const textareaRef = React.useRef<HTMLTextAreaElement>(null);

  React.useEffect(() => {
    if (isEditing) {
      textareaRef.current?.focus();
    }
  }, [isEditing]);

  React.useEffect(() => {
    setTempValue(value);
  }, [value]);

  const handleSave = () => {
    onChange(tempValue);
    setIsEditing(false);
  };

  if (isEditing) {
    return (
      <textarea
        ref={textareaRef}
        value={tempValue}
        onChange={(e) => setTempValue(e.target.value)}
        onBlur={handleSave}
        onKeyDown={(e) => {
          if (e.key === 'Escape') {
            setTempValue(value);
            setIsEditing(false);
          }
        }}
        className={className}
        placeholder={placeholder}
      />
    );
  }

  return (
    <div 
      onClick={() => setIsEditing(true)}
      className={`group cursor-pointer hover:border-[#6366f1] transition-colors ${className}`}
    >
      <div className="whitespace-pre-wrap min-h-[200px] p-4">
        {value || <span className="text-[#a3acb9] italic">{placeholder}</span>}
      </div>
      <div className="mt-2 flex justify-end">
        <div className="flex items-center gap-2 text-[#a3acb9] text-xs opacity-0 group-hover:opacity-100 transition-opacity">
          <Edit3 className="w-3 h-3" />
          <span>Click to edit</span>
        </div>
      </div>
    </div>
  );
};
    </div>
  );
};

export default ProposalPage;
