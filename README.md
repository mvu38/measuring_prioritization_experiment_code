# Experiment code and stimuli for _Getting to the Heart of it: Multi-Method Exploration of Nonconscious Prioritization Processes_
Each folder in this repository contains the code used to run one of the experiments reported in Abir, Y. & Hassin, R. R. (Under review). _Getting to the Heart of it: Multi-Method Exploration of Nonconscious Prioritization Processes_.

Experiments 1a, 1b, 3a and 3b run on Psychtoolbox for Matlab. We achieved excellent presentation timings only when running in a Linux environment.

Experiment 2 ran on the browser, using [jsPsych](https://www.jspsych.org) for coding the experiment, [GSAP](https://greensock.com/gsap/) for high-performance animation and [psiTurk](https://psiturk.org) for setting up a server.

Lastly, an improved version of the jsPsych plugin used to run a bRMS trial is included in _jspsych_brms_plugins_. It requires the pro version of GSAP, and jsPsych v6.0.
It also includes a test-version of this plugin, which can be used to run animation trials that are invisible to the participant. This plugin outputs metric of the animation performance, which can be used to exclude participants with underpowered setups. Use this several times at the beginning of an experiment.

For any questions or comments please contact yaniv.abir@columbia.edu
