require_relative '../../helper_spec.rb'

context 'AVM activate' do
  describe command 'avm activate' do
    it 'prints arguments' do
      expect(subject.exit_status).to eq 1
      expect(subject.stdout).to match('argument')
    end
  end

  describe command 'avm activate xxxx' do
    it 'pints installed version' do
      expect(subject.exit_status).to eq 1
      expect(subject.stdout).to match('available')
    end
  end

end
