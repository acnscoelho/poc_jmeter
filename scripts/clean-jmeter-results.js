const fs = require('fs');
const path = require('path');

function cleanJmeterResults(inputFile, outputFile) {
  try {
    console.log(`Cleaning JMeter results from ${inputFile} to ${outputFile}`);
    
    // Read the input file
    const content = fs.readFileSync(inputFile, 'utf8');
    const lines = content.split('\n');
    
    if (lines.length === 0) {
      console.error('Input file is empty');
      process.exit(1);
    }
    
    // Get header line
    const headerLine = lines[0];
    const headers = headerLine.split(',');
    
    // Find the index of failureMessage column
    const failureMessageIndex = headers.findIndex(header => 
      header.trim().toLowerCase() === 'failuremessage'
    );
    
    if (failureMessageIndex === -1) {
      console.log('No failureMessage column found, copying file as is');
      fs.copyFileSync(inputFile, outputFile);
      return;
    }
    
    console.log(`Found failureMessage column at index ${failureMessageIndex}`);
    
    // Remove the failureMessage column from headers
    const newHeaders = headers.filter((_, index) => index !== failureMessageIndex);
    const newHeaderLine = newHeaders.join(',');
    
    // Process data lines
    const newLines = [newHeaderLine];
    
    for (let i = 1; i < lines.length; i++) {
      const line = lines[i];
      if (line.trim() === '') continue;
      
      const values = line.split(',');
      if (values.length > failureMessageIndex) {
        // Remove the failureMessage value
        const newValues = values.filter((_, index) => index !== failureMessageIndex);
        newLines.push(newValues.join(','));
      } else {
        // Line doesn't have enough columns, keep as is
        newLines.push(line);
      }
    }
    
    // Write the cleaned content
    fs.writeFileSync(outputFile, newLines.join('\n'));
    console.log(`Successfully cleaned JMeter results. Output written to ${outputFile}`);
    
  } catch (error) {
    console.error('Error cleaning JMeter results:', error.message);
    process.exit(1);
  }
}

// Get command line arguments
const args = process.argv.slice(2);
if (args.length !== 2) {
  console.error('Usage: node clean-jmeter-results.js <input-file> <output-file>');
  process.exit(1);
}

const [inputFile, outputFile] = args;

// Validate input file exists
if (!fs.existsSync(inputFile)) {
  console.error(`Input file does not exist: ${inputFile}`);
  process.exit(1);
}

cleanJmeterResults(inputFile, outputFile); 