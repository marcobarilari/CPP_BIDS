function cfg = userInputs(cfg)
    % cfg = userInputs(cfg)
    %
    % Get subject, run and session number and make sure they are
    % positive integer values
    %
    % expParameters.subject.askGrpSess
    % a 1 X 2 array of booleans (default is [true true] ):
    %    - the first value set to false will skip asking for the participants
    %    group
    %    - the second value set to false will skip asking for the session

    if nargin < 1
        cfg = [];
    end
    if isempty(cfg.debug)
        cfg.debug.do = false;
    end

    cfg = checkCFG(cfg);

    [cfg, responses] = setDefaultResponses(cfg);

        askGrpSess = cfg.subject.askGrpSess;

    end
    if numel(askGrpSess) < 2
        askGrpSess(2) = 1;
    end

        if cfg.useGUI

            try
                responses = askUserGui(questions, responses);
            catch
                responses = askUserCli(questions, responses);
            end

        else

            responses = askUserCli(questions, responses);

        end

        % the subject number
        subjectNb = str2double(input('Enter subject number (1-999): ', 's'));
        subjectNb = checkInput(subjectNb);

        % the session number
        if  numel(askGrpSess) > 1 && askGrpSess(2)
            sessionNb = str2double(input('Enter the session (i.e day - 1-999)) number: ', 's'));
            sessionNb = checkInput(sessionNb);
        end

        % the run number
        runNb = str2double(input('Enter the run number (1-999): ', 's'));
        runNb = checkInput(runNb);

    end

    cfg.subject.subjectGrp = subjectGrp;
    cfg.subject.subjectNb = subjectNb;
    cfg.subject.sessionNb = sessionNb;
    cfg.subject.runNb = runNb;

end

function input2check = checkInput(input2check)
    % this function checks the input to makes sure the user enters a positive integer
    while isnan(input2check) || fix(input2check) ~= input2check || input2check < 0
        input2check = str2double(input('Please enter a positive integer: ', 's'));
    end
end
