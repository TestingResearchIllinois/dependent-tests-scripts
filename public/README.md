# Dependent-Test-Aware Regression Testing Techniques
This repository contains tools for dependent-test-aware regression testing techniques.

More details about the algorithms that are supported can be found in its [paper](http://mir.cs.illinois.edu/winglam/publications/2020/LamETAL20ISSTA.pdf) and [website](https://sites.google.com/view/test-dependence-impact).

# Usage
The dependent-test-aware regression testing techniques are meant to be used on two versions of a subject. We will refer to the older version as the *firstVers* and the later version as the *subseqVers*.

The algorithms of the techniques require three main steps:
1. Setting up the metadata needed for the regression testing algorithms on the firstVers
2. (Optional) Computing the test dependencies for the regression testing algorithms on the firstVers
3. Running the regression testing algorithms on the subseqVers

## Relevant contents of this directory
- ```setup.sh``` main script to setup the metadata needed for the regression testing algorithms (Step 1)
- ```compute-deps.sh``` main script to compute dependencies for the regression testing algorithms (Step 2)
- ```run.sh``` main script to run the regression testing algorithms (Step 3)
- ```example.sh``` example script for how to run the three main scripts
- ```dt-impact-tracer``` source code of the enhanced and unenhanced regression testing algorithms

<!-- - ```setup``` scripts to setup the metadata needed for the regression testing algorithms -->
<!-- - ```compute-deps``` scripts to compute dependencies for the regression testing algorithms -->
<!-- - ```run``` scripts to run the regression testing algorithms -->
<!-- - ```shared``` contains scripts shared between the three steps -->

## Prerequisites
- The firstVers and subseqVers must be installed and its dependencies are copied into the ```target/dependency``` directory
- All tests in the original test order must pass. Step (1) will generate an original order to run and any test that doesn't pass in the original order is skipped in the regression testing orders
- It is possible that rerunning the setup script will give different coverage of tests (e.g., one test can cover different paths in different test runs) and consequently result in different regression testing orders. The coverage of tests that achieved the results in our paper is available at [here]()
- The tools are intended to work with JUnit tests that are compatiable with JUnit version 4.12

## General use case
To use the dependent-test-aware regression testing algorithms on any Maven-based, Java project one would need to do the following.
1. Compile the firstVers and subseqVers of any project (e.g., running ```mvn install dependency:copy-dependencies```)
2. Setup the metadata by running ```bash setup.sh <path_to_firstVers_module> <algorithm_label> <path_to_subseqVers_module>```
3. (Optional) Compute dependencies by running ```bash compute-deps.sh <path_to_firstVers_module> <algorithm_label> <path_to_subseqVers_module>```
4. Running the regression testing algorithm by running ```bash run.sh <path_to_firstVers_module> <algorithm_label> <path_to_subseqVers_module>```

The supported ```algorithm_label``` can be found in Tables 1-3 of our [paper](http://mir.cs.illinois.edu/winglam/publications/2020/LamETAL20ISSTA.pdf).

## Example use case
The ```example.sh``` in the repository runs the enhanced algorithms on ```kevinsawicki/http-request``` (M9). E.g., running ```bash example.sh t2``` runs (test prioritization, statement, relative) on M9 and it generally takes about 33 minutes to run. The script will then generate the following in the current directory:
- ```firstVers``` directory containing the firstVers of M9 (```d0ba95c```)
- ```secondVers``` directory containing the subseqVers of M9 (```ef89ec6```)
- ```logs``` directory containing the logs for running the various steps including building the two different versions of M9
- ```lib-results``` directory containing the results of the three steps. Specifically, the directory contains
  - ```PRIORITIZATION-ORIG-LIB-STATEMENT-RELATIVE-CONTAINS_DT-GIVEN_TD-false.txt``` contains the results of each test, the order the tests ran, and number of dependent tests observed in the enhanced T2 algorithm
  - ```prio-DT_LIST-lib-statement-relative.txt``` contains the computed dependencies used to enhance the T2 algorithm
  - ```lib-orig-order``` contains the original order used. When running this order, all tests are observed to have passed
  - ```lib-ignore-order``` contains the tests that failed in the original order and are ignored for the algorithms
  - ```lib-orig-time.txt``` contains the time each test took to run in the original order
  - ```sootTestOutput-orig``` contains the coverage of each test
  - ```PRIORITIZATION-ORIG-LIB-STATEMENT-RELATIVE-FIXED_DT-OMITTED_TD-false.txt``` contains debugging information from computing dependencies

# Cite
If you use any of this work, please cite our corresponding [ISSTA paper](http://mir.cs.illinois.edu/winglam/publications/2020/LamETAL20ISSTA.pdf):
```
@inproceedings{LamETAL2020ISSTA,
    author      = "Wing Lam and August Shi and Reed Oei and Sai Zhang and Michael D. Ernst and Tao Xie",
    title       = "Dependent-Test-Aware Regression Testing Techniques",
    booktitle   = "ISSTA 2020, Proceedings of the 2020 International Symposium on Software Testing and Analysis",
    month       = "July",
    year 	= 2020,
    address 	= "Virutal Event",
    pages       = "pages-to-appear"
}
```
