module Strawman
  class Source
  end

  class TwitterSource < Source
    include EventMachine::Deferrable
    ONE_HOUR = 60*60
    attr_reader :proxies

    def initialize(twitter_username, cache=true)
      @id = twitter_username
      @cache = cache

      if cache
        fetched = update_cache
      else
        fetched = fetch
      end

      fetched.callback do
        if @cache
          data = read_cache
        else
          data = fetched.response
        end

        @proxies = JSON.parse(data).map do |status|
          match = /.*(http:\/\/.*)/.match(status["text"])

          if match
            GlypeProxy.new(match[1])
          else
            nil
          end
        end.compact

        # Notify that the source is now initialized
        succeed
      end
    end

  private
    def cache_dir
      "cache"
    end

    def cache_file_path
      File.join cache_dir, "#{@id}.json"
    end

    def cache_file_url
      "http://twitter.com/statuses/user_timeline/#{@id}.json"
    end

    def read_cache
      File.read(cache_file_path)
    end

    def update_cache
      begin
        f = File.new(cache_file_path)
        seconds_since_update = (Time.now - f.mtime)
        if seconds_since_update > ONE_HOUR
          fetch
        else
          d = EventMachine::Deferrable.new
          d.set_deferred_success
        end
      rescue Exception
        fetch
      end
    end

    def fetch
      http = Transport.new(cache_file_url).get

      if @cache
        http.callback do
          FileUtils.mkdir(cache_dir) unless File.exist? cache_dir
          open(cache_file_path, "w") do |f|
            f.write(http.response)
          end
        end
      end

      http
    end
  end
end
