require_relative '../../helper_spec.rb'

context 'AVM commands' do
  describe command 'command -v avm' do
    it 'executes avm' do
      expect(subject.exit_status).to eq 0
    end
  end

  describe command 'avm' do
    it 'no args prints usage' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('Usage')
    end
  end

  describe command 'command -v ansible-vault' do
    it 'executes ansible-vault' do
      expect(subject.exit_status).to eq 0
    end
  end
end

context 'AVM Manage' do
  describe command 'avm installed' do
    it 'shows default version v1' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('v1')
    end
  end

  describe command 'avm list' do
    it 'show installed version' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match("installed versions: '1.9.6' '2.1.1.0' 'devel' 'v1' 'v2'")
    end
  end

  describe command 'avm info' do
    let(:pre_command) { 'avm use v2' }
    it 'use v2' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('v2')
    end
  end

  describe command 'ansible --version' do
    let(:pre_command) { 'avm use v2' }
    it 'version is set 2.1' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('ansible 2.')
    end
  end

  describe command 'avm info' do
    let(:pre_command) { 'avm use v1' }
    it 'use v1' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('v1')
    end
  end

  describe command 'avm path v1' do
    it 'print the correct v1 path ' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('/home/kitchen/.venv_ansible/v1/venv/bin/')
    end
  end

  describe command 'avm path v2' do
    it 'print the correct v2 path ' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('/home/kitchen/.venv_ansible/v2/venv/bin/')
    end
  end

end
