require 'progressing'

class TempClass
  include Custom::Progressing
end

RSpec.describe TempClass, "#format_terminal_progressing" do
  context "print processing" do
    it "test some number" do
      temp = TempClass.new
      length = TempClass::DefaultLength

      expect_string1 = "[##################################################]"
      expect(temp.format_terminal_progressing(100)).to eq expect_string1

      expect_string2 = "[##########                                        ]"
      expect(temp.format_terminal_progressing(20)).to eq expect_string2
    end
  end
  
end
