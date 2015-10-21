#!/usr/bin/env ruby

# file: mymedia-polyrex.rb

require 'fileutils'
require 'mymedia'

class MyMediaPolyrexException < Exception
end

class MyMediaPolyrex < MyMedia::Base

  def initialize(public_type: 'polyrex', media_type: 'mmpolyrex', \
                                  config: nil, xsl: '/xsl/polyrex-b.xsl')
    
    @xsl = xsl
    super(media_type: media_type, public_type: @public_type=public_type, config: config)

    @media_src = "%s/media/%s" % [@home, public_type]
    @target_ext = '.xml'
    @rss = true    
  end

  def copy_publish(filename, raw_msg='')

    src_path = File.join(@media_src,filename)

    r = file_publish(src_path, raw_msg='') do |destination, raw_destination|
      
      if not raw_msg or raw_msg.empty? then
        raw_msg = File.basename(src_path) + " updated: " + Time.now.to_s
      end
      
      if File.extname(src_path) == '.txt' then
        raw_msg = copy_edit(src_path, destination)
        copy_edit(src_path, raw_destination,'r/')
      end            
   
      if not File.basename(src_path)[/px\d{6}T\d{4}\.txt/] then
        
        xml_filename = File.basename(src_path).sub(/txt$/,'xml')

        FileUtils.cp destination, @home + '/polyrex/' + xml_filename
        
        if File.extname(src_path) == '.txt' then
          FileUtils.cp src_path, @home + '/polyrex/' + File.basename(src_path)
        end
        
        # publish the static links feed
        dynarex_filepath = @home + '/polyrex/static.xml'
        target_url = "%s/polyrex/%s" % [@website, xml_filename]

        publish_dynarex(dynarex_filepath, {title: xml_filename, url: target_url })
        
      end

      raw_msg
    end    

    r

  end
  
  def copy_edit(src_path, destination,raw='')

    txt_destination = destination.sub(/xml$/,'txt')

    FileUtils.cp src_path, txt_destination        

    buffer = File.read(src_path)
    polyrex = buffer[/<?polyrex /] ? Polyrex.new.parse(buffer) : \
        PolyrexHeadings.new(buffer).to_polyrex
    
    title = polyrex.summary.title || ''
    #puts 'dynarex.summary['tags'] : ' + dynarex.summary.inspect        
    tags = polyrex.summary.tags ? '#' + polyrex.summary.tags.split.join(' #') : ''
    raw_msg = ("%s %s" % [title, tags]).strip        
    #polyrex.summary[:title] = raw_msg

    polyrex.summary.original_source = File.basename(src_path)
    polyrex.summary.source = File.basename(txt_destination)

    polyrex.save(destination, {pretty: true}) do |xml| 
      a = xml.lines.to_a
      line1 = a.shift
      a.unshift %Q{<?xml-stylesheet title="XSL_formatting" type="text/xsl" href="/xsl/#{raw}polyrex-b.xsl"?>\n}
      a.unshift line1
      a.join
    end                

    raw_msg
  end
  
end
