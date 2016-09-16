# TestRail-API-Tool

TestRail (http://www.gurock.com/testrail/) is one of the best test case management software available. It has available APIs which can be used to mark your automated test results.

This is a command line tool that parses through all your RSPEC XML results file or Squish results file and marks all the test cases (Passed, Failed, ...) via API calls. This is a very useful tool to mark your test cases after running your automation tests using RSpec or Squish tests. 

To Use:

1) Get all the files. 
   $ git clone https://github.com/ibaralf/TestRail-API-Tool.git

2) Make sure you have ruby installed
   $ ruby -version

3) Make sure you have nokigiti gem installed
  $ gem install nokogiri

4) Run the TestRail tool with help 
  $ ruby trail_marker.rb -h

5) Run with required arguments
  $ ruby trail_marker.rb -p Test Project Name -r test_run_auto -x ../some/directory/results


Arguments required:

-p Name of Project

-r or -t, Name of test run or test plan to mark

-x Directory path where XML test results are located


For RSPEC files: 
   Tag all the tests with the correct test case
   
   Ex:
   
      it “should login to Files as a regular user (TestRail: C27)” do
      => This would mark TestRail cases number 27
      
      it “should login to Files as a regular user (TestRail: C11, C12 )” do
      => This would mark two test cases, number 11 and 12, at the same time

For SquishReport (Not sure how this is formatted - please edit):
   Tag all verification name with the correct test case
   Ex (results XML should be):
      <verification line="114" type="" name=“Transfer (TestRail: C76, C92) " file="C:/qatools/scp/suite_connections/tst_clone/test.rb">
            <result type="PASS" time="2015-07-06T11:20:58-07:00">
                <description>Comparison</description>
            </result>
        </verification>

NOTE: You can associate multiple Test Cases to a single automated test if needed (TestRail C111, C222, …)

<b>Other Options</b>

    -h, Show HELP
    -p *, name of project (e.g. Production Push) (required parameter) 
    -r or -t *, name of test run (-r) or test plan (-t) (required parameter) 
    -m, milestone name (can be used when creating a test run)
    -s, test suite name (* required when creating a test run)
    -u, user (e.g. ibarra@asperasoft.com)
    -pw, password or token (recommended)
    -url, URL of TestRail (e.g. https://test.aspera.us/testrail)
    -d, debug mode (set to false to suppresses most messages)
    -x or -f *, path (-x, Directory) or specific file (-f) for results to parse 
    -com, comment to put on each test
    
    '-cm', '-cr', '-ct'  => Creates milestones, runs, or test plan
    '-dm', '-dr', '-dt' => Deletes milestones, runs, test plan
    
