dic_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'dictionary.txt'))
in_file  = File.expand_path(File.join(File.dirname(__FILE__), '..', 'input.txt'))
out_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'output.txt'))

@words = File.open(dic_file).select { |w| w =~ /^\w+$/ }.map(&:chomp)
@memo = { "2" => "ABC", "3" => "DEF", "4" => "GHI", "5" => "JKL", "6" => "MNO", "7" => "PQRS", "8" => "TUV", "9" => "WXYZ" }
@codes = @memo.reduce({}) {|acc, (k, v)| v.chars.reduce(acc) {|_acc, ch| _acc.merge ch => k } }

@words_map = @words.group_by { |word|
  word.upcase.chars.map {|ch| @codes[ch]}.join
}.tap {|map| map.default = []}

def _encode digits
  return [[]] if digits.empty?
  (1..digits.size).flat_map do |i|
    @words_map[digits.take(i).join].flat_map do |word|
      _encode(digits.drop(i)).map {|words| words.unshift word}
    end
  end
end

def encode number
  _encode(number.chars.to_a).map {|words| words.join(' ').downcase }
end

File.open(out_file, 'w') do |out|
  File.open(in_file).each do |line|
    number = line.chomp
    codes = encode number
    codes.map {|code| "#{number} #{code}\n"}.each {|encoding| out.write(encoding) }
  end
end
