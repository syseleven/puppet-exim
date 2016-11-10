describe package('exim4') do
  it { should be_installed }
end

# workaround service() auto-detect
# https://github.com/chef/inspec/issues/1171
describe sysv_service('exim4') do
  it { should be_running }
  it { should be_enabled }
  before do
    skip unless os[:release] == '14.04' or os[:release] == '16.04'
  end
end

describe service('exim4') do
  it "is listening on port 25" do
    expect(port(25)).to be_listening
  end
end

options = {
  assignment_re: /^\s*([^:]*?)\s*:\s*(.*?)\s*$/,
  multiple_values: false
}

describe parse_config_file('/etc/aliases', options) do
  its('root') { should eq 'exim@syseleven.de' }
end


describe command('echo test|mail -s test -v root; sleep 10') do
  its('stderr') { should match('RCPT TO:<exim@syseleven.de>') }
  its('stderr') { should match('5.5.1 Error: no valid recipients') }
end

#control '01' do
#  impact 0.7
#  title 'Verify exim4 service'
#  desc 'Ensures exim4 service is up and running'
#  describe sysv_service('exim4') do
#    it { should be_enabled }
#    it { should be_installed }
#    it { should be_running }
#  end
#end
#
