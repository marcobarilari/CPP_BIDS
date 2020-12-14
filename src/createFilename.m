% (C) Copyright 2020 CPP_BIDS developers

function cfg = createFilename(cfg)
    % cfg = createFilename(cfg)
    %
    % create the BIDS compliant directories and fileNames for the behavioral output
    % for this subject / session / run using the information from cfg and expParameters.
    % Will also create the right fileName for the eyetracking data file.
    %
    % For the moment the date of acquisition is appended to the fileName
    %
    % can work for behavioral experiment if cfg.device is set to 'PC'
    % can work for fMRI experiment if cfg.device is set to 'scanner'
    % can work for simple eyetracking data if cfg.eyeTracker.do is set to 1
    %
    %
    % See test_createFilename in the test folder for more details on how to use it.

    cfg = checkCFG(cfg);

    cfg.fileName.pattern = ['%0' num2str(cfg.fileName.zeroPadding) '.0f'];
    cfg.fileName.date = datestr(now, cfg.fileName.dateFormat);

    if ~isfield(cfg, 'task')
        error('createFilename: missing a task name. i.e cfg.task.name');
    end

    cfg = getModality(cfg);

    cfg = createDirectories(cfg);

    cfg = setSuffixes(cfg);

    cfg = setFilenames(cfg);

    talkToMe(cfg);

    cfg = orderfields(cfg);
    cfg.fileName = orderfields(cfg.fileName);
    cfg.dir = orderfields(cfg.dir);

end

function cfg = getModality(cfg)

    switch lower(cfg.testingDevice)
        case 'pc'
            modality = 'beh';
        case 'mri'
            modality = 'func';
        case 'eeg'
            modality = 'eeg';
        case 'ieeg'
            modality = 'ieeg';
        case 'meg'
            modality = 'meg';
        otherwise
            modality = 'beh';
    end

    cfg.fileName.modality = modality;

end

function [subjectGrp, subjectNb, sessionNb, modality, taskName] = extractInput(cfg)

    subjectGrp = cfg.subject.subjectGrp;
    subjectNb = cfg.subject.subjectNb;
    sessionNb = cfg.subject.sessionNb;
    modality = cfg.fileName.modality;
    taskName = cfg.fileName.task;

    if isempty(sessionNb)
        sessionNb = 1;
    end

end

function cfg = createDirectories(cfg)

    [subjectGrp, subjectNb, sessionNb, modality] = extractInput(cfg);

    pattern = cfg.fileName.pattern;

    % output dir
    cfg.dir.outputSubject = fullfile ( ...
                                      cfg.dir.output, ...
                                      'source', ...
                                      ['sub-' subjectGrp, sprintf(pattern, subjectNb)], ...
                                      ['ses-', sprintf(pattern, sessionNb)]);

    [~, ~, ~] = mkdir(cfg.dir.output);
    [~, ~, ~] = mkdir(cfg.dir.outputSubject);
    [~, ~, ~] = mkdir(fullfile(cfg.dir.outputSubject, modality));

end

function cfg = setSuffixes(cfg)

    cfg.fileName.suffix.run = ['_run-' sprintf(cfg.fileName.pattern, cfg.subject.runNb)];

    %% MRI
    % set values for the suffixes for the different fields in the BIDS name
    fields2Check = { ...
                    'acquisition', ...
                    'contrastEnhancement', ...
                    'echo', ...
                    'phaseEncodingDirection', ...
                    'reconstruction', ...
                    'recording' ...
                   };

    targetFields = { ...
                    'acq', ...
                    'ce', ...
                    'echo', ...
                    'dir', ...
                    'rec', ...
                    'recording' ...
                   };

    for iField = 1:numel(fields2Check)

        if isempty (cfg.suffix.(fields2Check{iField})) %#ok<*GFLD>

            cfg.fileName.suffix.(fields2Check{iField}) = ''; %#ok<*SFLD>

        else

            % upper camelCase and remove invalid characters
            thisField = getfield(cfg.suffix, fields2Check{iField});
            [~, validFieldName] = createValidName(thisField);

            cfg.fileName.suffix.(fields2Check{iField}) = ...
                ['_' targetFields{iField} '-' validFieldName];

        end
    end

    cfg.fileName.suffix = orderfields(cfg.fileName.suffix);

end

function cfg = setFilenames(cfg)

    [subjectGrp, subjectNb, sessionNb, modality, taskName] = extractInput(cfg);

    pattern = cfg.fileName.pattern;

    runSuffix = cfg.fileName.suffix.run;
    acqSuffix = cfg.fileName.suffix.acquisition;
    ceSuffix = cfg.fileName.suffix.contrastEnhancement;
    dirSuffix = cfg.fileName.suffix.phaseEncodingDirection;
    recSuffix = cfg.fileName.suffix.reconstruction;
    echoSuffix = cfg.fileName.suffix.echo;
    recordingSuffix = cfg.fileName.suffix.recording;

    thisDate = cfg.fileName.date;

    cfg.fileName.datasetDescription = fullfile ( ...
                                                cfg.dir.output, ...
                                                'dataset_description.json');

    % create base fileName
    fileNameBase = ...
        ['sub-', subjectGrp, sprintf(pattern, subjectNb), ...
         '_ses-', sprintf(pattern, sessionNb), ...
         '_task-', taskName];
    cfg.fileName.base = fileNameBase;

    switch modality

        case 'func'

            basename = [fileNameBase, ...
                        acqSuffix, ceSuffix, ...
                        dirSuffix, recSuffix, ...
                        runSuffix, echoSuffix];

        case 'beh'

            basename = ...
                [fileNameBase, ...
                 acqSuffix, ...
                 runSuffix];

        otherwise

            basename = [fileNameBase, runSuffix];

    end

    cfg.fileName.events = [basename, '_events_date-' thisDate '.tsv'];

    cfg.fileName.stim = [basename, recordingSuffix, '_stim_date-' thisDate '.tsv'];

    if cfg.eyeTracker.do
        cfg.fileName.eyetracker = ...
            [basename, '_recording-eyetracking_physio_date-' thisDate '.edf'];
    end

end

function talkToMe(cfg)

    if cfg.verbose > 0

        fprintf(1, '\nData will be saved in this directory:\n\t%s\n', ...
                fullfile(cfg.dir.outputSubject, cfg.fileName.modality));

        fprintf(1, '\nData will be saved in this file:\n\t%s\n', ...
                cfg.fileName.events);

        if cfg.eyeTracker.do

            fprintf(1, '\nEyetracking data will be saved in this directory:\n\t%s\n', ...
                    fullfile(cfg.dir.outputSubject, 'eyetracker'));

            fprintf(1, '\nEyetracking data will be saved in this file:\n\t%s\n', ...
                    cfg.fileName.eyetracker);

        end

    end

end
