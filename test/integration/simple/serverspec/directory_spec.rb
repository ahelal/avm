require_relative '../../helper_spec.rb'

context 'Directory stucture for V1' do
  describe command '/home/kitchen/.venv_ansible/v1/venv/bin/python -c "import boto"' do
    it 'does not have boto installed' do
      expect(subject.exit_status).to eq 1
    end
  end

  describe file('/home/kitchen/.venv_ansible/v1/ansible/.git') do
    it 'does not have .git' do
      should_not exist
    end
  end
end

context 'Directory stucture for V2' do
  describe command '/home/kitchen/.venv_ansible/v2/venv/bin/python -c "import boto"' do
    it 'does not have boto installed' do
      expect(subject.exit_status).to eq 1
    end
  end

  describe file('/home/kitchen/.venv_ansible/v2/ansible/.git') do
    it 'does not have .git' do
      should_not exist
    end
  end
end

context 'Directory stucture for devel' do
  describe command '/home/kitchen/.venv_ansible/devel/venv/bin/python -c "import boto"' do
    it 'does not have boto installed' do
      expect(subject.exit_status).to eq 1
    end
  end

  describe file('/home/kitchen/.venv_ansible/devel/ansible/.git') do
    it 'has .git' do
      should exist
    end
  end
end

context 'Directory stucture venv' do
  describe file('/home/kitchen/.venv_ansible/') do
    it 'has right perm' do
      should exist
      should be_directory
      should be_mode 755
      should be_owned_by 'kitchen'
    end
  end
end
