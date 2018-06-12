This directory contains the scripts used to generate the results in the dt-impact paper. 

The following are expected to be in this directory.

- all-subj-precomputed-dependences.sh - Generates the precomputed dependences for all of the subjects in the paper.
- all-subj-prio-sele-para.sh - Generates the test prioritization, selection and parallelization results for all of the subjects in the paper.
- data/ - Directory containing information used by the scripts in this directory.
- compile.sh - Compiles all of the subjects in the paper.
- constants.sh - File containing the constants pertaining to the regression testing techniques.
- one-subj.sh - Generates the results for a specific subject specified by the arguments to this script.
- setup-vars.sh - Sets the environment variables used by our scripts automatically. Run `source setup-vars.sh` to use.
- subj-constants.sh - File containing the constants pertaining to the subjects. 
- subj-para.sh - Generates the test parallelization results for a specific subject.
- subj-prio.sh - Generates the test priorization results for a specific subject.
- subj-sele.sh - Generates the test selection results for a specific subject.

