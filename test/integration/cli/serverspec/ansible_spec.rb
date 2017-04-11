require_relative '../../helper_spec.rb'

context 'Ansible binaries' do
  describe command 'command -v ansible' do
    it 'executes ansible' do
      expect(subject.exit_status).to eq 0
    end
  end

  describe command 'command -v ansible-playbook' do
    it 'executes ansible-playbook' do
      expect(subject.exit_status).to eq 0
    end
  end

  describe command 'command -v ansible-doc' do
    it 'executes ansible-doc' do
      expect(subject.exit_status).to eq 0
    end
  end

  describe command 'command -v ansible-galaxy' do
    it 'executes ansible-galaxy' do
      expect(subject.exit_status).to eq 0
    end
  end

  describe command 'command -v ansible-pull' do
    it 'executes ansible-pull' do
      expect(subject.exit_status).to eq 0
    end
  end

  describe command 'command -v ansible-vault' do
    it 'executes ansible-vault' do
      expect(subject.exit_status).to eq 0
    end
  end

  # describe command 'command -v ansible-console' do
  #   let(:pre_command) { 'avm use v2.1' }
  #   it 'executes ansible-console' do
  #     expect(subject.exit_status).to eq 0
  #   end
  # end

end

