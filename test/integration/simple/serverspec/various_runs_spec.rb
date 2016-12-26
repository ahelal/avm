require_relative '../../helper_spec.rb'

context 'Ansible ad-hoc run' do
  describe command 'ansible --version' do
    it 'Ansible 1.9' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('ansible 1.9')
    end
  end

  describe command 'ansible -i localhost, -c local -m ping all' do
    it 'ping pongs' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('localhost | success')
    end
  end

  describe command 'ansible -i localhost, -c local -m copy -a "src=/etc/passwd dest=/tmp/myfile.tmp mode=0666" all' do
    it 'copys /etc/passwd to /tmp/myfile.tmp' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('localhost | success')
    end
  end

  describe file('/tmp/myfile.tmp') do
    it 'templated file exisits' do
      should exist
      should be_file
      should be_mode 666
    end
  end

end
