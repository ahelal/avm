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
    let(:pre_command) { 'avm use v2.1' }
    it 'shows version v2.1' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('v2.1')
    end
  end

  describe command 'avm list' do
    it 'show installed version' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match("installed versions:  '2.0.2.0' '2.1.1.0' 'devel' 'v2.0' 'v2.1'")
    end
  end

  describe command 'avm info' do
    let(:pre_command) { 'avm use v2.0' }
    it 'use v2.0' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('v2.0')
    end
  end

  describe command 'ansible --version' do
    let(:pre_command) { 'avm use v2.0' }
    it 'version is set 2.0' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('ansible 2.0')
    end
  end

  describe command 'avm info' do
    let(:pre_command) { 'avm use v2.0' }
    it 'use v1' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('v2.0')
    end
  end

  describe command 'avm path v2.0' do
    it 'print the correct v2.0 path ' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('/home/kitchen/.avm/v2.0/venv/bin/')
    end
  end

  describe command 'avm path v2.1' do
    it 'print the correct v2.1 path ' do
      expect(subject.exit_status).to eq 0
      expect(subject.stdout).to match('/home/kitchen/.avm/v2.1/venv/bin/')
    end
  end

end
