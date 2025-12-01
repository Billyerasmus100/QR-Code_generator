import React, { useState } from 'react';
import QRCode from 'qrcode';
import './App.css';

function App() {
  const [fields, setFields] = useState([
    { label: 'MAC Address', value: '' },
    { label: 'Serial Number', value: '' }
  ]);
  const [qrCodeUrl, setQrCodeUrl] = useState('');

  const addField = () => {
    setFields([...fields, { label: '', value: '' }]);
  };

  const removeField = (index) => {
    const newFields = fields.filter((_, i) => i !== index);
    setFields(newFields);
  };

  const updateField = (index, key, value) => {
    const newFields = [...fields];
    newFields[index][key] = value;
    setFields(newFields);
  };

  const generateQRCode = async () => {
    const validFields = fields.filter(f => f.label.trim() && f.value.trim());
    
    if (validFields.length === 0) {
      alert('Please add at least one field with both label and value');
      return;
    }

    const data = {};
    validFields.forEach(field => {
      data[field.label] = field.value;
    });

    const qrData = JSON.stringify(data, null, 2);

    try {
      const url = await QRCode.toDataURL(qrData, {
        width: 400,
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      });
      setQrCodeUrl(url);
    } catch (err) {
      console.error('Error generating QR code:', err);
      alert('Error generating QR code');
    }
  };

  const downloadQRCode = () => {
    if (!qrCodeUrl) {
      alert('Please generate a QR code first');
      return;
    }

    const link = document.createElement('a');
    link.download = 'qrcode.png';
    link.href = qrCodeUrl;
    link.click();
  };

  const clearAll = () => {
    setFields([
      { label: 'MAC Address', value: '' },
      { label: 'Serial Number', value: '' }
    ]);
    setQrCodeUrl('');
  };

  return (
    <div className="app">
      <div className="container">
        <div className="card">
          <h1>QR Code Generator</h1>
          <p className="subtitle">Create QR codes with multiple data fields</p>

          <div className="grid">
            {/* Left Panel - Input Fields */}
            <div className="input-section">
              <div className="section-header">
                <h2>Data Fields</h2>
                <button onClick={addField} className="btn btn-primary btn-sm">
                  + Add Field
                </button>
              </div>

              <div className="fields-container">
                {fields.map((field, index) => (
                  <div key={index} className="field-card">
                    <div className="field-header">
                      <span className="field-label">Field {index + 1}</span>
                      {fields.length > 1 && (
                        <button
                          onClick={() => removeField(index)}
                          className="btn-remove"
                        >
                          Remove
                        </button>
                      )}
                    </div>
                    <div className="field-inputs">
                      <input
                        type="text"
                        placeholder="Label (e.g., MAC Address)"
                        value={field.label}
                        onChange={(e) => updateField(index, 'label', e.target.value)}
                        className="input"
                      />
                      <input
                        type="text"
                        placeholder="Value (e.g., 00:1A:2B:3C:4D:5E)"
                        value={field.value}
                        onChange={(e) => updateField(index, 'value', e.target.value)}
                        className="input"
                      />
                    </div>
                  </div>
                ))}
              </div>

              <div className="button-group">
                <button onClick={generateQRCode} className="btn btn-primary btn-lg">
                  Generate QR Code
                </button>
                <button onClick={clearAll} className="btn btn-secondary btn-lg">
                  Clear
                </button>
              </div>
            </div>

            {/* Right Panel - QR Code Preview */}
            <div className="preview-section">
              <h2>Preview</h2>
              <div className="preview-container">
                {qrCodeUrl ? (
                  <>
                    <img 
                      src={qrCodeUrl} 
                      alt="QR Code" 
                      className="qr-image"
                    />
                    <button onClick={downloadQRCode} className="btn btn-success btn-lg">
                      <svg className="icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                      </svg>
                      Download QR Code
                    </button>
                  </>
                ) : (
                  <div className="preview-placeholder">
                    <svg className="placeholder-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z" />
                    </svg>
                    <p className="placeholder-title">No QR code generated yet</p>
                    <p className="placeholder-text">Fill in the fields and click "Generate"</p>
                  </div>
                )}
              </div>

              {qrCodeUrl && (
                <div className="info-box">
                  <p>
                    <strong>Tip:</strong> This QR code contains JSON data with all your fields. Scan it to retrieve the information.
                  </p>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Info Section */}
        <div className="guide-card">
          <h3>Quick Guide</h3>
          <div className="guide-grid">
            <div className="guide-item">
              <span className="guide-number">1.</span>
              <span>Enter labels and values for your data fields</span>
            </div>
            <div className="guide-item">
              <span className="guide-number">2.</span>
              <span>Click "Add Field" to add more fields</span>
            </div>
            <div className="guide-item">
              <span className="guide-number">3.</span>
              <span>Click "Generate QR Code" to create it</span>
            </div>
            <div className="guide-item">
              <span className="guide-number">4.</span>
              <span>Preview and download as PNG</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
