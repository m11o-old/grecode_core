#! /usr/bin/env ruby

require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('-d', '--dir=dir,dir,...', Array, '検索するディレクトリを指定します'){|v| options[:dir] = v}
  opt.on('-A num', '\A[1-9][0-9]*\z', 'マッチした行から後num行を同時に検索結果として表示する'){|v| options[:A] = v}
  opt.on('-B num', '\A[1-9][0-9]*\z', 'マッチした行から前num行を同時に検索結果として表示する'){|v| options[:B] = v}
  # -NUMをどう実装するか検討


  opt.parse!(ARGV)
end
puts options