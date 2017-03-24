require_relative '../../helper_spec.rb'

context 'Directory stucture for V1' do
  describe command '/home/kitchen/.avm/v1/venv/bin/python -c "import boto"' do
    it 'does not have boto installed' do
      expect(subject.exit_status).to eq 1
    end
  end

  describe file('/home/kitchen/.avm/v1/ansible/.git') do
    it 'does not have .git' do
      should_not exist
    end
  end
end

context 'Directory stucture for V2' do
  describe command '/home/kitchen/.avm/v2/venv/bin/python -c "import boto"' do
    it 'does not have boto installed' do
      expect(subject.exit_status).to eq 1
    end
  end

  describe file('/home/kitchen/.avm/v2/ansible/.git') do
    it 'does not have .git' do
      should_not exist
    end
  end
end

context 'Directory stucture for devel' do
  describe command '/home/kitchen/.avm/devel/venv/bin/python -c "import boto"' do
    it 'does not have boto installed' do
      expect(subject.exit_status).to eq 1
    end
  end

  describe file('/home/kitchen/.avm/.source_git/ansible/.git') do
    it 'has .git' do
      should exist
    end
  end

  describe command 'cd /home/kitchen/.avm/.source_git/ansible/;git branch' do
    it 'is devel' do
      expect(subject.stdout).to match('devel')
    end
  end

end

context 'Directory stucture venv' do
  describe file('/home/kitchen/.avm/') do
    it 'has right perm' do
      should exist
      should be_directory
      should be_mode 755
      should be_owned_by 'kitchen'
    end
  end
end
