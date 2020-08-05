function test_suite = test_saveEventsFileSave %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_saveEventsFileSaveBasic()

    outputDir = fullfile(fileparts(mfilename('fullpath')), '..', 'output');

    %% set up

    cfg.verbose = false;

    cfg.subject.subjectNb = 1;
    cfg.subject.runNb = 1;

    cfg.task.name = 'testtask';

    cfg.dir.output = outputDir;

    cfg.testingDevice = 'mri';

    cfg = createFilename(cfg);

    logFile.extraColumns.Speed.length = 1;
    logFile.extraColumns.LHL24.length = 12;
    logFile.extraColumns.is_Fixation.length = 1;

    % create the events file and header
    logFile = saveEventsFile('open', cfg, logFile);

    % ROW 2: normal events : all info is there
    logFile(1, 1).onset = 2;
    logFile(end, 1).trial_type = 'motion_up';
    logFile(end, 1).duration = 3;
    logFile(end, 1).Speed = 2;
    logFile(end, 1).is_Fixation = true;
    logFile(end, 1).LHL24 = 1:12;

    logFile = saveEventsFile('save', cfg, logFile);

    % ROW 3: missing info (speed, LHL24)
    logFile(1, 1).onset = 3;
    logFile(end, 1).trial_type = 'static';
    logFile(end, 1).duration = 4;
    logFile(end, 1).is_Fixation = false;

    % ROW 4: missing info (duration is missing and speed is empty)
    logFile(2, 1).onset = 4;
    logFile(end, 1).trial_type = 'motion_up';
    logFile(end, 1).Speed = [];
    logFile(end, 1).is_Fixation = true;
    logFile(end, 1).LHL24 = 1:12;

    % empty events
    logFile(3, 1).onset = [];
    logFile(end, 1).trial_type = [];
    logFile(end, 1).duration = 3;

    logFile(4, 1).onset = 1;
    logFile(end, 1).trial_type = '';

    % ROW 5: missing info (array is too short)
    logFile(5, 1).onset = 5;
    logFile(end, 1).trial_type = 'jazz';
    logFile(end, 1).duration = 3;
    logFile(end, 1).LHL24 = rand(1, 10);

    % ROW 6: too much info (array is too long)
    %     logFile(5, 1).onset = 5;
    %     logFile(end, 1).trial_type = 'blues';
    %     logFile(end, 1).duration = 3;
    %     logFile(end, 1).LHL24 = rand(1, 15);

    saveEventsFile('save', cfg, logFile);

    % close the file
    saveEventsFile('close', cfg, logFile);

    %% test

    % check the extra columns of the header and some of the content
    nbExtraCol = ...
        logFile(1).extraColumns.Speed.length + ...
        logFile(1).extraColumns.LHL24.length + ...
        logFile(1).extraColumns.is_Fixation.length;

    funcDir = fullfile(cfg.dir.outputSubject, cfg.fileName.modality);

    eventFilename = cfg.fileName.events;

    FID = fopen(fullfile(funcDir, eventFilename), 'r');
    C = textscan(FID, repmat('%s', 1, nbExtraCol + 3), 'Delimiter', '\t', 'EndOfLine', '\n');

    % event 1/ ROW 2: check that values are entered correctly
    assertEqual(C{1}{2}, sprintf('%f', 2));
    assertEqual(C{3}{2}, 'motion_up');
    assertEqual(C{2}{2}, sprintf('%f', 3));
    assertEqual(C{4}{2}, sprintf('%f', 2));
    assertEqual(C{5}{2}, sprintf('%f', 1));
    assertEqual(C{16}{2}, sprintf('%f', 12));
    assertEqual(C{17}{2}, 'true');

    % event 2 / ROW 3: missing info replaced by nans
    assertEqual(C{4}{3}, 'n/a');
    assertEqual(C{5}{3}, 'n/a');
    assertEqual(C{16}{3}, 'n/a');
    assertEqual(C{17}{3}, 'false');

    % event 3 / ROW 4: missing info (duration is missing and speed is empty)
    assertEqual(C{2}{4}, 'n/a');
    assertEqual(C{4}{4}, 'n/a');

    % event 4-5 / ROW 5-6: skip empty events
    assertTrue(~isequal(C{1}{5}, 'n/a'));

    % check values entered properly
    assertEqual(C{15}{5}, 'n/a');
    assertEqual(C{16}{5}, 'n/a');

end
