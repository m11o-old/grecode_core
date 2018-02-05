#! /usr/bin/env ruby

require 'optparse'
require 'pathname'
require "open3"

def build_grep_opts(options)
  options.map do |key, value|
    key = key.to_s
    if %w(A B).include? key
      "-#{key} #{value}"
    elsif %w(E F G B c h i l n s w x r).include? key
      "-#{key}"
    elsif %w(e f).include? key
      "-#{key} #{value}"
    elsif %w(target).include? key
      value
    end
  end.join(" ")
end

options = {}
OptionParser.new do |opt|
  opt.on('-d', '--dir=dir,dir,...', Array, '検索するディレクトリを指定します') do |dirs|
    options[:dir] = dirs.map {|dir| Pathname.new(dir).expand_path}
  end

  opt.on('-A num', '\A[1-9][0-9]*\z', 'マッチした行から後num行を同時に検索結果として表示する'){|v| options[:A] = v}
  opt.on('-B num', '\A[1-9][0-9]*\z', 'マッチした行から前num行を同時に検索結果として表示する'){|v| options[:B] = v}
  # -NUMをどう実装するか検討
  opt.on('-G', '検索に正規表現を使用できる'){|v| options[:G] = v}
  opt.on('-E', '検索に拡張正規表現を使用できる'){|v| options[:E] = v}
  opt.on('-F', '固定文字列の検索を行う'){|v| options[:F] = v}
  opt.on('-C', 'マッチした前後2行を同時に検索結果として表示する'){|v| options[:C] = v}
  opt.on('-b', '各行の前に，ファイルの先頭からバイト単位のオフセット数を表示する'){|v| options[:b] = v}
  opt.on('-n', '各行の前に行番号を表示する'){|v| options[:n] = v}
  opt.on('-c', '検索条件にマッチした行数を表示する。-cvとするとマッチしなかった行数を表示する'){|v| options[:c] = v}
  opt.on('-e pattern', '検索条件を指定する'){|v| options[:e] = v}
  opt.on('-f file', '検索パターンとしてfileの内容を使用する'){|v| options[:f] = v}
  opt.on('-h', '検索結果の先頭にマッチしたファイル名を表示しない'){|v| options[:h] = v}
  opt.on('-i', '検索条件に大文字と小文字の区別をなくす'){|v| options[:i] = v}
  opt.on('-l', '検索条件にマッチしたファイル名を表示する。-lvとするとマッチしなかったファイル名を表示する'){|v| options[:l] = v}
  opt.on('-q', '検索結果を表示しない'){|v| options[:q] = v}
  #-sのエラーを表示しないための実装をどうするか
  opt.on('-s', 'エラー・メッセージを表示しない'){|v| options[:s] = v}
  opt.on('-v array', Array, 'マッチしない行を検索結果として表示する'){|v| options[:v] = v}
  opt.on('-w', 'パターン・マッチを，単語全体で行うようにする'){|v| options[:w] = v}
  opt.on('-x', '行全体を検索対象にする'){|v| options[:x] = v}
  opt.on('-r', '検索結果のディレクトリ構造を表示する'){|v| options[:r] = v}
  opt.on(/\-\d+/, 'test'){|v| options[:num] = v}

  opt.parse!(ARGV)
end

dirs = options.delete :dir if options.has_key? :dir

if ARGV.count == 1
  options.merge! target: ARGV.first
end

file_paths = dirs.map do |dir|
  cmd = "grep #{build_grep_opts(options)} -l #{dir}/*"
  if options[:v].any?
    options[:v].each do |except|
      cmd += " | grep -v #{except}"
    end
  end
  puts cmd

  output, error, status = Open3.capture3(cmd)
  output.gsub("\n", " ")
end.join(" ")


`code -n #{file_paths}`

