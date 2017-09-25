module Custom
  module Progressing
    DefaultLength = 50

    def format_terminal_progressing(percentage)
      '[' + '#' * scale(percentage).round + " " * (DefaultLength - scale(percentage).round) + ']'
    end

    private
    def scale(number)
      (DefaultLength / 100.0) * number
    end
  end
end
