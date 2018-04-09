%MEASDEMO Demonstrates a complete measurement using the 
%    Agilent Technologies 89600 Vector Signal Analyzer Application.
%
%    This routine creates, sets up, starts a measurement, reads
%    frequency and voltage data, plots the data, and quits the application,
%    if one was created by the routince. If the routine attached to a
%    running instance of the VSA application, the routine returns without 
%    quitting it.
%
%    Normally all these steps would be combined into one routine.
%    In paticular, the creation of the 89600 app would normally be done
%    only once and kept around until the application is done.
%
%    Type 'MeasDemo' to see it run.


% Load Agilent.Sa.Vsa.Interfaces assembly
% Assumption is that this demo is run from the Examples\DotNet\Matlab
% direction and that the Agilent.Sa.Vsa.Interfaces assembly is location
% under the Examples\DotNet\Interfaces directory.
cd ..
asmPath = strcat(pwd, '\Interfaces\');
cd Matlab;
asmName = 'Agilent.SA.Vsa.Interfaces.dll';
asm = NET.addAssembly(strcat(asmPath, asmName));
import Agilent.SA.Vsa.*;

% Attach to a running instance of VSA. If there no running instance, 
% create one.
vsaApp = ApplicationFactory.Create();
if (isempty(vsaApp))
    wasVsaRunning = false;
    vsaApp = ApplicationFactory.Create(true, '', '', -1);
else
    wasVsaRunning = true;
end

% Make VSA visible
vsaApp.IsVisible = true;

% Label analyzer display
vsaApp.Title = 'Measurement Demo';

% Get interfaces to major items
vsaMeas = vsaApp.Measurements.SelectedItem;
vsaDisp = vsaApp.Display;

% Preset to defaults
vsaDisp.Preset;
vsaMeas.Preset;
vsaMeas.Reset;

% Set center frequency and span
vsaFreq = vsaMeas.Frequency;
vsaFreq.Center = 1e9;
vsaFreq.Span = 5e6;

% Set input range
vsaInputAnalog = vsaMeas.Input.Analog;
vsaInputAnalog.Range = 1;

% The default trace 1 shows a spectrum.
% Set trace 1 to display volts so the upcoming read will return volts.
vsaTrace0 = vsaDisp.Traces.Item(0);
vsaTrace0.Format = TraceFormatType.LinearMagnitude;

% set for single measurement
vsaMeas.IsContinuous = false;

% start measurement
vsaMeas.Restart;

% wait for measdone, but don't bother it too often
% Set timeout to 5 seconds
bMeasDone = 0;
t0=clock;
vsaMeasStatus = vsaMeas.Status;
while(bMeasDone==0 & etime(clock,t0)<=5)
   pause(.1);
   if (verLessThan('matlab', '7.12'))  % earlier than R2011a
       value = EnumUtilities.GetEnumAsInt32(vsaMeasStatus, 'Value');
       bMeasDone = bitand(uint32(value), uint32(StatusBits.MeasurementDone));
   else  % R2011a or later (no support for calling uint32 on enums)
       bMeasDone = eq(StatusBits.MeasurementDone, bitand(vsaMeasStatus.Value, StatusBits.MeasurementDone));
   end
end

% check if meas was stuck
if bMeasDone == 0
	error('Measurement failed to complete');   
end

% pretty up the displays
vsaTrace0.YScaleAuto;
vsaTrace1 = vsaDisp.Traces.Item(1);
vsaTrace1.YScaleAuto;

% Get X-axis (frequency) data 
xData = vsaTrace0.DoubleData(TraceDataSelect.X, false);
% Get Y-axis (Amplitude) date
yData = vsaTrace0.DoubleData(TraceDataSelect.Y, false);
% Plot frequencies and voltages
plot(xData.double, abs(yData.double));
xlabel('Freq');
ylabel('Vrms');

%  Quit VSA if it was started by the demo
if (~wasVsaRunning)
    vsaApp.Quit;
end

% Delete objects
vsaApp.delete;
vsaDisp.delete;
vsaFreq.delete;
vsaInputAnalog.delete;
vsaMeas.delete;
vsaMeasStatus.delete;
vsaTrace0.delete;
vsaTrace1.delete;

% Clear variables from workspace
clear vsaApp vsaDisp vsaFreq vsaInputAnalog vsaMeas vsaMeasStatus vsaTrace0 vsaTrace1;
clear asm asmName asmPath;
clear bMeasDone t0 value wasVsaRunning xData yData;
