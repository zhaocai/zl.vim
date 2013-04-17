require 'rake/distribute'
require "hashie"
require 'awesome_print'
require 'zucker/debug'
require 'facets/string'



# ============================================================================
# settings:                                                               [[[1
# ============================================================================
    
vundle = File.join(Dir.home, '.vim', 'bundle')

zl_src = FileList['src/*.vim.erb']
zl_version = 130






# ============================================================================
# bundles:                                                                [[[1
# ============================================================================


bundles = {
  GoldenView: {
    :bundle => 'GoldenView.Vim',
    :name =>   'GoldenView',
    :export => [
      'rc', 'print', 'rule', 'list', 
      'var', 'window', 'regex'
    ].map {|v| "src/#{v}.vim.erb" },
  },
  zl: {
    :bundle => 'zl.vim',
    :name =>   'zl',
    :dest => File.join(vundle, 'zl.vim', 'autoload', 'zl'),
    :context => {
      :zl => "zl" ,
      :zu => "zl",
    },
  }
}

bundles = bundles.map { |k,v|
  item = Hashie::Mash.new({
    :context => {
      :zl => "#{v[:name]}#zl" ,
      :zu => "#{v[:name]}_zl",
      :version => zl_version ,
    },
    :export => zl_src,
    :dest => File.join(vundle, v[:bundle], 'autoload', v[:name], 'zl'),
  }).deep_merge!(v)
}


# ============================================================================
# distribution tasks:                                                     [[[1
# ============================================================================




bundles.each do |b|
  desc "install zl.vim"
  task :install => ["#{b[:name]}:install"]
  namespace b[:name] do

    b[:export].each do |f|
      distribute :ErbFile do
        from f
        to   File.join(b[:dest], File.basename(f, '.erb'))
        with_context b.context
        diff { |dest, src|
          system %Q{vimdo diff "#{dest}" "#{src}"}
        }
      end
    end

  end
end

desc "Print Distribute Info"
task :info => [] do
  ap bundles
end


