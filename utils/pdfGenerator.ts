interface ProposalSlide {
  slideNumber: number;
  slideType: string;
  title: string;
  content: string;
  visualLayout?: string;
  keyData?: string[];
  visualComponents?: string[];
}

/**
 * Generates a PDF from proposal slides using browser's print functionality
 * This creates a downloadable PDF by rendering HTML content
 */
export const generatePDFFromProposal = async (
  slides: ProposalSlide[],
  fileName: string,
  formData: {
    toCompany: string;
    toPerson: string;
    toRole: string;
    fromCompany: string;
    fromPerson: string;
    fromRole: string;
  }
): Promise<void> => {
  // Create a hidden container for PDF generation
  const printWindow = window.open('', '_blank');
  if (!printWindow) {
    throw new Error('Failed to open print window. Please allow popups.');
  }

  // Build HTML content with branding
  const htmlContent = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${fileName}</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;700;900&display=swap" rel="stylesheet">
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    body {
      font-family: 'Inter', sans-serif;
      background: #020617;
      color: #000000;
      padding: 0;
      margin: 0;
    }
    
    .slide {
      width: 100%;
      min-height: 100vh;
      background: #FFFFFF;
      padding: 80px;
      page-break-after: always;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }
    
    .slide:last-child {
      page-break-after: auto;
    }
    
    .slide-header {
      font-weight: 900;
      font-size: 64px;
      line-height: 1.1;
      letter-spacing: -0.02em;
      color: #000000;
      margin-bottom: 48px;
    }
    
    .slide-subheader {
      font-weight: 700;
      font-size: 24px;
      color: #000000;
      margin-bottom: 32px;
    }
    
    .slide-content {
      font-weight: 300;
      font-size: 18px;
      line-height: 1.6;
      color: #475569;
      flex: 1;
    }
    
    .slide-meta {
      font-weight: 700;
      font-size: 10px;
      text-transform: uppercase;
      letter-spacing: 0.2em;
      color: #94a3b8;
      margin-bottom: 16px;
    }
    
    .key-data {
      background: #F1F5F9;
      border-radius: 48px;
      padding: 32px;
      margin: 24px 0;
    }
    
    .key-data-item {
      font-family: monospace;
      font-size: 14px;
      color: #000000;
      margin: 8px 0;
    }
    
    .gradient-accent {
      background: linear-gradient(135deg, #6366f1 0%, #a855f7 50%, #ec4899 100%);
      height: 4px;
      border-radius: 2px;
      margin: 24px 0;
    }
    
    .cover-slide {
      background: linear-gradient(135deg, #020617 0%, #1e293b 100%);
      color: #FFFFFF;
      justify-content: center;
      align-items: center;
      text-align: center;
    }
    
    .cover-slide .slide-header {
      color: #FFFFFF;
      margin-bottom: 24px;
    }
    
    .cover-slide .slide-content {
      color: #E2E8F0;
    }
    
    .cover-info {
      margin-top: 48px;
      font-weight: 300;
      font-size: 18px;
      color: #E2E8F0;
    }
    
    .cover-info strong {
      font-weight: 700;
      color: #FFFFFF;
    }
    
    @media print {
      body {
        background: #FFFFFF;
      }
      
      .slide {
        page-break-after: always;
        page-break-inside: avoid;
      }
    }
  </style>
</head>
<body>
  ${slides.map((slide, index) => {
    const isCover = index === 0;
    return `
    <div class="slide ${isCover ? 'cover-slide' : ''}">
      ${isCover ? `
        <div>
          <div class="slide-header">Predictive Intelligence<br/>Flywheel Dashboard</div>
          <div class="gradient-accent" style="width: 200px; margin: 24px auto;"></div>
          <div class="cover-info">
            <p><strong>Prepared for:</strong> ${formData.toCompany}</p>
            <p><strong>Attention:</strong> ${formData.toPerson}, ${formData.toRole}</p>
            <br/>
            <p><strong>Prepared by:</strong></p>
            <p>${formData.fromPerson}</p>
            <p>${formData.fromRole}</p>
            <p>${formData.fromCompany}</p>
          </div>
        </div>
      ` : `
        <div>
          ${slide.slideType ? `<div class="slide-meta">${slide.slideType}</div>` : ''}
          <div class="slide-subheader">${slide.title}</div>
          ${slide.keyData && slide.keyData.length > 0 ? `
            <div class="key-data">
              ${slide.keyData.map(item => `<div class="key-data-item">${item}</div>`).join('')}
            </div>
          ` : ''}
          <div class="slide-content">${slide.content.split('\n').map(p => `<p style="margin-bottom: 16px;">${p}</p>`).join('')}</div>
        </div>
      `}
    </div>
    `;
  }).join('')}
</body>
</html>
  `;

  printWindow.document.write(htmlContent);
  printWindow.document.close();

  // Wait for content to load, then trigger print
  setTimeout(() => {
    printWindow.print();
    // Close window after a delay (user may cancel print)
    setTimeout(() => {
      printWindow.close();
    }, 1000);
  }, 500);
};

/**
 * Alternative: Generate PDF using jsPDF (requires library)
 * This is a placeholder for when jsPDF is added to the project
 */
export const generatePDFWithJsPDF = async (
  slides: ProposalSlide[],
  fileName: string
): Promise<void> => {
  // This would require installing jsPDF: npm install jspdf
  // For now, we'll use the print method above
  throw new Error('jsPDF method not implemented. Use generatePDFFromProposal instead.');
};
