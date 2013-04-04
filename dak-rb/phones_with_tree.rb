dic_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'dictionary.txt'))
in_file  = File.expand_path(File.join(File.dirname(__FILE__), '..', 'input.txt'))
out_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'output.txt'))

MEMO = { 2 => "ABC", 3 => "DEF", 4 => "GHI", 5 => "JKL", 6 => "MNO", 7 => "PQRS", 8 => "TUV", 9 => "WXYZ" }
CODES = MEMO.reduce({}) {|acc, (k, v)| v.chars.reduce(acc) {|_acc, ch| _acc.merge ch => k.to_i } }

class DigitsTree
  attr_accessor :items, :children

  def initialize(items = [], children = [])
    @items, @children = items, children
  end

  def store(word, digits = to_digits(word))
    digit, *rest = digits
    if digit
      DigitsTree.new(items, updated_children(digit, get_child(digit).store(word, rest)))
    else
      DigitsTree.new(items + [word], children)
    end
  end

  def get((digit, *rest))
    if digit
      get_child(digit).get(rest)
    else
      items
    end
  end

  private

  def get_child(digit)
    children[digit] || DigitsTree.new
  end

  def updated_children(digit, new_child)
    children.clone.tap {|ch| ch[digit] = new_child}
  end

  def to_digits(word)
    word.upcase.chars.map {|ch| CODES[ch]}
  end
end

@words = File.open(dic_file).select { |w| w =~ /^\w+$/ }.map(&:chomp)
@words_tree = @words.reduce(DigitsTree.new) {|acc, word| acc.store word}

def _encode digits
  return [[]] if digits.empty?
  (1..digits.size).flat_map do |i|
    @words_tree.get(digits.take(i)).flat_map do |word|
      _encode(digits.drop(i)).map {|words| words.unshift word}
    end
  end
end

def encode number
  _encode(number.chars.map(&:to_i).to_a).map {|words| words.join(' ').downcase }
end

File.open(out_file, 'w') do |out|
  File.open(in_file).each do |line|
    number = line.chomp
    codes = encode number
    codes.map {|code| "#{number} #{code}\n"}.each {|encoding| out.write(encoding) }
  end
end
