% --- Serial Setup ---
if exist('esp32', 'var')
    clear esp32; 
end

try
    % Adjust COM port to match your Device Manager
    esp32 = serialport("COM3", 115200); 
    configureTerminator(esp32, "CR/LF");
catch
    error('Could not open port. Ensure ESP32 is connected and Serial Monitor is closed.');
end

% --- GUI Setup ---
fig = uifigure('Name', 'ServoScope Pro: Ultra-Wide & Fast Response', 'Position', [100 50 900 800], 'Color', [0.12 0.12 0.12]);

% Main control panel
ctrlPanel = uipanel(fig, 'Title', 'Control Panel', 'Position', [20 620 860 160], 'BackgroundColor', [0.18 0.18 0.18], 'ForegroundColor', 'w', 'FontWeight', 'bold');

% Start/Stop and Waveform selection
uibutton(ctrlPanel, 'Text', 'START', 'Position', [30 30 140 45], 'BackgroundColor', [0.2 0.5 0.2], 'FontColor', 'w', 'ButtonPushedFcn', @(btn, event) writeline(esp32, "P"));
uibutton(ctrlPanel, 'Text', 'STOP', 'Position', [190 30 140 45], 'BackgroundColor', [0.6 0.2 0.2], 'FontColor', 'w', 'ButtonPushedFcn', @(btn, event) writeline(esp32, "O"));

uibutton(ctrlPanel, 'Text', 'SINE', 'Position', [30 90 100 40], 'ButtonPushedFcn', @(btn, event) writeline(esp32, "S"));
uibutton(ctrlPanel, 'Text', 'SQUARE', 'Position', [140 90 100 40], 'ButtonPushedFcn', @(btn, event) writeline(esp32, "D"));
uibutton(ctrlPanel, 'Text', 'TRIANGLE', 'Position', [250 90 100 40], 'ButtonPushedFcn', @(btn, event) writeline(esp32, "T"));

% Frequency slider (0.1 - 4.0 Hz)
lblFreq = uilabel(ctrlPanel, 'Text', 'Frequency: 1.0 Hz', 'Position', [400 100 150 22], 'FontColor', 'w');
sld = uislider(ctrlPanel, 'Position', [400 70 200 3], 'Limits', [0.1 4], 'Value', 1);
sld.ValueChangedFcn = @(sld, event) updateFreq(sld, lblFreq, esp32);

lblVolt = uilabel(ctrlPanel, 'Text', '0.00 V', 'Position', [650 30 150 80], 'FontColor', [0 1 0.8], 'FontSize', 40, 'FontWeight', 'bold');

% --- Oscilloscope Panel (Ultra-Wide View) ---
axTime = uiaxes(fig, 'Position', [20 320 860 280], 'Color', 'k', 'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7]);
title(axTime, 'Oscilloscope (Ultra-Wide 500ms Window)', 'Color', 'w');
ylabel(axTime, 'Voltage (V)', 'Color', 'w');
xlabel(axTime, 'Time (ms)', 'Color', 'w');
ylim(axTime, [-0.2 3.5]); grid(axTime, 'on'); axTime.GridColor = [0.3 0.3 0.3];

% Configuration for width and speed
timeWindow_ms = 500;    % 500ms makes the 1Hz wave look very wide
fftBufferLen = 2000;     % Smaller buffer = Faster FFT updates

xlim(axTime, [0, timeWindow_ms]);
timePoints = round(timeWindow_ms / 5); % Assuming ~200Hz sampling
timeX = linspace(0, timeWindow_ms, timePoints);
hLineTime = plot(axTime, timeX, nan(1, timePoints), 'Color', [0 1 0.8], 'LineWidth', 2.5);

% --- Spectrum Analyzer Panel (Fast FFT) ---
axFreq = uiaxes(fig, 'Position', [20 20 860 280], 'Color', 'k', 'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7]);
title(axFreq, 'Spectrum Analyzer (High Precision 0-12 Hz)', 'Color', 'w');
xlabel(axFreq, 'Frequency (Hz)', 'Color', 'w');
ylabel(axFreq, 'Amplitude', 'Color', 'w');

xlim(axFreq, [0 12]);
ylim(axFreq, [0 2]); grid(axFreq, 'on'); axFreq.GridColor = [0.3 0.3 0.3];
hLineFreq = stem(axFreq, nan, nan, 'Color', [1 0.5 0], 'Marker', 'none', 'LineWidth', 2);

% --- Main Acquisition Loop ---
voltageBuffer = zeros(1, fftBufferLen);

while ishandle(fig)
    try
        newData = false;
        count = 0;
        
        % Read data from serial
        while esp32.NumBytesAvailable > 0 && count < 60
            raw = readline(esp32);
            val = (str2double(raw) * 3.3) / 4095;
            if ~isnan(val)
                voltageBuffer = [voltageBuffer(2:end), val];
                newData = true;
            end
            count = count + 1;
        end
        
        if newData
            % 1. Update Oscilloscope (showing only the last 500ms worth of points)
            currentVoltage = voltageBuffer(end-timePoints+1:end);
            set(hLineTime, 'YData', currentVoltage);
            lblVolt.Text = sprintf('%.2f V', currentVoltage(end));
            
            % 2. Update FFT (Rapid Response)
            Fs = 200; 
            L = fftBufferLen;
            
            cleanSignal = voltageBuffer - mean(voltageBuffer); 
            Y = fft(cleanSignal);
            P2 = abs(Y/L);
            P1 = P2(1:floor(L/2)+1);
            P1(2:end-1) = 2*P1(2:end-1);
            freqBins = Fs*(0:floor(L/2))/L;
            
            set(hLineFreq, 'XData', freqBins, 'YData', P1);
            
            drawnow limitrate;
        end
        pause(0.01);
    catch
        % Minor serial error handling
    end
end

if exist('esp32', 'var'), clear esp32; end

% --- Helper Functions ---
function updateFreq(sld, lbl, esp32)
    fVal = round(sld.Value, 1);
    lbl.Text = sprintf('Frequency: %.1f Hz', fVal);
    try 
        writeline(esp32, "F:" + string(fVal)); 
    catch 
    end
end