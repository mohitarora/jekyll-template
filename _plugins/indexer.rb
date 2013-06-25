require 'uri'
require 'net/http'
require 'rexml/document'

module Jekyll

	class Indexer < Generator

		def initialize(config = {})
			super(config)
			# Raise Error if solr configuration parameters are missing.
			raise ArgumentError.new 'Missing solr_indexing_url.' unless config['solr_indexing_url']
			@solr_url = config['solr_indexing_url'].concat("?fmap.content=attr_content&commit=true&literal.id=")
	    end

		def generate(site)
			puts 'Indexing pages...'
			#items = site.html_pages
	    	items = site.pages.dup.concat(site.posts)
			# only process files that will be converted to .html and only non excluded files 
			items = items.find_all {|i| i.output_ext == '.html'} 
			items.reject! {|i| i.data['exclude_from_search'] } 

			items.each do |item|              
				puts 'Indexing page:' << item.url
				page_text = extract_text(site,item)
				# Build Request URL
				url = URI.parse(@solr_url.dup.concat(item.url))
				# Build HTTP CLient object
				http = Net::HTTP.new(url.host, url.port)
				# Build Http Post Request
				request = Net::HTTP::Post.new(url.request_uri)
				request["Content-type"] = 'text/html'
		        # Adding Title tag so that solr can index it and it can be shown on results page.
		        request.body = '<title>' + (item.data['title'] || item.name) + '</title>' + page_text
				response = http.start {|http| http.request(request) }
				response_data = REXML::Document.new(response.body)
				solr_response_code = response_data.elements["response/lst/int[@name='status']"].text
				if solr_response_code.to_i > 0
					raise 'Solr Indexing Failed with reason' << response.body
				end
	      
        	end
        	puts 'Indexing done'
		end

		def extract_text(site, page)
			page.render({}, site.site_payload)	
			page_text = page.output		
		end

	end
end