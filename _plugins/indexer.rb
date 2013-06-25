require 'uri'
require 'net/http'
require 'rexml/document'

module Jekyll

	class Indexer < Generator

		def initialize(config = {})
			super(config)
			# Raise Error if solr host is missing in configuration.
			raise ArgumentError.new 'Missing solr_host.' unless config['solr_host']
			@solr_index_url = config['solr_host'].dup.concat("/solr/update/extract?fmap.content=attr_content&commit=true&literal.id=")
			#@solr_delete_index_url = config['solr_host'].dup.concat("/solr/update?stream.body=<delete><query>*:*</query></delete>&commit=true")
	    end

		def generate(site)
		    puts 'Deleting existing index..'
		    #delete_index()
		    puts 'Existing index deleted..'
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
				url = URI.parse(@solr_index_url.dup.concat(item.url))
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

		def delete_index()
            uri = URI(@solr_delete_index_url)
            response = Net::HTTP.get(uri)
            response_data = REXML::Document.new(response.body)
            solr_response_code = response_data.elements["response/lst/int[@name='status']"].text
            if solr_response_code.to_i > 0
                raise 'Solr Index Delete Failed with reason' << response.body
            end
		end

	end
end