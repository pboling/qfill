# frozen_string_literal: true

module Support
  module Helper
    def build_elements(name, num)
      array = []
      Array.new(num).each_with_index.map do |_x, i|
        array << "#{name}-#{i}"
      end
      array
    end
  end
end
