##################################################################################
#  TestRail is a test case/suite management tool. It has available API in order for 
#  automated tests to mark cases as passed or failed.
#  This tool can be used via command line or called inside your script.
#  
#  unix$ ruby trail_api.rb -h
#
# HISTORY: 4/11/2016 Created
# TODO: Implement configuration file
#
#
require_relative 'testrail'
require_relative 'argument'
require_relative 'response'
require_relative 'request'
require_relative 'api_testrail'
require_relative 'results_parser'

## Use if no arguments are passed
TESTRAIL_URL = 'https://mycompany.testrail.url'
USER_EMAIL = 'user_email@testrail_account.com'
PASSWORD = 'testrail_created_token'

EXIT_MSG = "\nYour test results have been marked on TestRails!\n"
DEFAULT_COMMENT = "Comment to put"
# If user name and password (or token) are passed in the command line arguments
# it would use those instead of the preset values.
#
def get_client(args_passed)
  user = args_passed.get_arg_value('-u') == "" ? USER_EMAIL : args_passed.get_arg_value('-u')
  pw = args_passed.get_arg_value('-pw') == "" ? PASSWORD : args_passed.get_arg_value('-pw')
  url = args_passed.get_arg_value('-url') == "" ? TESTRAIL_URL : args_passed.get_arg_value('-url')
  
  client = TestRail::APIClient.new(url)
  client.user = user
  client.password = pw
  return client
end

# Initial setup - creates API client and API testrail objects
#
def setup(argobj)
  if @client.nil? || @api_testrail.nil?
    @client = get_client(argobj)
    @api_testrail = ApiTestRail.new(@client)
  end
  passed_comment = argobj.get_arg_value('-com')
  @default_comment = passed_comment == "" ? DEFAULT_COMMENT : passed_comment
end

# Determine if results are for a run or a plan.
# Calls method to mark results.
#
def markoff_all_results(argobj) 
  mark_type = "testrun"
  runner = argobj.get_optional_arg(['-r', '-cr'])
  if runner.nil? || runner == ""
    mark_type = "testplan"
    runner = argobj.get_optional_arg(['-t', '-ct'])
  end
  run_ids = []
  project_id = @api_testrail.get_project_id(argobj.get_arg_value('-p'))
  case mark_type
  when "testrun"
    run_name = argobj.get_optional_arg(['-r', '-cr'])
    run_ids << @api_testrail.get_test_runplan_id(project_id, run_name)
  when "testplan"
    plan_name = argobj.get_optional_arg(['-t', '-ct'])
    run_ids = @api_testrail.get_testplan_run_ids(project_id, plan_name)
  end
  markoff(argobj, run_ids)
end

# Parses the XML files and makes API calls to post results to TestRail
def markoff(argobj, run_ids)
  project_id = @api_testrail.get_project_id(argobj.get_arg_value('-p'))
  is_dir = argobj.arg_exists?('-x')
  is_file = argobj.arg_exists?('-f')
  if is_dir || is_file
    results_parser = nil
    #results_file = nil
    if is_dir
      results_parser = ResultsParser.new(argobj.get_arg_value('-x'))
      results_files = results_parser.getAllXMLFiles()
    else
      specific_file = argobj.get_arg_value('-f')
      results_parser = ResultsParser.new(specific_file)
      results_files = Array.new
      results_files << specific_file
    end
    
    if results_files.size <= 0 
      puts "No XML Results found. Please check your directory"
      exit(0)
    end
    results_files.each do |one_file|
      case_results = results_parser.read_XML_file(one_file)
      if ! case_results.nil? && case_results.kind_of?(Array)
        case_results.each do |one_case|
          testrun_ids = []
          testrun_ids += run_ids
          markoff_test_case(@api_testrail, one_case, testrun_ids)
        end
      else
        puts "No Results found in : #{one_file} (Might be empty)"
      end  
    end 
  end
    
end

def markoff_test_case(api_obj, result_hash, run_ids)
  case_id = result_hash[:trail_case].gsub(/[Cc]/, "")
  test_id = nil
  run_id = nil
  puts "@@@@@@ #{run_ids}"
  if run_ids.size > 1
    run_ids.each do |rid|
      tempid = api_obj.get_testid(rid, case_id)
      if ! tempid.nil?
        test_id = tempid
        run_id = rid
        break
      end
    end
  else
    run_id = run_ids.pop()
  end
  passed = result_hash[:passed]
  api_obj.markoff_test(case_id, run_id, passed, @default_comment)
end

def create_milestone(argobj)
  project_name = argobj.get_arg_value('-p')
  milestone_name = argobj.get_arg_value('-m')
  if ! milestone_name.nil?
    @api_testrail.create_milestone(project_name, milestone_name)
  end
end

# USER DOES NOT HAVE PERMISSION. 
# Verify you have super user account or maybe 
# not yet implemented in TestRail. GUI has no delete as well.
def delete_milestone(argobj)
  project_name = argobj.get_arg_value('-p')
  milestone_name = argobj.get_arg_value('-dm')
  if ! milestone_name.nil?
    @api_testrail.delete_milestone(project_name, milestone_name)
  end
end

def create_testrun(argobj)
  project_name = argobj.get_arg_value('-p')
  milestone_name = argobj.get_optional_arg(['-m', '-cm'])
  testrun_name = argobj.get_arg_value('-cr')
  if ! testrun_name.nil?
    @api_testrail.create_testrun(project_name, milestone_name, testrun_name)
  end
end


def check_create(argobj)
  project_name = argobj.get_arg_value('-p')
  if argobj.arg_exists?('-cm')
    milestone_name = argobj.get_arg_value('-cm')
    @api_testrail.create_milestone(project_name, milestone_name)
  end
  run_name = argobj.get_arg_value('-cr')
  if argobj.arg_exists?('-cr')
    milestone_name = argobj.get_optional_arg(['-m', '-cm'])
    suite_name = argobj.get_arg_value('-s')
    @api_testrail.create_testrun(project_name, milestone_name, run_name, suite_name)
  end
end

############################  MAIN  ############################### 
#

# Reads and stores all arguments passed
argument = Argument.new(ARGV)

setup(argument)

# Check for create

check_create(argument)

# Reads the XML results files and marks test plan or test run
markoff_all_results(argument)

# Prints out goodbye message
puts EXIT_MSG

exit(0)











