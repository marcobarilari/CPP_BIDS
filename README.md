[![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?style=flat-square)](#contributors-) [![Build Status](https://travis-ci.com/cpp-lln-lab/CPP_BIDS.svg?branch=master)](https://travis-ci.com/cpp-lln-lab/CPP_BIDS)

# CPP_BIDS

<!-- TOC -->

- [CPP_BIDS](#cpp_bids)
  - [Usage](#usage)
  - [Functions descriptions](#functions-descriptions)
    - [userInputs](#userinputs)
    - [createFilename](#createfilename)
    - [saveEventsFile](#saveeventsfile)
    - [checkCFG](#checkcfg)
  - [How to install](#how-to-install)
    - [Use the matlab package manager](#use-the-matlab-package-manager)
  - [Contributing](#contributing)
    - [Guidestyle](#guidestyle)
    - [BIDS naming convention](#bids-naming-convention)

<!-- /TOC -->

A set of function for matlab and octave to create [BIDS-compatible](https://bids-specification.readthedocs.io/en/stable/) folder structure and filenames for the output of behavioral, EEG, fMRI, eyetracking studies.


## Contributing

% create the filenames
expParameters = createFilename(cfg, expParameters);

% initialize the events files with the typical BIDS
% columns (onsets, duration, trial_type)
% and add some more in this case (Speed and is_Fixation)
logFile = saveEventsFile('open', expParameters, [], 'Speed', 'is_Fixation');

% create the information about 2 events that we want to save
logFile(1,1).onset = 2;
logFile(1,1).trial_type = 'motion_up';
logFile(1,1).duration = 1;
logFile(1,1).speed = 2;
logFile(1,1).is_fixation = true;


## Functions descriptions


### userInputs


### createFilename


### saveEventsFile


### checkCFG

-   Eyetracker

`sub-<participant_label>[_ses-<label>][_acq-<label>]_task-<task_label>_eyetrack.<manufacturer_specific_extension>`
