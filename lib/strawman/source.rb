module Strawman
  class Source
  end

  #
  # A source that parses a twitter feed for urls which points to proxies, like
  # http://twitter.com/proxy_lists. The class is deferable itself and fires
  # its callback once the feed has been fetched and parsed.
  #
  # By default it caches the feed to disk (cache/twitter-username.json), and
  # fetches a new copy after that file is an hour old. To disable this, simply
  # pass in false to the constructor.
  #
  class TwitterSource < Source
    include EventMachine::Deferrable
    ONE_HOUR = 60*60
    attr_reader :proxies

    #
    # [twitter_username]  Just the twitter user's username. Not the full url.
    #
    # [cache]  Whether to enable or disable caching. Defaults to enabling
    #          caching.
    #
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

        @proxies = parse(data)

        succeed
      end
    end

  private
    def parse(data)
      JSON.parse(data).map do |status|
        match = /.*(http:\/\/.*)/.match(status["text"])

        if match
          GlypeProxy.new(match[1])
        else
          nil
        end
      end.compact
    end

    def cache_dir
      "cache"
    end

    def cache_file_path
      File.join cache_dir, "twitter-#{@id}.json"
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
